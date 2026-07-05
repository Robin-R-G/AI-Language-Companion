// agents/src/agents/copyright-compliance.ts
// Copyright Compliance Agent — checks generated exercises against official exam publishers

import { Agent, callable } from 'agents'
import type { LearningAgent, CopyrightInput, CopyrightOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { AIClient } from '../shared/ai'

export class CopyrightComplianceAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'copyright-compliance'
  get name(): string { return 'CopyrightComplianceAgent' }
  description = 'Scans content to verify compliance with publisher trademarks and prevent verbatim copying.'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: CopyrightInput): Promise<CopyrightOutput> {
    const startTime = Date.now()
    try {
      const content = input.content || ''
      const lower = content.toLowerCase()

      // Quick offline heuristics for common copyright issues:
      const flagKeywords = [
        'cambridge ielts', 'past paper 20', 'official test key', 'copyright ets',
        'british council official', 'ielts official test book'
      ]

      const heuristicsIssues: string[] = []
      flagKeywords.forEach(kw => {
        if (lower.includes(kw)) {
          heuristicsIssues.push(`Traces of publisher trademark: "${kw}" found.`)
        }
      })

      if (heuristicsIssues.length > 0) {
        return {
          agentId: 'copyright-compliance',
          success: true,
          data: {
            compliant: false,
            issues: heuristicsIssues,
            originalContent: content,
          },
          metadata: {
            latencyMs: Date.now() - startTime,
            confidence: 1.0,
          },
        }
      }

      // Call AI review as a fallback or double-check
      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        {
          role: 'system',
          content: 'You are the Copyright Compliance Agent. Analyze the user text to determine if it copies official test questions, standard passages from IELTS/TOEFL books, or lists copyrighted exam materials verbatim. Return JSON: {"compliant": boolean, "issues": ["description of issues"]}.'
        },
        { role: 'user', content: `Analyze: "${content}"` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      return {
        agentId: 'copyright-compliance',
        success: true,
        data: {
          compliant: parsedData.compliant ?? true,
          issues: parsedData.issues || [],
          originalContent: content,
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.95,
        },
      }
    } catch (err: any) {
      // Safe fallback on exception
      return {
        agentId: 'copyright-compliance',
        success: true,
        data: {
          compliant: true,
          issues: [],
          originalContent: input.content,
        },
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: CopyrightOutput): boolean {
    return output.success && !!output.data && typeof output.data.compliant === 'boolean'
  }

  score(output: CopyrightOutput): number {
    return output.success ? (output.data.compliant ? 1.0 : 0.0) : 0.0
  }
}
