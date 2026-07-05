// supabase/functions/shared/agents/__tests__/agents_test.ts
// Tests for the multi-agent framework core components.

import { assertEquals, assertExists, assertNotEquals } from 'https://deno.land/std@0.177.0/assert/mod.ts'

// Import core framework
import {
  registerAgent,
  unregisterAgent,
  getAgent,
  getAllAgents,
  getEnabledAgents,
  getAgentsByCategory,
  getAgentsByCapability,
  findAgentForCapability,
  getRegistryStats,
  clearRegistry,
} from '../registry.ts'

import {
  Container,
  getContainer,
  resetContainer,
  Tokens,
  getDefaultOrchestratorConfig,
} from '../container.ts'

import {
  recordMetrics,
  estimateCost,
  getAggregateMetrics,
  resetMetrics,
  getHealthStatus,
} from '../metrics.ts'

import {
  loadPromptTemplate,
  getPromptTemplate,
  resolveVariables,
  registerBuiltinTemplates,
  GLOBAL_RULES,
} from '../prompt-loader.ts'

import { createAgent, type AgentConfig } from '../base-agent.ts'
import type { LearningAgent, AgentContext } from '../types.ts'

// ─── Test Helpers ────────────────────────────────────────────────────────────

function createMockAgent(id: string, category: string = 'educational'): LearningAgent {
  return createAgent({
    metadata: {
      id,
      name: `Mock ${id}`,
      version: '1.0.0',
      description: `Test agent: ${id}`,
      category: category as any,
      capabilities: [id as any],
      providers: ['gemini'],
      costTier: 'low',
      maxTokens: 1024,
      temperature: 0.5,
      enabled: true,
    },
    promptBuilder: (ctx: AgentContext) => `Mock prompt for ${id}`,
  })
}

// ─── Registry Tests ──────────────────────────────────────────────────────────

Deno.test('Registry: register and retrieve agent', () => {
  clearRegistry()
  const agent = createMockAgent('test-1')
  registerAgent(agent)

  const retrieved = getAgent('test-1')
  assertExists(retrieved)
  assertEquals(retrieved!.metadata.id, 'test-1')
})

Deno.test('Registry: unregister agent', () => {
  clearRegistry()
  const agent = createMockAgent('test-unregister')
  registerAgent(agent)
  assertEquals(getAgent('test-unregister') !== undefined, true)

  const removed = unregisterAgent('test-unregister')
  assertEquals(removed, true)
  assertEquals(getAgent('test-unregister'), undefined)
})

Deno.test('Registry: get all agents', () => {
  clearRegistry()
  registerAgent(createMockAgent('a1'))
  registerAgent(createMockAgent('a2'))
  registerAgent(createMockAgent('a3'))

  const all = getAllAgents()
  assertEquals(all.length, 3)
})

Deno.test('Registry: filter by category', () => {
  clearRegistry()
  registerAgent(createMockAgent('edu-1', 'educational'))
  registerAgent(createMockAgent('edu-2', 'educational'))
  registerAgent(createMockAgent('eng-1', 'engineering'))

  const educational = getAgentsByCategory('educational')
  assertEquals(educational.length, 2)
})

Deno.test('Registry: filter by capability', () => {
  clearRegistry()
  registerAgent(createMockAgent('grammar', 'educational'))
  registerAgent(createMockAgent('vocabulary', 'educational'))

  const grammarAgents = getAgentsByCapability('grammar' as any)
  assertEquals(grammarAgents.length, 1)
  assertEquals(grammarAgents[0].metadata.id, 'grammar')
})

Deno.test('Registry: find agent for capability', () => {
  clearRegistry()
  registerAgent(createMockAgent('grammar', 'educational'))

  const found = findAgentForCapability('grammar' as any)
  assertExists(found)
  assertEquals(found!.metadata.id, 'grammar')
})

Deno.test('Registry: stats', () => {
  clearRegistry()
  registerAgent(createMockAgent('s1', 'educational'))
  registerAgent(createMockAgent('s2', 'engineering'))

  const stats = getRegistryStats()
  assertEquals(stats.totalAgents, 2)
  assertEquals(stats.enabledAgents, 2)
})

// ─── Container Tests ─────────────────────────────────────────────────────────

Deno.test('Container: register and resolve', () => {
  const container = new Container()
  container.registerInstance('test-service', { value: 42 })

  const resolved = container.resolve<{ value: number }>('test-service')
  assertEquals(resolved.value, 42)
})

Deno.test('Container: factory registration', () => {
  const container = new Container()
  let callCount = 0
  container.register('counter', () => ({ count: ++callCount }))

  const a = container.resolve<{ count: number }>('counter')
  const b = container.resolve<{ count: number }>('counter')
  assertEquals(a.count, 1)
  assertEquals(b.count, 2)
})

Deno.test('Container: singleton', () => {
  const container = new Container()
  let callCount = 0
  container.registerSingleton('singleton', () => ({ count: ++callCount }))

  const a = container.resolve<{ count: number }>('singleton')
  const b = container.resolve<{ count: number }>('singleton')
  assertEquals(a.count, 1)
  assertEquals(b.count, 1)
  assertEquals(a, b)
})

Deno.test('Container: resolve unregistered throws', () => {
  const container = new Container()
  let threw = false
  try {
    container.resolve('nonexistent')
  } catch {
    threw = true
  }
  assertEquals(threw, true)
})

// ─── Metrics Tests ───────────────────────────────────────────────────────────

Deno.test('Metrics: estimate cost', () => {
  const cost = estimateCost('openai', 'gpt-4o', 1000)
  assertEquals(cost > 0, true)
  assertEquals(cost < 1, true)
})

Deno.test('Metrics: record and aggregate', () => {
  resetMetrics()
  recordMetrics({
    agentId: 'test-metric',
    requestId: 'req-1',
    latencyMs: 500,
    tokensUsed: 200,
    costEstimate: 0.001,
    provider: 'openai',
    model: 'gpt-4o',
    success: true,
  })

  const agg = getAggregateMetrics('test-metric')
  assertExists(agg)
  assertEquals(agg!.totalCalls, 1)
  assertEquals(agg!.avgLatencyMs, 500)
})

Deno.test('Metrics: health status', () => {
  resetMetrics()
  const health = getHealthStatus()
  assertEquals(health.healthy, true)
  assertEquals(typeof health.totalCallsLast5Min, 'number')
})

// ─── Prompt Loader Tests ─────────────────────────────────────────────────────

Deno.test('Prompt Loader: register and retrieve template', () => {
  loadPromptTemplate({
    id: 'test-template',
    version: '1.0.0',
    system: 'You are a test agent.',
    userTemplate: 'Test input: {{user_input}}',
    variables: { user_input: 'text' },
  })

  const template = getPromptTemplate('test-template')
  assertExists(template)
  assertEquals(template!.id, 'test-template')
})

Deno.test('Prompt Loader: resolve variables', () => {
  const result = resolveVariables('Hello {{user_name}}, level: {{learning_level}}', {
    userId: '1',
    userProfile: {
      id: '1',
      fullName: 'Arjun',
      nativeLanguage: 'Malayalam',
      targetLanguage: 'English',
      proficiencyLevel: 'B1',
      targetExam: 'IELTS',
      subscriptionPlan: 'free',
    },
  })

  assertEquals(result, 'Hello Arjun, level: B1')
})

Deno.test('Prompt Loader: register builtin templates', () => {
  registerBuiltinTemplates()
  const grammar = getPromptTemplate('grammar-correction')
  assertExists(grammar)
  assertEquals(grammar!.version, '2.1.0')
})

Deno.test('Prompt Loader: GLOBAL_RULES contains safety rules', () => {
  assertEquals(GLOBAL_RULES.includes('prompt injection'), true)
  assertEquals(GLOBAL_RULES.includes('NEVER reproduce'), true)
})

// ─── Agent Creation Tests ────────────────────────────────────────────────────

Deno.test('Agent: create agent with config', () => {
  const agent = createAgent({
    metadata: {
      id: 'custom-agent',
      name: 'Custom Agent',
      version: '1.0.0',
      description: 'A custom test agent',
      category: 'educational',
      capabilities: ['grammar'],
      providers: ['gemini'],
      costTier: 'low',
      maxTokens: 1024,
      temperature: 0.5,
      enabled: true,
    },
    promptBuilder: () => 'Custom prompt',
  })

  assertEquals(agent.metadata.id, 'custom-agent')
  assertEquals(agent.buildPrompt({ userId: '1' }), 'Custom prompt')
})

Deno.test('Agent: validate output parses JSON', () => {
  const agent = createAgent({
    metadata: {
      id: 'validator-test',
      name: 'Validator Test',
      version: '1.0.0',
      description: 'Test',
      category: 'educational',
      capabilities: ['grammar'],
      providers: ['gemini'],
      costTier: 'low',
      maxTokens: 1024,
      temperature: 0.5,
      enabled: true,
    },
    promptBuilder: () => '',
  })

  const result = agent.validateOutput('Here is the result: {"is_correct": true}')
  assertEquals(result.valid, true)
  assertEquals((result.parsed as any).is_correct, true)
})

Deno.test('Agent: validate output handles invalid JSON', () => {
  const agent = createAgent({
    metadata: {
      id: 'invalid-test',
      name: 'Invalid Test',
      version: '1.0.0',
      description: 'Test',
      category: 'educational',
      capabilities: ['grammar'],
      providers: ['gemini'],
      costTier: 'low',
      maxTokens: 1024,
      temperature: 0.5,
      enabled: true,
    },
    promptBuilder: () => '',
  })

  const result = agent.validateOutput('No JSON here at all')
  assertEquals(result.valid, false)
})

// ─── Orchestrator Config Tests ───────────────────────────────────────────────

Deno.test('Config: default orchestrator config', () => {
  const config = getDefaultOrchestratorConfig()
  assertEquals(config.enablePostProcessing, true)
  assertEquals(config.mandatoryPostProcessors.length, 3)
  assertEquals(config.globalTimeout, 30000)
})
