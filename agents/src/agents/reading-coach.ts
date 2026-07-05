// agents/src/agents/reading-coach.ts
// Reading Coach Agent — designs reading comprehension lessons matching learner level

import { Agent, callable } from 'agents'
import type { LearningAgent, ReadingCoachInput, ReadingCoachOutput, ReadingLesson } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class ReadingCoachAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'reading-coach'
  get name(): string { return 'ReadingCoach' }
  description = 'Generates custom CEFR-appropriate reading passages and comprehension quizzes.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: ReadingCoachInput): Promise<ReadingCoachOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('reading-coach', {
        target_language: input.language,
        learning_level: input.level,
        topic: input.topic || 'General learning',
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Generate a ${input.passageLength || 'medium'} reading passage about: "${input.topic || 'General learning'}".`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const data: ReadingLesson = {
        title: parsedData.title || 'Graded Reading Lesson',
        passage: parsedData.passage || '',
        vocabulary: parsedData.vocabulary || [],
        questions: parsedData.questions || [],
        discussionPrompt: parsedData.discussionPrompt || 'What are your thoughts on this topic?',
        estimatedMinutes: parsedData.estimatedMinutes || 10,
      }

      return {
        agentId: 'reading-coach',
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
        agentId: 'reading-coach',
        success: false,
        data: {} as ReadingLesson,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: ReadingCoachOutput): boolean {
    return output.success && !!output.data && !!output.data.passage
  }

  score(output: ReadingCoachOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
