// agents/src/agents/grammar.ts
// Grammar Coach Agent — evaluates sentences for correctness, prepositions, verb conjugations

import { Agent, callable } from 'agents'
import type { LearningAgent, GrammarInput, GrammarOutput, GrammarExplanation } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class GrammarAgent extends Agent<Env, { history: Record<string, any[]> }> implements LearningAgent {
  initialState = { history: {} as Record<string, any[]> }

  id = 'grammar'
  get name(): string { return 'GrammarAgent' }
  description = 'Evaluates sentence structures, prepositions, verb conjugations and returns corrections and rules.'
  priority = 2
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: GrammarInput): Promise<GrammarOutput> {
    const startTime = Date.now()
    try {
      const sentence = input.sentence || ''
      const promptData = getPrompt('grammar', {
        target_language: input.language,
        native_language: 'Malayalam', // default scaffolding L1
        learning_level: input.level,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        { role: 'user', content: `Analyze this sentence: "${sentence}". If action is "${input.action}", focus on that.` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      // Map response to GrammarExplanation interface
      const data: GrammarExplanation = {
        rule: parsedData.category || 'General Grammar Rule',
        explanation: parsedData.explanation || 'No explanation provided.',
        explanationL1: parsedData.explanation_malayalam || '',
        examples: parsedData.examples || [],
        exceptions: [],
        commonMistakes: [],
        practiceExercise: {
          id: `ex-${Date.now()}`,
          type: 'short_answer',
          question: `Practice rewriting or responding to: "${sentence}" using the rule of ${parsedData.category}`,
          correctAnswer: parsedData.corrected || '',
          explanation: parsedData.explanation || '',
        },
      }

      const output: GrammarOutput = {
        agentId: 'grammar',
        success: true,
        data,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: parsedData.is_correct ? 1.0 : 0.8,
        },
      }

      // Track history in Durable Object state
      const userHistory = this.state.history[input.userId] || []
      this.setState({
        ...this.state,
        history: {
          ...this.state.history,
          [input.userId]: [...userHistory, { sentence, success: true, timestamp: Date.now() }].slice(-50),
        },
      })

      return output
    } catch (err: any) {
      return {
        agentId: 'grammar',
        success: false,
        data: {} as GrammarExplanation,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: GrammarOutput): boolean {
    return output.success && !!output.data && typeof output.data.rule === 'string'
  }

  score(output: GrammarOutput): number {
    return output.success ? (output.metadata?.confidence || 1.0) : 0.0
  }
}
