// supabase/functions/agent-orchestrate/index.ts
// Unified AI Orchestration Edge Function.
// Routes requests to the appropriate agent(s) and enforces post-processing.

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, serverError, aiProviderError } from '../shared/errors.ts'
import { validateRequired } from '../shared/validator.ts'
import { corsHeaders } from '../shared/cors.ts'

import {
  initializeAgentFramework,
  Orchestrator,
  getAgent,
  getAllAgents,
  getRegistryStats,
  findAgentForCapability,
  getHealthStatus,
  getAllAggregateMetrics,
  type AgentContext,
  type AgentCapability,
  type Pipeline,
} from '../shared/agents/index.ts'

// ─── Initialize Framework ────────────────────────────────────────────────────

let initialized = false;
function ensureInitialized() {
  if (!initialized) {
    initializeAgentFramework();
    initialized = true;
  }
}

// ─── Request Types ───────────────────────────────────────────────────────────

interface OrchestrateRequest {
  action: 'route' | 'execute' | 'pipeline' | 'list' | 'stats' | 'health';
  agent_id?: string;
  capability?: AgentCapability;
  input?: string;
  pipeline?: Pipeline;
  options?: {
    temperature?: number;
    maxTokens?: number;
    preferredProvider?: string;
    skipPostProcessing?: boolean;
  };
}

// ─── Handlers ────────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  ensureInitialized()

  try {
    const body: OrchestrateRequest = await req.json()

    switch (body.action) {
      case 'route':
        return await handleRoute(body, authResult)
      case 'execute':
        return await handleExecute(body, authResult)
      case 'pipeline':
        return await handlePipeline(body, authResult)
      case 'list':
        return handleList()
      case 'stats':
        return handleStats()
      case 'health':
        return handleHealth()
      default:
        return badRequest(`Unknown action: ${(body as any).action}`)
    }
  } catch (error) {
    console.error('Agent orchestration error:', error)
    if ((error as Error).message?.includes('AI providers failed')) {
      return aiProviderError('AI service temporarily unavailable. Please try again.')
    }
    return serverError((error as Error).message || 'Internal server error')
  }
})

// ─── Route to Capability ─────────────────────────────────────────────────────

async function handleRoute(
  body: OrchestrateRequest,
  authResult: any
): Promise<Response> {
  if (!body.capability || !body.input) {
    return badRequest('capability and input are required for route action')
  }

  const supabase = authResult.supabaseClient
  const userId = authResult.user.id

  // Load user profile
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('auth_user_id', userId)
    .single()

  const context: AgentContext = {
    userId,
    userProfile: profile ? {
      id: profile.id,
      fullName: profile.full_name,
      nativeLanguage: profile.native_language,
      targetLanguage: profile.target_language,
      proficiencyLevel: profile.proficiency_level,
      targetExam: profile.target_exam,
      subscriptionPlan: 'free',
    } : undefined,
  }

  const orchestrator = new Orchestrator()
  const result = await orchestrator.route(
    body.capability,
    body.input,
    context,
    body.options
  )

  return successResponse({
    agent_id: result.agentId,
    output: result.output,
    metrics: result.metrics,
    post_processing: result.postProcessingResults,
  }, `Routed to ${result.agentId}`)
}

// ─── Execute Specific Agent ──────────────────────────────────────────────────

async function handleExecute(
  body: OrchestrateRequest,
  authResult: any
): Promise<Response> {
  if (!body.agent_id || !body.input) {
    return badRequest('agent_id and input are required for execute action')
  }

  const agent = getAgent(body.agent_id)
  if (!agent) {
    return badRequest(`Agent not found: ${body.agent_id}`)
  }

  const supabase = authResult.supabaseClient
  const userId = authResult.user.id

  const { data: profile } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('auth_user_id', userId)
    .single()

  const context: AgentContext = {
    userId,
    userProfile: profile ? {
      id: profile.id,
      fullName: profile.full_name,
      nativeLanguage: profile.native_language,
      targetLanguage: profile.target_language,
      proficiencyLevel: profile.proficiency_level,
      targetExam: profile.target_exam,
      subscriptionPlan: 'free',
    } : undefined,
  }

  const orchestrator = new Orchestrator()
  const result = await orchestrator.execute(
    body.agent_id,
    body.input,
    context,
    body.options
  )

  return successResponse({
    agent_id: result.agentId,
    output: result.output,
    metrics: result.metrics,
    post_processing: result.postProcessingResults,
  }, `Executed ${result.agentId}`)
}

// ─── Execute Pipeline ────────────────────────────────────────────────────────

async function handlePipeline(
  body: OrchestrateRequest,
  authResult: any
): Promise<Response> {
  if (!body.pipeline || !body.input) {
    return badRequest('pipeline and input are required for pipeline action')
  }

  const supabase = authResult.supabaseClient
  const userId = authResult.user.id

  const { data: profile } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('auth_user_id', userId)
    .single()

  const context: AgentContext = {
    userId,
    userProfile: profile ? {
      id: profile.id,
      fullName: profile.full_name,
      nativeLanguage: profile.native_language,
      targetLanguage: profile.target_language,
      proficiencyLevel: profile.proficiency_level,
      targetExam: profile.target_exam,
      subscriptionPlan: 'free',
    } : undefined,
  }

  const orchestrator = new Orchestrator()
  const results = await orchestrator.executePipeline(
    body.pipeline,
    body.input,
    context,
    body.options
  )

  const serialized = Object.fromEntries(
    [...results.entries()].map(([key, val]) => [key, {
      agent_id: val.agentId,
      output: val.output,
      metrics: val.metrics,
    }])
  )

  return successResponse(serialized, 'Pipeline executed')
}

// ─── List Agents ─────────────────────────────────────────────────────────────

function handleList(): Response {
  const agents = getAllAgents().map((a) => ({
    id: a.metadata.id,
    name: a.metadata.name,
    category: a.metadata.category,
    capabilities: a.metadata.capabilities,
    version: a.metadata.version,
    enabled: a.metadata.enabled,
  }))

  return successResponse(agents, `Found ${agents.length} agents`)
}

// ─── Registry Stats ──────────────────────────────────────────────────────────

function handleStats(): Response {
  return successResponse(getRegistryStats(), 'Registry stats')
}

// ─── Health Check ────────────────────────────────────────────────────────────

function handleHealth(): Response {
  const health = getHealthStatus()
  const metrics = getAllAggregateMetrics()

  return successResponse({
    framework: health,
    agents: metrics,
    timestamp: new Date().toISOString(),
  }, 'Health check')
}
