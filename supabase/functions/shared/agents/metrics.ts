// supabase/functions/shared/agents/metrics.ts
// Runtime metrics collection for agent execution.
// Tracks latency, cost, confidence, quality, and usage patterns.

import type { AgentMetrics, AgentEvent } from './types.ts';

// ─── Metrics Storage ─────────────────────────────────────────────────────────

interface MetricsEntry {
  agentId: string;
  requestId: string;
  timestamp: number;
  latencyMs: number;
  tokensUsed: number;
  costEstimate: number;
  provider: string;
  model: string;
  success: boolean;
  confidenceScore?: number;
  qualityScore?: number;
}

const metricsLog: MetricsEntry[] = [];
const MAX_LOG_SIZE = 10000;

// ─── Cost Estimation ─────────────────────────────────────────────────────────

const COST_PER_1K_TOKENS: Record<string, number> = {
  'gpt-4o': 0.005,
  'gpt-4o-mini': 0.00015,
  'gemini-1.5-flash': 0.000075,
  'gemini-1.5-pro': 0.00125,
  'claude-3-sonnet': 0.003,
  'claude-3-haiku': 0.00025,
};

export function estimateCost(provider: string, model: string, tokensUsed: number): number {
  const key = model;
  const rate = COST_PER_1K_TOKENS[key] ?? 0.001;
  return (tokensUsed / 1000) * rate;
}

// ─── Metrics Recording ───────────────────────────────────────────────────────

export function recordMetrics(entry: Omit<MetricsEntry, 'timestamp'>): void {
  metricsLog.push({ ...entry, timestamp: Date.now() });
  if (metricsLog.length > MAX_LOG_SIZE) {
    metricsLog.splice(0, metricsLog.length - MAX_LOG_SIZE);
  }
}

// ─── Aggregation ─────────────────────────────────────────────────────────────

export interface AgentAggregateMetrics {
  agentId: string;
  totalCalls: number;
  successRate: number;
  avgLatencyMs: number;
  avgTokensUsed: number;
  totalCostEstimate: number;
  p95LatencyMs: number;
  p99LatencyMs: number;
  avgConfidenceScore: number;
  avgQualityScore: number;
}

export function getAggregateMetrics(agentId: string): AgentAggregateMetrics | null {
  const entries = metricsLog.filter((e) => e.agentId === agentId);
  if (entries.length === 0) return null;

  const sortedLatencies = entries.map((e) => e.latencyMs).sort((a, b) => a - b);
  const successes = entries.filter((e) => e.success);

  const confidenceScores = entries.filter((e) => e.confidenceScore !== undefined);
  const qualityScores = entries.filter((e) => e.qualityScore !== undefined);

  return {
    agentId,
    totalCalls: entries.length,
    successRate: successes.length / entries.length,
    avgLatencyMs: entries.reduce((sum, e) => sum + e.latencyMs, 0) / entries.length,
    avgTokensUsed: entries.reduce((sum, e) => sum + e.tokensUsed, 0) / entries.length,
    totalCostEstimate: entries.reduce((sum, e) => sum + e.costEstimate, 0),
    p95LatencyMs: sortedLatencies[Math.floor(sortedLatencies.length * 0.95)] ?? 0,
    p99LatencyMs: sortedLatencies[Math.floor(sortedLatencies.length * 0.99)] ?? 0,
    avgConfidenceScore:
      confidenceScores.length > 0
        ? confidenceScores.reduce((sum, e) => sum + (e.confidenceScore ?? 0), 0) / confidenceScores.length
        : 0,
    avgQualityScore:
      qualityScores.length > 0
        ? qualityScores.reduce((sum, e) => sum + (e.qualityScore ?? 0), 0) / qualityScores.length
        : 0,
  };
}

export function getAllAggregateMetrics(): AgentAggregateMetrics[] {
  const agentIds = [...new Set(metricsLog.map((e) => e.agentId))];
  return agentIds
    .map((id) => getAggregateMetrics(id))
    .filter((m): m is AgentAggregateMetrics => m !== null);
}

// ─── Event Listener ──────────────────────────────────────────────────────────

type EventListener = (event: AgentEvent) => void;
const listeners: EventListener[] = [];

export function onAgentEvent(listener: EventListener): void {
  listeners.push(listener);
}

export function emitEvent(event: AgentEvent): void {
  for (const listener of listeners) {
    try {
      listener(event);
    } catch {
      // Don't let listener errors break the pipeline
    }
  }
}

// ─── Health Check ────────────────────────────────────────────────────────────

export interface HealthStatus {
  healthy: boolean;
  totalCallsLast5Min: number;
  avgLatencyLast5Min: number;
  errorRateLast5Min: number;
}

export function getHealthStatus(): HealthStatus {
  const fiveMinAgo = Date.now() - 5 * 60 * 1000;
  const recent = metricsLog.filter((e) => e.timestamp > fiveMinAgo);

  const totalCalls = recent.length;
  const avgLatency = totalCalls > 0
    ? recent.reduce((sum, e) => sum + e.latencyMs, 0) / totalCalls
    : 0;
  const errorRate = totalCalls > 0
    ? recent.filter((e) => !e.success).length / totalCalls
    : 0;

  return {
    healthy: errorRate < 0.1 && avgLatency < 5000,
    totalCallsLast5Min: totalCalls,
    avgLatencyLast5Min: avgLatency,
    errorRateLast5Min: errorRate,
  };
}

// ─── Reset (for testing) ────────────────────────────────────────────────────

export function resetMetrics(): void {
  metricsLog.length = 0;
}
