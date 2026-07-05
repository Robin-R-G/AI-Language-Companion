// agents/src/agents/conversation.ts
// Conversation Coach Agent — manages friendly dialog and gives contextual corrections

import { Agent, callable } from 'agents'
import type { LearningAgent, ConversationInput, ConversationOutput, ConversationResponse } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class ConversationAgent extends Agent<Env, { sessions: Record<string, string[]> }> implements LearningAgent {
  initialState = { sessions: {} as Record<string, string[]> }

  id = 'conversation'
  get name(): string { return 'ConversationAgent' }
  description = 'Engages learners in interactive conversations with inline corrections and helpful hints.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: ConversationInput): Promise<ConversationOutput> {
    const startTime = Date.now()
    try {
      const userMsg = input.userMessage || ''
      const promptData = getPrompt('conversation', {
        target_language: input.language,
        learning_level: input.level,
        scenario: input.scenario,
      })

      const sessionHistory = this.state.sessions[input.sessionId] || []
      const messagesForAi = [
        { role: 'system' as const, content: promptData.prompt },
        ...sessionHistory.map((msg, idx) => ({
          role: idx % 2 === 0 ? ('user' as const) : ('assistant' as const),
          content: msg,
        })),
        { role: 'user' as const, content: userMsg },
      ].slice(-10) // Keep context window within last 10 messages for cost efficiency

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback(messagesForAi)

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData: ConversationResponse = JSON.parse(cleanedContent)

      // Update session history
      const updatedHistory = [...sessionHistory, userMsg, parsedData.message].slice(-40)
      this.setState({
        ...this.state,
        sessions: {
          ...this.state.sessions,
          [input.sessionId]: updatedHistory,
        },
      })

      return {
        agentId: 'conversation',
        success: true,
        data: parsedData,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.95,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'conversation',
        success: false,
        data: {} as ConversationResponse,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: ConversationOutput): boolean {
    return output.success && !!output.data && typeof output.data.message === 'string'
  }

  score(output: ConversationOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
