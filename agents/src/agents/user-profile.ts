// agents/src/agents/user-profile.ts
// User Profile Agent — maintains learner profile

import { Agent, callable } from 'agents'
import type { LearningAgent, UserProfileInput, UserProfile, UserProfileOutput } from '../types/contracts'

export class UserProfileAgent extends Agent<Env, { profiles: Record<string, UserProfile> }> implements LearningAgent {
  initialState = { profiles: {} as Record<string, UserProfile> }

  id = 'user-profile'
  get name(): string { return 'UserProfileAgent' }
  description = 'Maintains learner profile'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: UserProfileInput): Promise<UserProfileOutput> {
    return this.getProfile(input)
  }

  validate(output: UserProfileOutput): boolean {
    return output.success && !!output.data
  }

  score(output: UserProfileOutput): number {
    return output.success ? 1.0 : 0.0
  }

  @callable()
  async getProfile(input: UserProfileInput): Promise<UserProfileOutput> {
    const profile = this.state.profiles[input.userId]

    if (!profile && input.action === 'initialize') {
      const newProfile: UserProfile = {
        userId: input.userId,
        name: input.updates?.name || 'Learner',
        nativeLanguage: input.updates?.nativeLanguage || 'Malayalam',
        targetLanguage: input.updates?.targetLanguage || 'English',
        currentLevel: input.updates?.currentLevel || 'A1',
        targetExam: input.updates?.targetExam || 'General',
        learningGoal: input.updates?.learningGoal || 'General improvement',
        weakSkills: input.updates?.weakSkills || [],
        strongSkills: input.updates?.strongSkills || [],
        preferredLearningStyle: input.updates?.preferredLearningStyle || 'visual',
        dailyGoalMinutes: input.updates?.dailyGoalMinutes || 30,
        subscription: input.updates?.subscription || 'free',
        createdAt: Date.now(),
        updatedAt: Date.now(),
      }

      this.setState({
        ...this.state,
        profiles: { ...this.state.profiles, [input.userId]: newProfile },
      })

      return {
        agentId: 'user-profile',
        success: true,
        data: newProfile,
      }
    }

    if (input.action === 'update' && input.updates && profile) {
      const updatedProfile = {
        ...profile,
        ...input.updates,
        updatedAt: Date.now(),
      }

      this.setState({
        ...this.state,
        profiles: { ...this.state.profiles, [input.userId]: updatedProfile },
      })

      return {
        agentId: 'user-profile',
        success: true,
        data: updatedProfile,
      }
    }

    return {
      agentId: 'user-profile',
      success: !!profile,
      data: profile || {} as UserProfile,
      errors: profile ? undefined : ['Profile not found'],
    }
  }
}
