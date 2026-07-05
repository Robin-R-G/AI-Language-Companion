// agents/src/agents/curriculum-planner.ts
// Curriculum Planner Agent — creates learning plans

import { Agent, callable } from 'agents'
import type {
  LearningAgent,
  CurriculumPlannerInput,
  LearningPlan,
  LearningTask,
  CurriculumPlannerOutput,
  UserProfile,
  MemoryEntry,
  CEFRLanguage,
} from '../types/contracts'

export class CurriculumPlannerAgent extends Agent<Env, { plans: Record<string, LearningPlan> }> implements LearningAgent {
  initialState = { plans: {} as Record<string, LearningPlan> }

  id = 'curriculum-planner'
  get name(): string { return 'CurriculumPlanner' }
  description = 'Creates custom learning plans'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: CurriculumPlannerInput): Promise<CurriculumPlannerOutput> {
    return this.createPlan(input)
  }

  validate(output: CurriculumPlannerOutput): boolean {
    return output.success && !!output.data
  }

  score(output: CurriculumPlannerOutput): number {
    return output.success ? 1.0 : 0.0
  }

  @callable()
  async createPlan(input: CurriculumPlannerInput): Promise<CurriculumPlannerOutput> {
    const tasks = this.generateTasks(input.action, input.profile, input.memories)

    const plan: LearningPlan = {
      id: `plan-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
      userId: input.userId,
      type: input.action,
      tasks,
      estimatedMinutes: tasks.reduce((sum, t) => sum + t.estimatedMinutes, 0),
      difficulty: input.profile.currentLevel,
      createdAt: Date.now(),
    }

    this.setState({
      ...this.state,
      plans: { ...this.state.plans, [input.userId]: plan },
    })

    return { agentId: 'curriculum-planner', success: true, data: plan }
  }

  private generateTasks(
    type: string,
    profile: UserProfile,
    memories: MemoryEntry[]
  ): LearningTask[] {
    const tasks: LearningTask[] = []
    const weakSkills = profile.weakSkills || []

    // Daily plan: structured learning cycle
    if (type === 'daily') {
      // 1. Review Phase (SRS)
      tasks.push({
        id: `task-${Date.now()}-review`,
        type: 'review',
        agent: 'vocabulary',
        description: 'Active recall and review of vocabulary and previous errors',
        estimatedMinutes: 5,
        priority: 'high',
      })

      // 2. Learn Phase
      tasks.push({
        id: `task-${Date.now()}-learn`,
        type: 'lesson',
        agent: 'lesson-generator',
        description: 'Introduce new vocabulary and grammar structures based on goals',
        estimatedMinutes: 15,
        priority: 'high',
      })

      // 3. Practice Phase (Retrieval)
      tasks.push({
        id: `task-${Date.now()}-practice`,
        type: 'practice',
        agent: 'conversation',
        description: 'Guided retrieval practice: try to use new expressions in a dialogue scenario',
        estimatedMinutes: 10,
        priority: 'medium',
      })

      // 4. Reflection Phase
      tasks.push({
        id: `task-${Date.now()}-reflection`,
        type: 'assessment',
        agent: 'curriculum-planner',
        description: 'Metacognitive reflection: summarize what you learned and identify personal struggles',
        estimatedMinutes: 5,
        priority: 'low',
      })
    }

    // Weekly plan: balanced coverage
    if (type === 'weekly') {
      const skills = ['grammar', 'vocabulary', 'reading', 'writing', 'speaking', 'listening']
      skills.forEach((skill, i) => {
        tasks.push({
          id: `task-${Date.now()}-${i}`,
          type: 'lesson',
          agent: skill === 'vocabulary' ? 'vocabulary' : skill === 'grammar' ? 'grammar' : `${skill}-coach` as any,
          description: `${skill.charAt(0).toUpperCase() + skill.slice(1)} lesson`,
          estimatedMinutes: 15,
          priority: weakSkills.includes(skill) ? 'high' : 'medium',
        })
      })
    }

    // Monthly plan: comprehensive
    if (type === 'monthly') {
      tasks.push({
        id: `task-${Date.now()}-1`,
        type: 'assessment',
        agent: 'writing-coach',
        description: 'Monthly writing assessment',
        estimatedMinutes: 30,
        priority: 'high',
      })
      tasks.push({
        id: `task-${Date.now()}-2`,
        type: 'assessment',
        agent: 'speaking-coach',
        description: 'Monthly speaking assessment',
        estimatedMinutes: 30,
        priority: 'high',
      })
    }

    // Exam roadmap
    if (type === 'exam-roadmap' && profile.targetExam !== 'General') {
      tasks.push({
        id: `task-${Date.now()}-1`,
        type: 'lesson',
        agent: 'exam-pattern',
        description: `Learn ${profile.targetExam} exam format`,
        estimatedMinutes: 20,
        priority: 'high',
      })
      tasks.push({
        id: `task-${Date.now()}-2`,
        type: 'practice',
        agent: 'exam-pattern',
        description: `${profile.targetExam} practice test`,
        estimatedMinutes: 60,
        priority: 'high',
      })
    }

    return tasks
  }
}
