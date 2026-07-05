// agents/src/agents/prompt-optimizer.ts
// Prompt Optimizer Agent — optimizes prompts dynamically depending on target models

import { Agent, callable } from 'agents'
import type { LearningAgent, PromptOptimizerInput, PromptOptimizerOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { AIClient } from '../shared/ai'

export class PromptOptimizerAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'prompt-optimizer'
  get name(): string { return 'PromptOptimizer' }
  description = 'Reviews and optimizes system/user prompts for performance, token reduction, and model alignment.'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: PromptOptimizerInput): Promise<PromptOptimizerOutput> {
    const startTime = Date.now()
    try {
      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        {
          role: 'system',
          content: 'You are the Prompt Optimizer. Your task is to shorten and refine prompts to make them token-efficient and clear, optimizing specifically for: ' + input.optimizeFor + '. Return JSON: {"optimizedPrompt": "...", "estimatedTokenReduction": number, "qualityImpact": "..."}'
        },
        { role: 'user', content: `Optimize this prompt: "${input.prompt}"` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      return {
        agentId: 'prompt-optimizer',
        success: true,
        data: {
          optimizedPrompt: parsedData.optimizedPrompt || input.prompt,
          estimatedTokenReduction: parsedData.estimatedTokenReduction || 0,
          qualityImpact: parsedData.qualityImpact || 'Neutral',
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.90,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'prompt-optimizer',
        success: false,
        data: {
          optimizedPrompt: input.prompt,
          estimatedTokenReduction: 0,
          qualityImpact: 'None',
        },
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: PromptOptimizerOutput): boolean {
    return output.success && !!output.data && typeof output.data.optimizedPrompt === 'string'
  }

  score(output: PromptOptimizerOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
