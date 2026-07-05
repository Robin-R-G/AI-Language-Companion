// agents/src/agents/lesson-generator.ts
// Lesson Generator Agent — creates educational content

import { Agent, callable } from 'agents'
import type { LearningAgent, LessonGeneratorInput, Lesson, LessonGeneratorOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class LessonGeneratorAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'lesson-generator'
  get name(): string { return 'LessonGeneratorAgent' }
  description = 'Creates custom educational lessons'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: LessonGeneratorInput): Promise<LessonGeneratorOutput> {
    return this.generateLesson(input)
  }

  validate(output: LessonGeneratorOutput): boolean {
    return output.success && !!output.data && !!output.data.content
  }

  score(output: LessonGeneratorOutput): number {
    return output.success ? 1.0 : 0.0
  }

  @callable()
  async generateLesson(input: LessonGeneratorInput): Promise<LessonGeneratorOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('lesson', {
        topic: input.topic,
        learning_level: input.level,
        target_language: input.language,
        lesson_type: input.lessonType,
        duration: input.durationMinutes.toString(),
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        { role: 'user', content: `Generate the lesson JSON for: topic="${input.topic}", level="${input.level}".` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const lesson: Lesson = {
        id: `lesson-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
        title: parsedData.title || `${input.level} Lesson: ${input.topic}`,
        level: input.level,
        language: input.language,
        type: input.lessonType,
        content: parsedData.content || '',
        vocabulary: parsedData.vocabulary || [],
        exercises: parsedData.exercises || [],
        estimatedMinutes: input.durationMinutes,
        learningObjective: parsedData.learningObjective,
        prerequisites: parsedData.prerequisites || [],
        grammarFocus: parsedData.grammarFocus,
        speakingTask: parsedData.speakingTask,
        listeningTask: parsedData.listeningTask,
        readingTask: parsedData.readingTask,
        writingTask: parsedData.writingTask,
        reviewQuestions: parsedData.reviewQuestions || [],
      }

      return {
        agentId: 'lesson-generator',
        success: true,
        data: lesson,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 1.0,
        },
      }
    } catch (err: any) {
      // Pedagogical Fallback if API fails or parsing errors out
      const lesson: Lesson = {
        id: `lesson-${Date.now()}-fallback`,
        title: `Standard ${input.level} Lesson: ${input.topic}`,
        level: input.level,
        language: input.language,
        type: input.lessonType,
        content: `Welcome to this ${input.level} lesson on ${input.topic}. [Pedagogical fallback due to offline API or parse issue: ${err.message}]`,
        vocabulary: [
          {
            word: 'structure',
            partOfSpeech: 'noun',
            definition: 'The arrangement of parts',
            pronunciation: '/ˈstrʌktʃər/',
            example: 'The structure of the lesson is clean.',
          },
        ],
        exercises: [
          {
            id: `ex-fb-1`,
            type: 'short_answer',
            question: `Explain what you want to learn about ${input.topic}.`,
            correctAnswer: 'study',
            explanation: 'Allows learner tracking.',
          },
        ],
        estimatedMinutes: input.durationMinutes,
        learningObjective: `Understand the fundamentals of ${input.topic} at ${input.level} level.`,
        prerequisites: ['Basic language structure'],
        grammarFocus: 'Introductory sentence structure',
        speakingTask: 'Speak about why you are studying this lesson.',
        listeningTask: 'Listen and repeat the main key points.',
        readingTask: 'Read this short passage explaining the core topic.',
        writingTask: 'Write 3 sentences about the lesson.',
        reviewQuestions: ['What did you learn today?'],
      }

      return {
        agentId: 'lesson-generator',
        success: true,
        data: lesson,
        metadata: {
          latencyMs: Date.now() - startTime,
          confidence: 0.5,
        },
      }
    }
  }
}
