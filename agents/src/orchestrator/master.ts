// agents/src/orchestrator/master.ts
// Master Orchestrator Agent — coordinates all specialized agents

import { Agent, callable } from 'agents'
import type {
  OrchestratorInput,
  OrchestratorOutput,
  AgentName,
  UserProfile,
  MemoryEntry,
} from '../types/contracts'
import type { Env } from '../types/declarations'

interface OrchestratorState {
  activeSessions: Map<string, { startTime: number; agents: AgentName[] }>
  totalRequests: number
  averageLatency: number
}

export class MasterOrchestrator extends Agent<Env, OrchestratorState> {
  initialState: OrchestratorState = {
    activeSessions: new Map(),
    totalRequests: 0,
    averageLatency: 0,
  }

  @callable()
  async processRequest(input: OrchestratorInput): Promise<OrchestratorOutput> {
    const startTime = Date.now()
    const agentsInvolved: AgentName[] = []

    try {
      // 1. Get user profile
      const profile = await this.callAgent<UserProfile>('user-profile', {
        userId: input.userId,
        sessionId: input.sessionId,
        timestamp: Date.now(),
        action: 'get',
      })
      agentsInvolved.push('user-profile')

      // 2. Get memory context
      const memories = await this.callAgent<MemoryEntry[]>('memory', {
        userId: input.userId,
        sessionId: input.sessionId,
        timestamp: Date.now(),
        action: 'query',
      })
      agentsInvolved.push('memory')

      // 3. Detect intent and select agents
      const intent = await this.detectIntent(input.userMessage, profile)
      const selectedAgents = this.selectAgents(intent, profile)

      // 4. Execute specialized agents in parallel if allowed, else sequentially
      let agentOutput: unknown = null

      const canRunParallel = (agents: AgentName[]): boolean => {
        if (agents.length !== 2) return false
        const pair = [...agents].sort().join('+')
        return [
          'grammar+vocabulary',
          'vocabulary+writing-coach', // writing + vocabulary
          'pronunciation+speaking-coach', // speaking + pronunciation
          'reading-coach+vocabulary', // reading + vocabulary
          'listening-coach+vocabulary', // listening + vocabulary
        ].includes(pair)
      }

      if (canRunParallel(selectedAgents)) {
        console.log(`Executing agents in parallel: ${selectedAgents.join(', ')}`)
        const results = await Promise.all(
          selectedAgents.map(agentName =>
            this.callAgent(agentName, {
              userId: input.userId,
              sessionId: input.sessionId,
              timestamp: Date.now(),
              ...this.buildAgentInput(agentName, input, profile, memories, null),
            })
          )
        )
        agentsInvolved.push(...selectedAgents)
        agentOutput = {
          parallel: true,
          results,
        }
      } else {
        // Execute sequentially
        for (const agentName of selectedAgents) {
          agentOutput = await this.callAgent(agentName, {
            userId: input.userId,
            sessionId: input.sessionId,
            timestamp: Date.now(),
            ...this.buildAgentInput(agentName, input, profile, memories, agentOutput),
          })
          agentsInvolved.push(agentName)
        }
      }

      // 5. Safety review (always executed after generation)
      const safetyResult = await this.callAgent<any>('ai-safety', {
        userId: input.userId,
        sessionId: input.sessionId,
        timestamp: Date.now(),
        content: JSON.stringify(agentOutput),
        contentType: 'lesson',
        level: profile.currentLevel,
      })
      agentsInvolved.push('ai-safety')

      // 6. Quality review (always executed last)
      const qualityResult = await this.callAgent<any>('quality-reviewer', {
        userId: input.userId,
        sessionId: input.sessionId,
        timestamp: Date.now(),
        content: JSON.stringify(agentOutput),
        contentType: intent,
        level: profile.currentLevel,
        language: profile.targetLanguage,
        agent: selectedAgents[selectedAgents.length - 1] || 'lesson-generator',
      })
      agentsInvolved.push('quality-reviewer')

      // 7. Generate response
      const response = this.formatResponse(agentOutput, qualityResult)

      // 8. Update analytics (async, non-blocking)
      this.queue('updateAnalytics', {
        userId: input.userId,
        sessionId: input.sessionId,
        intent,
        latencyMs: Date.now() - startTime,
      })

      const totalLatency = Date.now() - startTime

      // Update state
      this.setState({
        ...this.state,
        totalRequests: this.state.totalRequests + 1,
        averageLatency: (this.state.averageLatency + totalLatency) / 2,
      })

      return {
        response,
        agentsInvolved,
        metadata: {
          totalTokens: 0,
          totalLatencyMs: totalLatency,
          pipeline: agentsInvolved,
        },
      }
    } catch (error) {
      console.error('Orchestrator error:', error)
      return {
        response: 'I apologize, but I encountered an issue processing your request. Let me try again.',
        agentsInvolved,
        metadata: {
          totalTokens: 0,
          totalLatencyMs: Date.now() - startTime,
          pipeline: agentsInvolved,
        },
      }
    }
  }

  @callable()
  async updateAnalytics(input: any): Promise<void> {
    console.log('Background analytics queue triggered:', input)
    try {
      // 1. Fetch user profile via user-profile agent binding
      const profileResult = await this.callAgent<any>('user-profile', {
        userId: input.userId,
        sessionId: input.sessionId,
        action: 'get',
        timestamp: Date.now(),
      })

      if (!profileResult || !profileResult.success || !profileResult.data) {
        console.warn('Could not retrieve user profile for background analytics update.')
        return
      }

      // 2. Fetch user memory history
      const memoryResult = await this.callAgent<any>('memory', {
        userId: input.userId,
        sessionId: input.sessionId,
        action: 'query',
        timestamp: Date.now(),
      })

      const memories = Array.isArray(memoryResult?.data) ? memoryResult.data : []

      // 3. Trigger Learning Analytics Agent in the background
      await this.callAgent('learning-analytics', {
        userId: input.userId,
        sessionId: input.sessionId,
        timestamp: Date.now(),
        timeframe: 'daily',
        profile: profileResult.data,
        memories,
      })

      console.log(`Background analytics update completed successfully for user: ${input.userId}`)
    } catch (err: any) {
      console.error('Failed to run background analytics update:', err.message)
    }
  }

  private async detectIntent(message: string, profile: UserProfile): Promise<string> {
    const lowerMessage = message.toLowerCase()

    // Grammar-related intents
    if (lowerMessage.includes('grammar') || lowerMessage.includes('correct') || lowerMessage.includes('mistake')) {
      return 'grammar'
    }

    // Vocabulary intents
    if (lowerMessage.includes('vocabulary') || lowerMessage.includes('word') || lowerMessage.includes('meaning')) {
      return 'vocabulary'
    }

    // Writing intents
    if (lowerMessage.includes('essay') || lowerMessage.includes('writing') || lowerMessage.includes('review')) {
      return 'writing'
    }

    // Speaking intents
    if (lowerMessage.includes('speak') || lowerMessage.includes('pronunciation') || lowerMessage.includes('pronounce')) {
      return 'speaking'
    }

    // Reading intents
    if (lowerMessage.includes('read') || lowerMessage.includes('passage') || lowerMessage.includes('article')) {
      return 'reading'
    }

    // Listening intents
    if (lowerMessage.includes('listen') || lowerMessage.includes('audio') || lowerMessage.includes('dictation')) {
      return 'listening'
    }

    // Exam prep
    if (profile.targetExam !== 'General' && (
      lowerMessage.includes('exam') || lowerMessage.includes('test') || lowerMessage.includes('practice')
    )) {
      return 'exam-prep'
    }

    // Conversation practice
    if (lowerMessage.includes('practice') || lowerMessage.includes('conversation') || lowerMessage.includes('chat')) {
      return 'conversation'
    }

    // Default: general question
    return 'general'
  }

  private selectAgents(intent: string, profile: UserProfile): AgentName[] {
    const agentMap: Record<string, AgentName[]> = {
      grammar: ['grammar'],
      vocabulary: ['vocabulary'],
      writing: ['writing-coach', 'grammar'],
      speaking: ['speaking-coach', 'pronunciation'],
      reading: ['reading-coach', 'vocabulary'],
      listening: ['listening-coach', 'vocabulary'],
      'exam-prep': ['exam-pattern', 'difficulty-adjustment'],
      conversation: ['conversation'],
      general: ['lesson-generator'],
    }

    return agentMap[intent] || ['lesson-generator']
  }

  private buildAgentInput(
    agentName: AgentName,
    input: OrchestratorInput,
    profile: UserProfile,
    memories: MemoryEntry[],
    previousOutput: unknown
  ): Record<string, unknown> {
    const base = {
      level: profile.currentLevel,
      language: profile.targetLanguage,
    }

    switch (agentName) {
      case 'grammar':
        return { ...base, action: 'correct' as const, sentence: input.userMessage }
      case 'vocabulary':
        return { ...base, action: 'generate' as const, topic: input.userMessage }
      case 'writing-coach':
        return { ...base, text: input.userMessage, taskType: 'essay' as const }
      case 'speaking-coach':
        return { ...base, transcript: input.userMessage }
      case 'reading-coach':
        return { ...base, topic: input.userMessage }
      case 'listening-coach':
        return { ...base, exerciseType: 'comprehension' as const }
      case 'conversation':
        return { ...base, scenario: 'general', userMessage: input.userMessage }
      case 'exam-pattern':
        return { ...base, examType: profile.targetExam, action: 'practice' as const }
      case 'difficulty-adjustment':
        return { ...base, currentLevel: profile.currentLevel, performance: { correctRate: 0.7, averageResponseTime: 5000, errorPatterns: [] } }
      case 'lesson-generator':
        return { ...base, topic: input.userMessage, lessonType: 'grammar' as const, durationMinutes: 15 }
      default:
        return base
    }
  }

  private async callAgent<T>(agentName: string, input: unknown): Promise<T> {
    const bindingMap: Record<AgentName, string> = {
      'master-orchestrator': 'MasterOrchestrator',
      'user-profile': 'UserProfile',
      'memory': 'Memory',
      'curriculum-planner': 'CurriculumPlanner',
      'difficulty-adjustment': 'DifficultyAdjustment',
      'motivation': 'Motivation',
      'learning-analytics': 'LearningAnalytics',
      'lesson-generator': 'LessonGenerator',
      'vocabulary': 'Vocabulary',
      'grammar': 'Grammar',
      'conversation': 'Conversation',
      'pronunciation': 'Pronunciation',
      'writing-coach': 'WritingCoach',
      'speaking-coach': 'SpeakingCoach',
      'reading-coach': 'ReadingCoach',
      'listening-coach': 'ListeningCoach',
      'translation': 'Translation',
      'exam-pattern': 'ExamPattern',
      'ai-safety': 'Safety',
      'copyright-compliance': 'CopyrightReviewer',
      'prompt-optimizer': 'PromptOptimizer',
      'quality-reviewer': 'QualityReviewer',
    }

    const bindingName = bindingMap[agentName as AgentName]
    if (!bindingName) {
      throw new Error(`No binding mapping found for agent: ${agentName}`)
    }

    const binding = (this.env as any)[bindingName]
    if (!binding) {
      console.warn(`Durable Object binding "${bindingName}" not found in environment. Simulating fallback.`)
      return {} as T
    }

    const id = binding.idFromName((input as any).userId || 'default-user')
    const stub = binding.get(id)

    // Call execute method if it implements the LearningAgent interface
    if (typeof stub.execute === 'function') {
      return await stub.execute(input)
    }

    // Legacy fallback bindings
    if (agentName === 'user-profile') {
      return await stub.getProfile(input)
    } else if (agentName === 'memory') {
      return await stub.processMemory(input)
    } else if (agentName === 'curriculum-planner') {
      return await stub.createPlan(input)
    } else if (agentName === 'difficulty-adjustment') {
      return await stub.evaluate(input)
    } else if (agentName === 'motivation') {
      return await stub.generateMotivation(input)
    } else if (agentName === 'vocabulary') {
      return await stub.processVocabulary(input)
    } else if (agentName === 'lesson-generator') {
      return await stub.generateLesson(input)
    }

    throw new Error(`No execute method or legacy RPC method matched for agent: ${agentName}`)
  }

  private formatResponse(output: unknown, quality: any): string {
    if (typeof output === 'string') return output
    if (output && typeof output === 'object') {
      const obj = output as Record<string, unknown>
      if (obj.message) return obj.message as string
      if (obj.response) return obj.response as string
      if (obj.content) return obj.content as string
    }
    return JSON.stringify(output)
  }
}

