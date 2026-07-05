// supabase/functions/shared/learning-engine/study-planner.ts
import { CEFRLevel, SkillType, StudyPlan, StudyActivity, LearningProgress, UserProfile } from './types.ts'

const SKILL_WEIGHTS: Record<SkillType, number> = {
  grammar: 0.2,
  vocabulary: 0.2,
  speaking: 0.15,
  writing: 0.15,
  reading: 0.1,
  listening: 0.1,
  pronunciation: 0.05,
  translation: 0.05,
}

const DAILY_ACTIVITY_LIMIT = 6
const MIN_ACTIVITY_MINUTES = 5
const MAX_ACTIVITY_MINUTES = 30

export function generateStudyPlan(
  profile: UserProfile,
  progress: LearningProgress,
  targetMinutes: number
): StudyPlan {
  const weakAreas = identifyWeakAreas(progress)
  const activities: StudyActivity[] = []

  // Allocate time based on weaknesses
  const timeAllocation = allocateTime(weakAreas, targetMinutes)

  for (const [skill, minutes] of Object.entries(timeAllocation)) {
    if (minutes >= MIN_ACTIVITY_MINUTES) {
      const activity = createActivity(skill as SkillType, profile.proficiencyLevel, minutes)
      activities.push(activity)
    }
  }

  // Ensure minimum activities
  if (activities.length < 3) {
    activities.push(
      createActivity('vocabulary', profile.proficiencyLevel, 10),
      createActivity('grammar', profile.proficiencyLevel, 10),
      createActivity('listening', profile.proficiencyLevel, 10)
    )
  }

  const totalMinutes = activities.reduce((sum, a) => sum + a.estimatedMinutes, 0)

  return {
    userId: profile.id,
    date: new Date().toISOString().split('T')[0],
    activities: activities.slice(0, DAILY_ACTIVITY_LIMIT),
    estimatedMinutes: totalMinutes,
    focusArea: weakAreas[0] || 'grammar',
    xpGoal: calculateXpGoal(totalMinutes, profile.proficiencyLevel),
  }
}

function identifyWeakAreas(progress: LearningProgress): SkillType[] {
  const skills: [SkillType, number][] = [
    ['grammar', progress.grammarScore],
    ['speaking', progress.speakingScore],
    ['writing', progress.writingScore],
    ['vocabulary', progress.vocabularyScore],
    ['reading', progress.readingScore],
    ['listening', progress.listeningScore],
  ]

  return skills
    .sort((a, b) => a[1] - b[1])
    .map(([skill]) => skill)
}

function allocateTime(weakAreas: SkillType[], totalMinutes: number): Record<string, number> {
  const allocation: Record<string, number> = {}
  const remaining = totalMinutes

  // Give weak areas more time
  weakAreas.forEach((skill, index) => {
    const weight = SKILL_WEIGHTS[skill] || 0.1
    const multiplier = index < 3 ? 1.5 : 1.0
    allocation[skill] = Math.round(remaining * weight * multiplier)
  })

  // Fill remaining time
  const allocated = Object.values(allocation).reduce((sum, m) => sum + m, 0)
  if (allocated < totalMinutes && weakAreas.length > 0) {
    allocation[weakAreas[0]] += totalMinutes - allocated
  }

  return allocation
}

function createActivity(
  skill: SkillType,
  level: CEFRLevel,
  minutes: number
): StudyActivity {
  const titles: Record<SkillType, string> = {
    grammar: 'Grammar Practice',
    vocabulary: 'Vocabulary Building',
    speaking: 'Speaking Exercise',
    writing: 'Writing Practice',
    reading: 'Reading Comprehension',
    listening: 'Listening Exercise',
    pronunciation: 'Pronunciation Drill',
    translation: 'Translation Practice',
  }

  const descriptions: Record<SkillType, string> = {
    grammar: 'Practice grammar rules and sentence structures',
    vocabulary: 'Learn and review new words',
    speaking: 'Practice speaking with AI conversation',
    writing: 'Write and get feedback on your text',
    reading: 'Read passages and answer questions',
    listening: 'Listen and understand spoken language',
    pronunciation: 'Practice correct pronunciation',
    translation: 'Translate between languages',
  }

  return {
    type: skill,
    title: titles[skill],
    description: descriptions[skill],
    estimatedMinutes: Math.min(MAX_ACTIVITY_MINUTES, Math.max(MIN_ACTIVITY_MINUTES, minutes)),
    xpReward: calculateXpReward(skill, minutes),
    difficulty: level,
    completed: false,
  }
}

function calculateXpReward(skill: SkillType, minutes: number): number {
  const baseXp = SKILL_WEIGHTS[skill] || 0.1
  return Math.round(baseXp * minutes * 10)
}

function calculateXpGoal(minutes: number, level: CEFRLevel): number {
  const levelMultiplier: Record<CEFRLevel, number> = {
    A1: 1.0,
    A2: 1.2,
    B1: 1.5,
    B2: 1.8,
    C1: 2.0,
    C2: 2.5,
  }
  return Math.round(minutes * 5 * (levelMultiplier[level] || 1.0))
}
