// agents/src/agents/vocabulary.ts
// Vocabulary Agent — word generation, collocations, SRS scheduling

import { Agent, callable } from 'agents'
import type { LearningAgent, VocabularyInput, VocabularyItem, VocabularyOutput } from '../types/contracts'

const SRS_INTERVALS_DAYS = [0, 1, 3, 7, 14, 30, 60, 90]

export class VocabularyAgent extends Agent<Env, { srsQueue: Record<string, Array<{ word: string; nextReview: number; intervalIndex: number; lastReview?: number }>> }> implements LearningAgent {
  initialState = { srsQueue: {} as Record<string, Array<{ word: string; nextReview: number; intervalIndex: number; lastReview?: number }>> }

  id = 'vocabulary'
  get name(): string { return 'VocabularyAgent' }
  description = 'SRS vocab trainer and collocation builder'
  priority = 2
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: VocabularyInput): Promise<VocabularyOutput> {
    return this.processVocabulary(input)
  }

  validate(output: VocabularyOutput): boolean {
    return output.success && !!output.data && output.data.length > 0
  }

  score(output: VocabularyOutput): number {
    return output.success ? 1.0 : 0.0
  }

  @callable()
  async processVocabulary(input: VocabularyInput): Promise<VocabularyOutput> {
    switch (input.action) {
      case 'generate':
        return this.generateWords(input)
      case 'review':
        return this.getReviewWords(input)
      case 'quiz':
        return this.generateQuizWords(input)
      case 'collocations':
        return this.generateCollocations(input)
      case 'record_feedback':
        return this.recordFeedback(input)
      default:
        return { agentId: 'vocabulary', success: false, data: [], errors: ['Unknown action'] }
    }
  }

  private generateWords(input: VocabularyInput): VocabularyOutput {
    const count = input.count || 5
    const words: VocabularyItem[] = []

    const wordBank: Record<string, VocabularyItem[]> = {
      A1: [
        { word: 'water', partOfSpeech: 'noun', definition: 'A clear liquid', pronunciation: '/ˈwɔːtər/', example: 'I drink water every day.' },
        { word: 'eat', partOfSpeech: 'verb', definition: 'To consume food', pronunciation: '/iːt/', example: 'I eat breakfast at 7 AM.' },
        { word: 'big', partOfSpeech: 'adjective', definition: 'Large in size', pronunciation: '/bɪɡ/', example: 'The house is very big.' },
        { word: 'small', partOfSpeech: 'adjective', definition: 'Little in size', pronunciation: '/smɔːl/', example: 'The cat is small.' },
        { word: 'go', partOfSpeech: 'verb', definition: 'To move', pronunciation: '/ɡoʊ/', example: 'I go to school every day.' },
      ],
      A2: [
        { word: 'decide', partOfSpeech: 'verb', definition: 'To make a choice', pronunciation: '/dɪˈsaɪd/', example: 'I decided to study harder.' },
        { word: 'important', partOfSpeech: 'adjective', definition: 'Having great value', pronunciation: '/ɪmˈpɔːrtənt/', example: 'This is very important.' },
        { word: 'enjoy', partOfSpeech: 'verb', definition: 'To take pleasure in', pronunciation: '/ɪnˈdʒɔɪ/', example: 'I enjoy reading books.' },
        { word: 'difficult', partOfSpeech: 'adjective', definition: 'Not easy', pronunciation: '/ˈdɪfɪkəlt/', example: 'The test was difficult.' },
        { word: 'beautiful', partOfSpeech: 'adjective', definition: 'Very attractive', pronunciation: '/ˈbjuːtɪfəl/', example: 'The sunset is beautiful.' },
      ],
      B1: [
        { word: 'achieve', partOfSpeech: 'verb', definition: 'To reach a goal', pronunciation: '/əˈtʃiːv/', example: 'She achieved her dream.' },
        { word: 'significant', partOfSpeech: 'adjective', definition: 'Important or notable', pronunciation: '/sɪɡˈnɪfɪkənt/', example: 'This is a significant discovery.' },
        { word: 'contribute', partOfSpeech: 'verb', definition: 'To give something to help', pronunciation: '/kənˈtrɪbjuːt/', example: 'I contributed to the project.' },
        { word: 'opportunity', partOfSpeech: 'noun', definition: 'A chance to do something', pronunciation: '/ˌɑːpərˈtuːnɪti/', example: 'This is a great opportunity.' },
        { word: 'experience', partOfSpeech: 'noun', definition: 'Knowledge from doing things', pronunciation: '/ɪkˈspɪriəns/', example: 'She has lots of experience.' },
      ],
      B2: [
        { word: 'ubiquitous', partOfSpeech: 'adjective', definition: 'Present everywhere', pronunciation: '/juːˈbɪkwɪtəs/', example: 'Smartphones are ubiquitous.' },
        { word: 'paradigm', partOfSpeech: 'noun', definition: 'A typical example or pattern', pronunciation: '/ˈpærədaɪm/', example: 'This is a paradigm shift.' },
        { word: 'mitigate', partOfSpeech: 'verb', definition: 'To make less severe', pronunciation: '/ˈmɪtɪɡeɪt/', example: 'Steps were taken to mitigate the damage.' },
        { word: 'nuanced', partOfSpeech: 'adjective', definition: 'Subtle and detailed', pronunciation: '/ˈnuːɑːnst/', example: 'This requires a nuanced approach.' },
        { word: 'resilient', partOfSpeech: 'adjective', definition: 'Able to recover quickly', pronunciation: '/rɪˈzɪliənt/', example: 'Children are very resilient.' },
      ],
      C1: [
        { word: 'juxtapose', partOfSpeech: 'verb', definition: 'To place side by side', pronunciation: '/ˌdʒʌkstəˈpoʊz/', example: 'The artist juxtaposed old and new.' },
        { word: 'ephemeral', partOfSpeech: 'adjective', definition: 'Lasting a very short time', pronunciation: '/ɪˈfemərəl/', example: 'The beauty is ephemeral.' },
        { word: 'perspicacious', partOfSpeech: 'adjective', definition: 'Having keen insight', pronunciation: '/ˌpɜːrspɪˈkeɪʃəs/', example: 'A perspicacious observer.' },
        { word: 'ameliorate', partOfSpeech: 'verb', definition: 'To make something bad better', pronunciation: '/əˈmiːliəreɪt/', example: 'Steps to ameliorate the situation.' },
        { word: 'sycophant', partOfSpeech: 'noun', definition: 'A person who flatters', pronunciation: '/ˈsɪkəfænt/', example: 'He is just a sycophant.' },
      ],
      C2: [
        { word: 'obsequious', partOfSpeech: 'adjective', definition: 'Excessively compliant', pronunciation: '/əbˈsiːkwiəs/', example: 'His obsequious behavior was annoying.' },
        { word: 'perfunctory', partOfSpeech: 'adjective', definition: 'Done without care', pronunciation: '/pərˈfʌŋktəri/', example: 'He gave a perfunctory nod.' },
        { word: 'magnanimous', partOfSpeech: 'adjective', definition: 'Very generous or forgiving', pronunciation: '/mæɡˈnænɪməs/', example: 'The magnanimous gesture感动了所有人。' },
        { word: 'capricious', partOfSpeech: 'adjective', definition: 'Given to sudden changes', pronunciation: '/kəˈprɪʃəs/', example: 'The weather is capricious.' },
        { word: 'idiosyncratic', partOfSpeech: 'adjective', definition: 'Distinctive or peculiar', pronunciation: '/ˌɪdioʊsɪŋˈkrætɪk/', example: 'His idiosyncratic style sets him apart.' },
      ],
    }

    const levelWords = wordBank[input.level] || wordBank['A1']
    for (let i = 0; i < Math.min(count, levelWords.length); i++) {
      words.push(levelWords[i])
    }

    // Add to SRS queue
    const userQueue = this.state.srsQueue[input.userId] || []
    const newWords = words.filter(w => !userQueue.some(item => item.word.toLowerCase() === w.word.toLowerCase()))
    const newQueue = [
      ...userQueue,
      ...newWords.map(w => ({
        word: w.word,
        nextReview: Date.now() + 24 * 60 * 60 * 1000, // Day 1
        intervalIndex: 1,
        lastReview: Date.now(),
      })),
    ]
    this.setState({ ...this.state, srsQueue: { ...this.state.srsQueue, [input.userId]: newQueue } })

    return { agentId: 'vocabulary', success: true, data: words }
  }

  private getReviewWords(input: VocabularyInput): VocabularyOutput {
    const userQueue = this.state.srsQueue[input.userId] || []
    const now = Date.now()
    const dueWords = userQueue.filter(w => w.nextReview <= now).slice(0, 10)

    // In production, fetch word details from database
    const words: VocabularyItem[] = dueWords.map(w => {
      // Calculate predicted retention score using forgetting curve formula
      const timeElapsedMs = now - (w.lastReview || now)
      const intervalDays = SRS_INTERVALS_DAYS[w.intervalIndex]
      const strengthMs = (intervalDays || 0.16) * 24 * 60 * 60 * 1000
      const predictedRetention = Math.exp(-timeElapsedMs / strengthMs)

      return {
        word: w.word,
        partOfSpeech: 'noun',
        definition: `Review: ${w.word} (Estimated retention: ${(predictedRetention * 100).toFixed(0)}%)`,
        pronunciation: '',
        example: `Practice using "${w.word}" in a sentence.`,
      }
    })

    return { agentId: 'vocabulary', success: true, data: words }
  }

  private recordFeedback(input: VocabularyInput): VocabularyOutput {
    if (!input.feedback || input.feedback.length === 0) {
      return { agentId: 'vocabulary', success: false, data: [], errors: ['No feedback provided'] }
    }

    const userQueue = this.state.srsQueue[input.userId] || []
    const updatedQueue = [...userQueue]

    for (const feed of input.feedback) {
      const idx = updatedQueue.findIndex(item => item.word.toLowerCase() === feed.word.toLowerCase())
      if (idx !== -1) {
        const item = updatedQueue[idx]
        const currentIdx = item.intervalIndex !== undefined ? item.intervalIndex : 0
        const nextIndex = feed.correct
          ? Math.min(currentIdx + 1, SRS_INTERVALS_DAYS.length - 1)
          : Math.max(currentIdx - 1, 0)
        
        const nextIntervalDays = SRS_INTERVALS_DAYS[nextIndex]
        const delayMs = nextIntervalDays === 0 ? 4 * 60 * 60 * 1000 : nextIntervalDays * 24 * 60 * 60 * 1000
        
        updatedQueue[idx] = {
          word: item.word,
          nextReview: Date.now() + delayMs,
          intervalIndex: nextIndex,
          lastReview: Date.now(),
        }
      } else {
        const nextIndex = feed.correct ? 1 : 0
        const nextIntervalDays = SRS_INTERVALS_DAYS[nextIndex]
        const delayMs = nextIntervalDays === 0 ? 4 * 60 * 60 * 1000 : nextIntervalDays * 24 * 60 * 60 * 1000
        updatedQueue.push({
          word: feed.word,
          nextReview: Date.now() + delayMs,
          intervalIndex: nextIndex,
          lastReview: Date.now(),
        })
      }
    }

    this.setState({
      ...this.state,
      srsQueue: {
        ...this.state.srsQueue,
        [input.userId]: updatedQueue,
      },
    })

    return { agentId: 'vocabulary', success: true, data: [] }
  }

  private generateQuizWords(input: VocabularyInput): VocabularyOutput {
    const words: VocabularyItem[] = [
      { word: 'select', partOfSpeech: 'verb', definition: 'To choose', pronunciation: '/sɪˈlekt/', example: 'Please select the correct answer.' },
    ]
    return { agentId: 'vocabulary', success: true, data: words }
  }

  private generateCollocations(input: VocabularyInput): VocabularyOutput {
    const words: VocabularyItem[] = [
      {
        word: 'make a decision',
        partOfSpeech: 'phrase',
        definition: 'To decide something',
        pronunciation: '/meɪk ə dɪˈsɪʒən/',
        example: 'I need to make a decision quickly.',
        collocations: ['make a decision', 'reach a decision', 'come to a decision'],
      },
    ]
    return { agentId: 'vocabulary', success: true, data: words }
  }
}
