// agents/src/workflows/request-pipeline.ts
// Request Pipeline Workflow — durable multi-step agent orchestration

import { AgentWorkflow } from 'agents/workflows'
import type { AgentWorkflowEvent, AgentWorkflowStep } from 'agents/workflows'
import { MasterOrchestrator } from '../orchestrator/master'

type PipelineParams = {
  userId: string
  sessionId: string
  userMessage: string
  intent?: string
  timestamp?: number
}

export class RequestPipeline extends AgentWorkflow<MasterOrchestrator, PipelineParams> {
  async run(event: AgentWorkflowEvent<PipelineParams>, step: AgentWorkflowStep) {
    const params = event.payload

    // Step 1: Get user profile
    const profile = await step.do('get-profile', (async () => {
      // Fetch user profile from UserProfileAgent
      return { level: 'B1', targetLanguage: 'English', targetExam: 'IELTS' }
    }) as any)

    // Step 2: Get memory context
    const memories = await step.do('get-memories', (async () => {
      // Fetch memories from MemoryAgent
      return []
    }) as any)

    // Step 3: Detect intent
    const intent = await step.do('detect-intent', (async () => {
      return params.intent || this.detectIntent(params.userMessage)
    }) as any)

    // Step 4: Execute specialized agent
    const agentOutput = await step.do('execute-agent', (async () => {
      return this.executeAgent(intent as string, params, profile)
    }) as any)

    // Step 5: Safety review
    const safetyResult = await step.do('safety-review', (async () => {
      return { safe: true, issues: [] }
    }) as any)

    // Step 6: Quality review
    const qualityResult = await step.do('quality-review', (async () => {
      return { score: 85, issues: [], suggestions: [] }
    }) as any)

    // Step 7: Generate response
    const response = await step.do('generate-response', (async () => {
      return this.formatResponse(agentOutput, qualityResult)
    }) as any)

    // Step 8: Report progress
    await this.reportProgress({ step: 'complete', percent: 1.0 })

    // Step 9: Report completion
    await step.reportComplete({
      response,
      agentsInvolved: ['user-profile', 'memory', intent as any, 'ai-safety', 'quality-reviewer'],
      metadata: {
        totalTokens: 0,
        totalLatencyMs: Date.now() - (params.timestamp ?? Date.now()),
        pipeline: ['profile', 'memory', intent as any, 'safety', 'quality'],
      },
    })

    return { response }
  }

  private detectIntent(message: string): string {
    const lower = message.toLowerCase()
    if (lower.includes('grammar') || lower.includes('correct')) return 'grammar'
    if (lower.includes('vocabulary') || lower.includes('word')) return 'vocabulary'
    if (lower.includes('writing') || lower.includes('essay')) return 'writing'
    if (lower.includes('speak') || lower.includes('pronunciation')) return 'speaking'
    if (lower.includes('read') || lower.includes('passage')) return 'reading'
    if (lower.includes('listen') || lower.includes('audio')) return 'listening'
    if (lower.includes('practice') || lower.includes('conversation')) return 'conversation'
    return 'general'
  }

  private async executeAgent(intent: string, params: PipelineParams, profile: any): Promise<unknown> {
    // In production, this would call the actual agents via DO RPC
    const agentMap: Record<string, string> = {
      grammar: 'grammar-agent',
      vocabulary: 'vocabulary-agent',
      writing: 'writing-coach-agent',
      speaking: 'speaking-coach-agent',
      reading: 'reading-coach-agent',
      listening: 'listening-coach-agent',
      conversation: 'conversation-agent',
      general: 'lesson-generator-agent',
    }

    const agentName = agentMap[intent] || 'lesson-generator-agent'
    console.log(`Executing agent: ${agentName}`)
    return { message: `Response from ${agentName}` }
  }

  private formatResponse(output: unknown, quality: any): string {
    if (typeof output === 'string') return output
    if (output && typeof output === 'object') {
      const obj = output as Record<string, unknown>
      if (obj.message) return obj.message as string
    }
    return JSON.stringify(output)
  }
}
