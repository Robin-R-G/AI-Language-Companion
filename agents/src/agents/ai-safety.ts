// agents/src/agents/ai-safety.ts
// AI Safety Agent — scans user messages and system outputs for injection or harmful content

import { Agent, callable } from 'agents'
import type { LearningAgent, SafetyInput, SafetyOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class AISafetyAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'ai-safety'
  get name(): string { return 'AISafetyAgent' }
  description = 'Examines prompts and responses to ensure content safety and block system overrides.'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: SafetyInput): Promise<SafetyOutput> {
    const startTime = Date.now()
    try {
      const content = input.content || ''
      const promptData = getPrompt('ai-safety', {
        content_type: input.contentType,
        learning_level: input.level,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Verify this content: "${content}"`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      return {
        agentId: 'ai-safety',
        success: true,
        data: {
          safe: parsedData.safe ?? true,
          issues: parsedData.issues || [],
          adjustedContent: parsedData.adjustedContent || content,
          confidence: parsedData.confidence ?? 1.0,
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: parsedData.confidence ?? 1.0,
        },
      }
    } catch (err: any) {
      // Safe fallback on error to not block session unless critical
      return {
        agentId: 'ai-safety',
        success: true,
        data: {
          safe: true,
          issues: [],
          adjustedContent: input.content,
          confidence: 0.5,
        },
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: SafetyOutput): boolean {
    return output.success && !!output.data && typeof output.data.safe === 'boolean'
  }

  score(output: SafetyOutput): number {
    return output.success ? (output.data.confidence || 1.0) : 0.0
  }
}
