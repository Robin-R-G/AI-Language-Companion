// agents/src/index.ts
// Main entry point — routing and agent orchestration

import { routeAgentRequest } from 'agents'
import { MasterOrchestrator } from './orchestrator/master'
import { UserProfileAgent } from './agents/user-profile'
import { MemoryAgent } from './agents/memory'
import { CurriculumPlannerAgent } from './agents/curriculum-planner'
import { DifficultyAdjustmentAgent } from './agents/difficulty-adjustment'
import { MotivationAgent } from './agents/motivation'
import { LearningAnalyticsAgent } from './agents/learning-analytics'
import { LessonGeneratorAgent } from './agents/lesson-generator'
import { VocabularyAgent } from './agents/vocabulary'
import { GrammarAgent } from './agents/grammar'
import { ConversationAgent } from './agents/conversation'
import { PronunciationAgent } from './agents/pronunciation'
import { WritingCoachAgent } from './agents/writing-coach'
import { SpeakingCoachAgent } from './agents/speaking-coach'
import { ReadingCoachAgent } from './agents/reading-coach'
import { ListeningCoachAgent } from './agents/listening-coach'
import { TranslationAgent } from './agents/translation'
import { ExamPatternAgent } from './agents/exam-pattern'
import { AISafetyAgent } from './agents/ai-safety'
import { CopyrightComplianceAgent } from './agents/copyright-compliance'
import { PromptOptimizerAgent } from './agents/prompt-optimizer'
import { QualityReviewerAgent } from './agents/quality-reviewer'
import { RequestPipeline } from './workflows/request-pipeline'

// Re-export all agents for wrangler.jsonc bindings
export {
  MasterOrchestrator,
  UserProfileAgent,
  MemoryAgent,
  CurriculumPlannerAgent,
  DifficultyAdjustmentAgent,
  MotivationAgent,
  LearningAnalyticsAgent,
  LessonGeneratorAgent,
  VocabularyAgent,
  GrammarAgent,
  ConversationAgent,
  PronunciationAgent,
  WritingCoachAgent,
  SpeakingCoachAgent,
  ReadingCoachAgent,
  ListeningCoachAgent,
  TranslationAgent,
  ExamPatternAgent,
  AISafetyAgent,
  CopyrightComplianceAgent,
  PromptOptimizerAgent,
  QualityReviewerAgent,
  RequestPipeline,
}

// Agent class map for routing
const AGENT_MAP: Record<string, new (...args: any[]) => any> = {
  'master-orchestrator': MasterOrchestrator,
  'user-profile': UserProfileAgent,
  'memory': MemoryAgent,
  'curriculum-planner': CurriculumPlannerAgent,
  'difficulty-adjustment': DifficultyAdjustmentAgent,
  'motivation': MotivationAgent,
  'learning-analytics': LearningAnalyticsAgent,
  'lesson-generator': LessonGeneratorAgent,
  'vocabulary': VocabularyAgent,
  'grammar': GrammarAgent,
  'conversation': ConversationAgent,
  'pronunciation': PronunciationAgent,
  'writing-coach': WritingCoachAgent,
  'speaking-coach': SpeakingCoachAgent,
  'reading-coach': ReadingCoachAgent,
  'listening-coach': ListeningCoachAgent,
  'translation': TranslationAgent,
  'exam-pattern': ExamPatternAgent,
  'ai-safety': AISafetyAgent,
  'copyright-compliance': CopyrightComplianceAgent,
  'prompt-optimizer': PromptOptimizerAgent,
  'quality-reviewer': QualityReviewerAgent,
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Try routing to an agent
    const agentResponse = await routeAgentRequest(request, env)
    if (agentResponse) return agentResponse

    // Handle direct API calls
    const url = new URL(request.url)

    // Health check
    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ status: 'ok', agents: Object.keys(AGENT_MAP) }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // API endpoint for processing requests
    if (url.pathname === '/api/process' && request.method === 'POST') {
      try {
        const body = await request.json() as { userId: string; sessionId: string; message: string }
        return new Response(JSON.stringify({
          status: 'processing',
          message: 'Request received',
          userId: body.userId,
        }), {
          headers: { 'Content-Type': 'application/json' },
        })
      } catch (error) {
        return new Response(JSON.stringify({ error: 'Invalid request body' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        })
      }
    }

    // List available agents
    if (url.pathname === '/api/agents') {
      return new Response(JSON.stringify({
        agents: Object.entries(AGENT_MAP).map(([name, cls]) => ({
          name,
          class: cls.name,
          type: name.includes('lesson') || name.includes('vocabulary') || name.includes('grammar')
            ? 'stateless'
            : 'stateful',
        })),
      }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    return new Response('AI Language Coach Agents — Multi-Agent System', {
      headers: { 'Content-Type': 'text/plain' },
    })
  },
}
