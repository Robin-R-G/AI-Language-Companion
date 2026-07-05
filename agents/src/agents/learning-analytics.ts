// agents/src/agents/learning-analytics.ts
// Learning Analytics Agent — aggregates user strengths/weaknesses and estimates exam readiness

import { Agent, callable } from 'agents'
import type { LearningAgent, AnalyticsInput, AnalyticsOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { AIClient } from '../shared/ai'
import { getPrompt } from '../shared/prompt-manager'

export class LearningAnalyticsAgent extends Agent<Env, { logs: Record<string, any[]> }> implements LearningAgent {
  initialState = { logs: {} as Record<string, any[]> }

  id = 'learning-analytics'
  get name(): string { return 'LearningAnalytics' }
  description = 'Compiles study session durations, mistake history, and estimates general exam band readiness.'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: AnalyticsInput): Promise<AnalyticsOutput> {
    const startTime = Date.now()
    try {
      const memoriesSummary = input.memories.map(m => `[Type: ${m.type}] Data: ${JSON.stringify(m.data)}`).join('\n')
      const promptData = getPrompt('learning-analytics')

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        {
          role: 'system',
          content: promptData.prompt,
        },
        {
          role: 'user',
          content: `Profile: ${JSON.stringify(input.profile)}. Memories:\n${memoriesSummary}. Timeframe: ${input.timeframe}`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const output: AnalyticsOutput = {
        agentId: 'learning-analytics',
        success: true,
        data: {
          summary: parsedData.summary || 'Summary unavailable.',
          weakAreas: parsedData.weakAreas || [],
          improvements: parsedData.improvements || [],
          timeSpent: parsedData.timeSpent || 0,
          recommendations: parsedData.recommendations || [],
          examReadiness: parsedData.examReadiness || { score: 50, feedback: 'Assessment pending.' },
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.90,
        },
      }

      // Track metric logs
      const userLogs = this.state.logs[input.userId] || []
      this.setState({
        ...this.state,
        logs: {
          ...this.state.logs,
          [input.userId]: [...userLogs, { timestamp: Date.now(), data: output.data }].slice(-30),
        },
      })

      return output
    } catch (err: any) {
      return {
        agentId: 'learning-analytics',
        success: false,
        data: {
          summary: 'Error generating analytics report.',
          weakAreas: [],
          improvements: [],
          timeSpent: 0,
          recommendations: [],
        },
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: AnalyticsOutput): boolean {
    return output.success && !!output.data && typeof output.data.summary === 'string'
  }

  score(output: AnalyticsOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
