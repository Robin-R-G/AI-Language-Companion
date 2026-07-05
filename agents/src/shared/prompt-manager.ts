/// <reference path="../types/ambient.d.ts" />
// agents/src/shared/prompt-manager.ts
// Prompt template manager, extracts frontmatter and interpolates context variables

import grammarPrompt from '../../prompts/grammar.md'
import writingPrompt from '../../prompts/writing.md'
import vocabularyPrompt from '../../prompts/vocabulary.md'
import safetyPrompt from '../../prompts/safety.md'
import qualityPrompt from '../../prompts/quality.md'
import examPatternPrompt from '../../prompts/exam-pattern.md'
import conversationPrompt from '../../prompts/conversation.md'
import readingPrompt from '../../prompts/reading.md'
import listeningPrompt from '../../prompts/listening.md'
import pronunciationPrompt from '../../prompts/pronunciation.md'
import translationPrompt from '../../prompts/translation.md'
import lessonPrompt from '../../prompts/lesson.md'
import speakingCoachPrompt from '../../prompts/speaking-coach.md'
import analyticsPrompt from '../../prompts/analytics.md'
import motivationPrompt from '../../prompts/motivation.md'

export interface PromptMetadata {
  id: string
  name: string
  version: string
  author: string
  date: string
  modelCompatibility: string
  changelog: string
  benchmarkScore: number
}

export interface ParsedPrompt {
  metadata: PromptMetadata
  template: string
}

const PROMPT_FILES: Record<string, string> = {
  grammar: grammarPrompt,
  'writing-coach': writingPrompt,
  vocabulary: vocabularyPrompt,
  'ai-safety': safetyPrompt,
  'quality-reviewer': qualityPrompt,
  'exam-pattern': examPatternPrompt,
  conversation: conversationPrompt,
  'reading-coach': readingPrompt,
  'listening-coach': listeningPrompt,
  pronunciation: pronunciationPrompt,
  translation: translationPrompt,
  lesson: lessonPrompt,
  'speaking-coach': speakingCoachPrompt,
  'learning-analytics': analyticsPrompt,
  motivation: motivationPrompt,
}

export function parsePrompt(content: string): ParsedPrompt {
  const match = content.match(/^---\r?\n([\s\S]+?)\r?\n---\r?\n([\s\S]*)$/)
  if (!match) {
    throw new Error('Invalid prompt format: missing frontmatter')
  }

  const yamlSection = match[1]
  const template = match[2]
  const metadata: Partial<PromptMetadata> = {}

  yamlSection.split('\n').forEach(line => {
    const idx = line.indexOf(':')
    if (idx !== -1) {
      const key = line.slice(0, idx).trim()
      const value = line.slice(idx + 1).trim()
      if (key === 'benchmarkScore') {
        metadata.benchmarkScore = parseFloat(value)
      } else {
        (metadata as any)[key] = value.replace(/^['"]|['"]$/g, '')
      }
    }
  })

  return {
    metadata: metadata as PromptMetadata,
    template,
  }
}

export function getPrompt(id: string, variables: Record<string, string> = {}): { metadata: PromptMetadata; prompt: string } {
  const rawContent = PROMPT_FILES[id]
  if (!rawContent) {
    throw new Error(`Prompt template not found for ID: ${id}`)
  }

  const parsed = parsePrompt(rawContent)
  let interpolated = parsed.template

  for (const [key, value] of Object.entries(variables)) {
    interpolated = interpolated.replace(new RegExp(`{{\\s*${key}\\s*}}`, 'g'), value || '')
  }

  return {
    metadata: parsed.metadata,
    prompt: interpolated.trim(),
  }
}
