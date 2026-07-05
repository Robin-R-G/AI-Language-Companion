// supabase/functions/shared/learning-engine/types.ts
export type CEFRLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

export type ExamType =
  | 'KSEEB_10TH'
  | 'KSEEB_12TH'
  | 'PU_11TH'
  | 'PU_12TH'
  | 'CBSE_10TH'
  | 'CBSE_12TH'
  | 'NEET'
  | 'JEE_MAIN'
  | 'JEE_ADVANCED'
  | 'UPSC_CSE_PRELIMS'
  | 'UPSC_CSE_MAINS'
  | 'STATE_PSC'
  | 'CAT'
  | 'GATE'
  | 'TOEFL'
  | 'IELTS'

export type SkillType =
  | 'grammar'
  | 'vocabulary'
  | 'speaking'
  | 'writing'
  | 'reading'
  | 'listening'
  | 'pronunciation'
  | 'translation'

export interface UserProfile {
  id: string
  fullName: string
  nativeLanguage: string
  targetLanguage: string
  proficiencyLevel: CEFRLevel
  targetExam?: ExamType
  learningGoal?: string
  dailyGoalMinutes: number
  createdAt: string
}

export interface LearningProgress {
  userId: string
  xp: number
  level: number
  streak: number
  totalLessonsCompleted: number
  vocabularyLearned: number
  speakingMinutes: number
  grammarScore: number
  speakingScore: number
  writingScore: number
  vocabularyScore: number
  readingScore: number
  listeningScore: number
  pronunciationScore: number
}

export interface Lesson {
  id: string
  type: SkillType
  title: string
  level: CEFRLevel
  topic: string
  xpReward: number
  estimatedMinutes: number
  content: LessonContent
}

export interface LessonContent {
  introduction?: string
  explanation?: string
  examples?: string[]
  practice?: PracticeItem[]
  vocabulary?: VocabularyItem[]
  exercises?: Exercise[]
}

export interface PracticeItem {
  prompt: string
  correctAnswer: string
  hint?: string
}

export interface VocabularyItem {
  word: string
  definition: string
  pronunciation?: string
  example?: string
  synonyms?: string[]
  antonyms?: string[]
}

export interface Exercise {
  question: string
  options?: string[]
  correctAnswer: string
  explanation?: string
  type: 'multiple_choice' | 'fill_blank' | 'translate' | 'listen_type'
}

export interface Flashcard {
  id: string
  userId: string
  word: string
  definition: string
  example?: string
  pronunciation?: string
  easeFactor: number
  interval: number
  repetitions: number
  nextReview: string
  lastReviewed?: string
  createdAt: string
}

export interface SRSResponse {
  flashcardId: string
  quality: number // 0-5 (0=forgot, 5=perfect)
  easeFactor: number
  interval: number
  nextReview: string
}

export interface StudyPlan {
  userId: string
  date: string
  activities: StudyActivity[]
  estimatedMinutes: number
  focusArea: SkillType
  xpGoal: number
}

export interface StudyActivity {
  type: SkillType
  title: string
  description: string
  estimatedMinutes: number
  xpReward: number
  difficulty: CEFRLevel
  completed: boolean
}
