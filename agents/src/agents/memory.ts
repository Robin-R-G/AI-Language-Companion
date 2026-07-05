// agents/src/agents/memory.ts
// Memory Agent — stores learning history

import { Agent, callable } from 'agents'
import type { LearningAgent, MemoryInput, MemoryEntry, MemoryOutput, MemoryType } from '../types/contracts'

export class MemoryAgent extends Agent<Env, { memories: Record<string, MemoryEntry[]> }> implements LearningAgent {
  initialState = { memories: {} as Record<string, MemoryEntry[]> }

  id = 'memory'
  get name(): string { return 'MemoryAgent' }
  description = 'Stores learning history'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: MemoryInput): Promise<MemoryOutput> {
    return this.processMemory(input)
  }

  validate(output: MemoryOutput): boolean {
    return output.success
  }

  score(output: MemoryOutput): number {
    return output.success ? 1.0 : 0.0
  }

  @callable()
  async processMemory(input: MemoryInput): Promise<MemoryOutput> {
    const userMemories = this.state.memories[input.userId] || []

    switch (input.action) {
      case 'get': {
        const filtered = input.memoryType
          ? userMemories.filter(m => m.type === input.memoryType)
          : userMemories
        return { agentId: 'memory', success: true, data: filtered }
      }

      case 'add': {
        if (!input.memoryType || !input.data) {
          return { agentId: 'memory', success: false, data: null as any, errors: ['Missing memoryType or data'] }
        }

        const newEntry: MemoryEntry = {
          id: `mem-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
          userId: input.userId,
          type: input.memoryType,
          data: input.data,
          confidence: 1.0,
          createdAt: Date.now(),
          updatedAt: Date.now(),
        }

        this.setState({
          ...this.state,
          memories: {
            ...this.state.memories,
            [input.userId]: [...userMemories, newEntry],
          },
        })

        return { agentId: 'memory', success: true, data: newEntry }
      }

      case 'update': {
        if (!input.data || !(input.data as any).id) {
          return { agentId: 'memory', success: false, data: null as any, errors: ['Missing entry ID'] }
        }

        const updated = userMemories.map(m =>
          m.id === (input.data as any).id
            ? { ...m, ...(input.data as any), updatedAt: Date.now() }
            : m
        )

        this.setState({
          ...this.state,
          memories: { ...this.state.memories, [input.userId]: updated },
        })

        return { agentId: 'memory', success: true, data: input.data as MemoryEntry }
      }

      case 'delete': {
        const filtered = userMemories.filter(m => m.id !== input.data)
        this.setState({
          ...this.state,
          memories: { ...this.state.memories, [input.userId]: filtered },
        })
        return { agentId: 'memory', success: true, data: null as any }
      }

      case 'query': {
        const results = input.query
          ? userMemories.filter(m =>
              JSON.stringify(m.data).toLowerCase().includes(input.query!.toLowerCase())
            )
          : userMemories
        return { agentId: 'memory', success: true, data: results }
      }

      default:
        return { agentId: 'memory', success: false, data: null as any, errors: ['Unknown action'] }
    }
  }
}
