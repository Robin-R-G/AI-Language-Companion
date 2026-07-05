// agents/src/agents/exam-pattern.ts
// Exam Pattern Agent — designs practice items matching exam format without copyright infringements

import { Agent, callable } from 'agents'
import type { LearningAgent, ExamPatternInput, ExamPatternOutput, ExamPattern } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class ExamPatternAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'exam-pattern'
  get name(): string { return 'ExamPatternAgent' }
  description = 'Prepares learners for language proficiency exams (IELTS, TOEFL, PTE, Goethe) with strategy and mock tests.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'TOEIC', 'CELPIP', 'TestDaF', 'TELC', 'DELF', 'DALF', 'DELE', 'SIELE', 'JLPT', 'TOPIK', 'HSK', 'General']

  @callable()
  async execute(input: ExamPatternInput): Promise<ExamPatternOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('exam-pattern', {
        target_exam: input.examType,
        learning_level: input.level,
        target_language: input.language,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Deliver exam preparation content for exam: "${input.examType}". Action requested: "${input.action}"${input.section ? `, section: "${input.section}"` : ''}.`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const data: ExamPattern = {
        name: parsedData.name || input.examType,
        sections: parsedData.sections || [],
        timing: parsedData.timing || {},
        scoring: parsedData.scoring || {},
        strategies: parsedData.strategies || [],
        practiceMaterial: parsedData.practiceMaterial || null,
      }

      return {
        agentId: 'exam-pattern',
        success: true,
        data,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.95,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'exam-pattern',
        success: false,
        data: {} as ExamPattern,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: ExamPatternOutput): boolean {
    return output.success && !!output.data && typeof output.data.name === 'string'
  }

  score(output: ExamPatternOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
