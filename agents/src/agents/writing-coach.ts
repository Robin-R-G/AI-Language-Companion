// agents/src/agents/writing-coach.ts
// Writing Coach Agent — evaluates essay submissions against official rubrics

import { Agent, callable } from 'agents'
import type { LearningAgent, WritingCoachInput, WritingCoachOutput, WritingEvaluation } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class WritingCoachAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'writing-coach'
  get name(): string { return 'WritingCoach' }
  description = 'Evaluates written text submissions against exam rubrics and CEFR standards.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: WritingCoachInput): Promise<WritingCoachOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('writing-coach', {
        target_language: input.language,
        learning_level: input.level,
        target_exam: input.examType || 'General',
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Grade this text: "${input.text}" for the task type "${input.taskType}"${input.prompt ? ` in response to prompt: "${input.prompt}"` : ''}.`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      // Map dynamic scores or properties
      const data: WritingEvaluation = {
        estimatedBand: parsedData.estimated_band || 'N/A',
        estimatedLevel: parsedData.estimated_level || input.level,
        scores: {
          taskAchievement: parsedData.grammar_score || 0,
          coherenceCohesion: parsedData.organization_score || 0,
          lexicalResource: parsedData.vocabulary_score || 0,
          grammaticalRange: parsedData.clarity_score || 0,
        },
        strengths: parsedData.strengths || [],
        mistakes: parsedData.mistakes?.map((m: any) => ({
          error: typeof m === 'string' ? m : m.error || '',
          correction: m.correction || '',
          rule: m.rule || '',
        })) || [],
        improvedVersion: parsedData.improved_version || '',
        recommendations: parsedData.recommendations || [],
        disclaimer: 'This is an advisory AI grade estimate and does not guarantee official exam outcomes.',
      }

      return {
        agentId: 'writing-coach',
        success: true,
        data,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.90,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'writing-coach',
        success: false,
        data: {} as WritingEvaluation,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: WritingCoachOutput): boolean {
    return output.success && !!output.data && !!output.data.improvedVersion
  }

  score(output: WritingCoachOutput): number {
    if (!output.success || !output.data.scores) return 0.0
    const scores = output.data.scores
    const avg = ((scores.taskAchievement || 0) + (scores.coherenceCohesion || 0) + (scores.lexicalResource || 0) + (scores.grammaticalRange || 0)) / 4
    return avg / 100
  }
}
