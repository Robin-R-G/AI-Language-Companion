// supabase/functions/shared/agents/registry.ts
// Central registry for all agents. Provides lookup, filtering, and usage tracking.

import type { LearningAgent, AgentMetadata, AgentCategory, AgentCapability, RegistryEntry } from './types.ts';

// ─── Registry ────────────────────────────────────────────────────────────────

const registry = new Map<string, RegistryEntry>();

export function registerAgent(agent: LearningAgent): void {
  const { id } = agent.metadata;
  if (registry.has(id)) {
    console.warn(`Agent "${id}" is already registered. Overwriting.`);
  }
  registry.set(id, {
    agent,
    metadata: agent.metadata,
    registeredAt: Date.now(),
    usageCount: 0,
  });
}

export function unregisterAgent(id: string): boolean {
  return registry.delete(id);
}

export function getAgent(id: string): LearningAgent | undefined {
  return registry.get(id)?.agent;
}

export function getAgentMetadata(id: string): AgentMetadata | undefined {
  return registry.get(id)?.metadata;
}

export function recordUsage(id: string): void {
  const entry = registry.get(id);
  if (entry) {
    entry.usageCount++;
    entry.lastUsed = Date.now();
  }
}

// ─── Queries ─────────────────────────────────────────────────────────────────

export function getAllAgents(): LearningAgent[] {
  return [...registry.values()].map((e) => e.agent);
}

export function getEnabledAgents(): LearningAgent[] {
  return getAllAgents().filter((a) => a.metadata.enabled);
}

export function getAgentsByCategory(category: AgentCategory): LearningAgent[] {
  return getEnabledAgents().filter((a) => a.metadata.category === category);
}

export function getAgentsByCapability(capability: AgentCapability): LearningAgent[] {
  return getEnabledAgents().filter((a) => a.metadata.capabilities.includes(capability));
}

export function getAgentsByProvider(provider: string): LearningAgent[] {
  return getEnabledAgents().filter((a) => a.metadata.providers.includes(provider));
}

export function findAgentForCapability(
  capability: AgentCapability,
  preferredProvider?: string
): LearningAgent | undefined {
  const candidates = getAgentsByCapability(capability);
  if (preferredProvider) {
    const preferred = candidates.filter((a) => a.metadata.providers.includes(preferredProvider));
    if (preferred.length > 0) return preferred[0];
  }
  // Fallback: return lowest cost tier first
  const costOrder = { low: 0, medium: 1, high: 2 };
  return candidates.sort(
    (a, b) => costOrder[a.metadata.costTier] - costOrder[b.metadata.costTier]
  )[0];
}

// ─── Registry Stats ──────────────────────────────────────────────────────────

export interface RegistryStats {
  totalAgents: number;
  enabledAgents: number;
  byCategory: Record<AgentCategory, number>;
  byCapability: Record<string, number>;
  mostUsed: { agentId: string; usageCount: number }[];
}

export function getRegistryStats(): RegistryStats {
  const all = [...registry.values()];
  const enabled = all.filter((e) => e.metadata.enabled);

  const byCategory: Record<string, number> = {};
  const byCapability: Record<string, number> = {};

  for (const entry of enabled) {
    byCategory[entry.metadata.category] = (byCategory[entry.metadata.category] || 0) + 1;
    for (const cap of entry.metadata.capabilities) {
      byCapability[cap] = (byCapability[cap] || 0) + 1;
    }
  }

  const mostUsed = all
    .sort((a, b) => b.usageCount - a.usageCount)
    .slice(0, 10)
    .map((e) => ({ agentId: e.metadata.id, usageCount: e.usageCount }));

  return {
    totalAgents: all.length,
    enabledAgents: enabled.length,
    byCategory: byCategory as Record<AgentCategory, number>,
    byCapability,
    mostUsed,
  };
}

// ─── Reset (for testing) ────────────────────────────────────────────────────

export function clearRegistry(): void {
  registry.clear();
}
