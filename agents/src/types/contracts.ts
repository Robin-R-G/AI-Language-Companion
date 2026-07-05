// agents/src/types/contracts.ts
// Agent Input/Output contracts for the AI Language Coach multi-agent system

// ─── Common Types ────────────────────────────────────────────────────────────

export type CEFRLanguage = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

export type TargetLanguage = 'English' | 'German' | 'French' | 'Spanish' | 'Japanese' | 'Korean' | 'Chinese'

export type NativeLanguage = 'Malayalam' | 'Hindi' | 'Tamil' | 'Telugu' | 'Kannada' | 'Bengali' | 'Marathi' | 'Gujarati' | 'Punjabi' | 'Urdu'

export type ExamType = 'IELTS' | 'TOEFL' | 'PTE' | 'OET' | 'CELPIP' | 'Cambridge' | 'Goethe' | 'TELC' | 'TestDaF' | 'JLPT' | 'TOPIK' | 'HSK' | 'DELF' | 'DALF' | 'DELE' | 'SIELE' | 'General'

export type AgentName =
  | 'master-orchestrator'
  | 'user-profile'
  | 'memory'
  | 'curriculum-planner'
  | 'lesson-generator'
  | 'vocabulary'
  | 'grammar'
  | 'conversation'
  | 'pronunciation'
  | 'writing-coach'
  | 'speaking-coach'
  | 'reading-coach'
  | 'listening-coach'
  | 'translation'
  | 'exam-pattern'
  | 'difficulty-adjustment'
  | 'motivation'
  | 'learning-analytics'
  | 'ai-safety'
  | 'copyright-compliance'
  | 'prompt-optimizer'
  | 'quality-reviewer'

// ─── Base Agent Types ────────────────────────────────────────────────────────

export interface AgentInput {
  userId: string
  sessionId: string
  timestamp: number
}

export interface AgentOutput {
  agentId: AgentName
  success: boolean
  data: unknown
  errors?: string[]
  metadata?: {
    tokensUsed?: number
    latencyMs?: number
    confidence?: number
  }
}

// ─── User Profile Agent ──────────────────────────────────────────────────────

export interface UserProfileInput extends AgentInput {
  action: 'get' | 'update' | 'initialize'
  updates?: Partial<UserProfile>
}

export interface UserProfile {
  userId: string
  name: string
  nativeLanguage: NativeLanguage
  targetLanguage: TargetLanguage
  currentLevel: CEFRLanguage
  targetExam: ExamType
  learningGoal: string
  weakSkills: string[]
  strongSkills: string[]
  preferredLearningStyle: 'visual' | 'auditory' | 'kinesthetic' | 'reading'
  dailyGoalMinutes: number
  subscription: 'free' | 'premium' | 'premium+'
  createdAt: number
  updatedAt: number
}

export interface UserProfileOutput extends AgentOutput {
  data: UserProfile
}

// ─── Memory Agent ────────────────────────────────────────────────────────────

export interface MemoryInput extends AgentInput {
  action: 'get' | 'add' | 'update' | 'delete' | 'query'
  memoryType?: MemoryType
  data?: unknown
  query?: string
}

export type MemoryType =
  | 'vocabulary_learned'
  | 'grammar_mistakes'
  | 'pronunciation_weaknesses'
  | 'writing_weaknesses'
  | 'speaking_confidence'
  | 'learning_streak'
  | 'lesson_completion'
  | 'error_patterns'
  | 'preferences'

export interface MemoryEntry {
  id: string
  userId: string
  type: MemoryType
  data: unknown
  confidence: number
  createdAt: number
  updatedAt: number
  expiresAt?: number
}

export interface MemoryOutput extends AgentOutput {
  data: MemoryEntry | MemoryEntry[]
}

// ─── Curriculum Planner ──────────────────────────────────────────────────────

export interface CurriculumPlannerInput extends AgentInput {
  action: 'daily' | 'weekly' | 'monthly' | 'exam-roadmap'
  profile: UserProfile
  memories: MemoryEntry[]
}

export interface LearningPlan {
  id: string
  userId: string
  type: 'daily' | 'weekly' | 'monthly' | 'exam-roadmap'
  tasks: LearningTask[]
  estimatedMinutes: number
  difficulty: CEFRLanguage
  createdAt: number
}

export interface LearningTask {
  id: string
  type: 'lesson' | 'practice' | 'review' | 'assessment' | 'challenge'
  agent: AgentName
  description: string
  estimatedMinutes: number
  priority: 'high' | 'medium' | 'low'
  prerequisites?: string[]
}

export interface CurriculumPlannerOutput extends AgentOutput {
  data: LearningPlan
}

// ─── Lesson Generator ────────────────────────────────────────────────────────

export interface LessonGeneratorInput extends AgentInput {
  topic: string
  level: CEFRLanguage
  language: TargetLanguage
  lessonType: 'grammar' | 'vocabulary' | 'reading' | 'listening' | 'writing' | 'speaking'
  durationMinutes: number
  interests?: string[]
}

export interface Lesson {
  id: string
  title: string
  level: CEFRLanguage
  language: TargetLanguage
  type: string
  content: string
  vocabulary: VocabularyItem[]
  exercises: Exercise[]
  estimatedMinutes: number
  learningObjective?: string
  prerequisites?: string[]
  grammarFocus?: string
  speakingTask?: string
  listeningTask?: string
  readingTask?: string
  writingTask?: string
  reviewQuestions?: string[]
}

export interface VocabularyItem {
  word: string
  partOfSpeech: string
  definition: string
  definitionL1?: string
  pronunciation: string
  example: string
  collocations?: string[]
  synonyms?: string[]
  antonyms?: string[]
}

export interface Exercise {
  id: string
  type: 'multiple_choice' | 'fill_blank' | 'short_answer' | 'true_false' | 'matching'
  question: string
  options?: string[]
  correctAnswer: string
  explanation: string
}

export interface LessonGeneratorOutput extends AgentOutput {
  data: Lesson
}

// ─── Vocabulary Agent ────────────────────────────────────────────────────────

export interface VocabularyInput extends AgentInput {
  action: 'generate' | 'review' | 'quiz' | 'collocations' | 'record_feedback'
  words?: string[]
  level: CEFRLanguage
  language: TargetLanguage
  topic?: string
  count?: number
  feedback?: Array<{ word: string; correct: boolean }>
}

export interface VocabularyOutput extends AgentOutput {
  data: VocabularyItem[]
}

// ─── Grammar Agent ───────────────────────────────────────────────────────────

export interface GrammarInput extends AgentInput {
  rule?: string
  sentence?: string
  level: CEFRLanguage
  language: TargetLanguage
  action: 'explain' | 'correct' | 'exercise' | 'common_mistakes'
}

export interface GrammarExplanation {
  rule: string
  explanation: string
  explanationL1?: string
  examples: string[]
  exceptions?: string[]
  commonMistakes: string[]
  practiceExercise: Exercise
}

export interface GrammarOutput extends AgentOutput {
  data: GrammarExplanation
}

// ─── Conversation Agent ──────────────────────────────────────────────────────

export interface ConversationInput extends AgentInput {
  scenario: string
  level: CEFRLanguage
  language: TargetLanguage
  context?: string[]
  userMessage?: string
}

export interface ConversationResponse {
  message: string
  corrections?: Array<{ original: string; corrected: string; explanation: string }>
  vocabulary?: VocabularyItem[]
  encouragement?: string
  followUpQuestion: string
}

export interface ConversationOutput extends AgentOutput {
  data: ConversationResponse
}

// ─── Pronunciation Agent ─────────────────────────────────────────────────────

export interface PronunciationInput extends AgentInput {
  audioText: string
  targetPhonemes?: string[]
  level: CEFRLanguage
  language: TargetLanguage
}

export interface PronunciationEvaluation {
  overallScore: number
  fluencyScore: number
  pronunciationScore: number
  intonationScore: number
  clarityScore: number
  strengths: string[]
  issues: string[]
  practiceWords: string[]
  shadowingExercise: string
}

export interface PronunciationOutput extends AgentOutput {
  data: PronunciationEvaluation
}

// ─── Writing Coach ───────────────────────────────────────────────────────────

export interface WritingCoachInput extends AgentInput {
  text: string
  prompt?: string
  taskType: 'essay' | 'email' | 'report' | 'task1' | 'task2' | 'letter'
  examType?: ExamType
  level: CEFRLanguage
  language: TargetLanguage
}

export interface WritingEvaluation {
  estimatedBand?: string
  estimatedLevel?: CEFRLanguage
  scores: {
    taskAchievement?: number
    coherenceCohesion?: number
    lexicalResource?: number
    grammaticalRange?: number
  }
  strengths: string[]
  mistakes: Array<{ error: string; correction: string; rule: string }>
  improvedVersion: string
  recommendations: string[]
  disclaimer: string
}

export interface WritingCoachOutput extends AgentOutput {
  data: WritingEvaluation
}

// ─── Speaking Coach ──────────────────────────────────────────────────────────

export interface SpeakingCoachInput extends AgentInput {
  transcript: string
  prompt?: string
  examType?: ExamType
  level: CEFRLanguage
  language: TargetLanguage
}

export interface SpeakingEvaluation {
  scores: {
    fluency: number
    grammar: number
    vocabulary: number
    pronunciation: number
    intonation: number
    clarity: number
    overall: number
  }
  estimatedProficiency: string
  strengths: string[]
  improvements: string[]
  practiceWords: string[]
  shadowingExercise: string
}

export interface SpeakingCoachOutput extends AgentOutput {
  data: SpeakingEvaluation
}

// ─── Reading Coach ───────────────────────────────────────────────────────────

export interface ReadingCoachInput extends AgentInput {
  level: CEFRLanguage
  language: TargetLanguage
  topic?: string
  passageLength?: 'short' | 'medium' | 'long'
}

export interface ReadingLesson {
  title: string
  passage: string
  vocabulary: VocabularyItem[]
  questions: Exercise[]
  discussionPrompt: string
  estimatedMinutes: number
}

export interface ReadingCoachOutput extends AgentOutput {
  data: ReadingLesson
}

// ─── Listening Coach ─────────────────────────────────────────────────────────

export interface ListeningCoachInput extends AgentInput {
  level: CEFRLanguage
  language: TargetLanguage
  topic?: string
  exerciseType: 'dictation' | 'gap_fill' | 'comprehension' | 'true_false'
}

export interface ListeningExercise {
  title: string
  script: string
  exercises: Exercise[]
  vocabularyHelp: VocabularyItem[]
  estimatedMinutes: number
}

export interface ListeningCoachOutput extends AgentOutput {
  data: ListeningExercise
}

// ─── Translation Agent ───────────────────────────────────────────────────────

export interface TranslationInput extends AgentInput {
  text: string
  sourceLanguage: TargetLanguage
  targetLanguage: NativeLanguage
  level: CEFRLanguage
  context?: string
}

export interface TranslationOutput extends AgentOutput {
  data: {
    translation: string
    pronunciation: string
    alternatives: { formal: string; informal: string }
    explanation: string
  }
}

// ─── Exam Pattern Agent ──────────────────────────────────────────────────────

export interface ExamPatternInput extends AgentInput {
  examType: ExamType
  action: 'info' | 'practice' | 'strategy' | 'scoring'
  section?: string
  level: CEFRLanguage
  language: TargetLanguage
}

export interface ExamPattern {
  name: string
  sections: string[]
  timing: Record<string, number>
  scoring: Record<string, string>
  strategies: string[]
  practiceMaterial?: unknown
}

export interface ExamPatternOutput extends AgentOutput {
  data: ExamPattern
}

// ─── Difficulty Adjustment Agent ─────────────────────────────────────────────

export interface DifficultyInput extends AgentInput {
  currentLevel: CEFRLanguage
  performance: {
    correctRate: number
    averageResponseTime: number
    errorPatterns: string[]
  }
  language: TargetLanguage
}

export interface DifficultyOutput extends AgentOutput {
  data: {
    recommendedLevel: CEFRLanguage
    adjustment: 'increase' | 'decrease' | 'maintain'
    reason: string
    confidence: number
  }
}

// ─── Motivation Agent ────────────────────────────────────────────────────────

export interface MotivationInput extends AgentInput {
  streak: number
  dailyGoalMet: boolean
  recentAchievements: string[]
  level: CEFRLanguage
  language: TargetLanguage
}

export interface MotivationOutput extends AgentOutput {
  data: {
    message: string
    celebration?: string
    challenge?: string
    streakInfo: { current: number; best: number; reminder: string }
    xpEarned?: number
    totalXp?: number
  }
}

// ─── Learning Analytics Agent ────────────────────────────────────────────────

export interface AnalyticsInput extends AgentInput {
  timeframe: 'daily' | 'weekly' | 'monthly'
  profile: UserProfile
  memories: MemoryEntry[]
}

export interface AnalyticsOutput extends AgentOutput {
  data: {
    summary: string
    weakAreas: string[]
    improvements: string[]
    timeSpent: number
    recommendations: string[]
    examReadiness?: { score: number; feedback: string }
  }
}

// ─── AI Safety Agent ─────────────────────────────────────────────────────────

export interface SafetyInput extends AgentInput {
  content: string
  contentType: 'lesson' | 'exercise' | 'feedback' | 'conversation'
  level: CEFRLanguage
}

export interface SafetyOutput extends AgentOutput {
  data: {
    safe: boolean
    issues: string[]
    adjustedContent?: string
    confidence: number
  }
}

// ─── Copyright Compliance Agent ──────────────────────────────────────────────

export interface CopyrightInput extends AgentInput {
  content: string
  source?: string
}

export interface CopyrightOutput extends AgentOutput {
  data: {
    compliant: boolean
    issues: string[]
    originalContent?: string
  }
}

// ─── Prompt Optimizer ────────────────────────────────────────────────────────

export interface PromptOptimizerInput extends AgentInput {
  prompt: string
  targetModel: string
  optimizeFor: 'cost' | 'quality' | 'balanced'
}

export interface PromptOptimizerOutput extends AgentOutput {
  data: {
    optimizedPrompt: string
    estimatedTokenReduction: number
    qualityImpact: string
  }
}

// ─── Quality Reviewer ────────────────────────────────────────────────────────

export interface QualityInput extends AgentInput {
  content: string
  contentType: string
  level: CEFRLanguage
  language: TargetLanguage
  agent: AgentName
}

export interface QualityOutput extends AgentOutput {
  data: {
    score: number
    dimensions: {
      accuracy: number
      educationalValue: number
      grammar: number
      difficulty: number
      personalization: number
      clarity: number
    }
    issues: string[]
    suggestions: string[]
  }
}

// ─── Orchestrator Types ──────────────────────────────────────────────────────

export interface OrchestratorInput {
  userId: string
  sessionId: string
  userMessage: string
  intent?: string
  context?: Record<string, unknown>
}

export interface OrchestratorOutput {
  response: string
  agentsInvolved: AgentName[]
  metadata: {
    totalTokens: number
    totalLatencyMs: number
    pipeline: string[]
  }
}

// ─── Learning Agent Interface ────────────────────────────────────────────────

export interface LearningAgent {
  id: string
  name: string
  description: string
  priority: number
  supportedLanguages: string[]
  supportedExams: string[]
  execute(input: any): Promise<any>
  validate(output: any): boolean
  score(output: any): number
}

