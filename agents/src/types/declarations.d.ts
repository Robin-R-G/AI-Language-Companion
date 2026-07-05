// agents/src/types/declarations.d.ts
// Global and module type overrides for AI Language Coach agents

declare global {
  interface Env {
    // Durable Objects bindings
    MasterOrchestrator: DurableObjectNamespace
    UserProfile: DurableObjectNamespace
    Memory: DurableObjectNamespace
    CurriculumPlanner: DurableObjectNamespace
    DifficultyAdjustment: DurableObjectNamespace
    Motivation: DurableObjectNamespace
    LearningAnalytics: DurableObjectNamespace
    LessonGenerator: DurableObjectNamespace
    Vocabulary: DurableObjectNamespace
    Grammar: DurableObjectNamespace
    Conversation: DurableObjectNamespace
    Pronunciation: DurableObjectNamespace
    WritingCoach: DurableObjectNamespace
    SpeakingCoach: DurableObjectNamespace
    ReadingCoach: DurableObjectNamespace
    ListeningCoach: DurableObjectNamespace
    Translation: DurableObjectNamespace
    ExamPattern: DurableObjectNamespace
    Safety: DurableObjectNamespace
    CopyrightReviewer: DurableObjectNamespace
    PromptOptimizer: DurableObjectNamespace
    QualityReviewer: DurableObjectNamespace

    // AI Binding
    AI: any

    // API Keys
    OPENAI_API_KEY?: string
    GEMINI_API_KEY?: string
    CLAUDE_API_KEY?: string
  }
}

export interface Env {
  // Durable Objects bindings
  MasterOrchestrator: DurableObjectNamespace
  UserProfile: DurableObjectNamespace
  Memory: DurableObjectNamespace
  CurriculumPlanner: DurableObjectNamespace
  DifficultyAdjustment: DurableObjectNamespace
  Motivation: DurableObjectNamespace
  LearningAnalytics: DurableObjectNamespace
  LessonGenerator: DurableObjectNamespace
  Vocabulary: DurableObjectNamespace
  Grammar: DurableObjectNamespace
  Conversation: DurableObjectNamespace
  Pronunciation: DurableObjectNamespace
  WritingCoach: DurableObjectNamespace
  SpeakingCoach: DurableObjectNamespace
  ReadingCoach: DurableObjectNamespace
  ListeningCoach: DurableObjectNamespace
  Translation: DurableObjectNamespace
  ExamPattern: DurableObjectNamespace
  Safety: DurableObjectNamespace
  CopyrightReviewer: DurableObjectNamespace
  PromptOptimizer: DurableObjectNamespace
  QualityReviewer: DurableObjectNamespace

  // AI Binding
  AI: any

  // API Keys
  OPENAI_API_KEY?: string
  GEMINI_API_KEY?: string
  CLAUDE_API_KEY?: string
}
