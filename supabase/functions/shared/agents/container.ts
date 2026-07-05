// supabase/functions/shared/agents/container.ts
// Dependency injection container for the multi-agent framework.
// Allows agents to be replaced, mocked, or extended at runtime.

import type { AIProvider, ChatMessage, AIResponse } from '../ai.ts';
import type { AgentContext, AgentRequestOptions, OrchestratorConfig } from './types.ts';

// ─── Service Tokens ──────────────────────────────────────────────────────────

export const Tokens = {
  AI_PROVIDER: 'ai_provider',
  AI_PROVIDER_FACTORY: 'ai_provider_factory',
  ORCHESTRATOR_CONFIG: 'orchestrator_config',
  SUPABASE_CLIENT: 'supabase_client',
  EVENT_EMITTER: 'event_emitter',
} as const;

// ─── Container ───────────────────────────────────────────────────────────────

type ServiceFactory<T> = () => T;
type ServiceInstance<T> = { instance: T };

export class Container {
  private factories = new Map<string, ServiceFactory<unknown>>();
  private singletons = new Map<string, ServiceInstance<unknown>>();

  /** Register a factory that creates a new instance each time. */
  register<T>(token: string, factory: ServiceFactory<T>): void {
    this.factories.set(token, factory as ServiceFactory<unknown>);
  }

  /** Register a singleton that is created once and reused. */
  registerSingleton<T>(token: string, factory: ServiceFactory<T>): void {
    const instance = factory();
    this.singletons.set(token, { instance });
  }

  /** Register an existing instance directly. */
  registerInstance<T>(token: string, instance: T): void {
    this.singletons.set(token, { instance });
  }

  /** Resolve a service by token. */
  resolve<T>(token: string): T {
    // Check singletons first
    const singleton = this.singletons.get(token);
    if (singleton) return singleton.instance as T;

    // Then factories
    const factory = this.factories.get(token);
    if (factory) return factory() as T;

    throw new Error(`Service not registered: ${token}`);
  }

  /** Check if a service is registered. */
  has(token: string): boolean {
    return this.singletons.has(token) || this.factories.has(token);
  }

  /** Remove a registration. */
  unregister(token: string): void {
    this.singletons.delete(token);
    this.factories.delete(token);
  }

  /** Clear all registrations. */
  clear(): void {
    this.singletons.clear();
    this.factories.clear();
  }
}

// ─── Global Container ────────────────────────────────────────────────────────

let _container: Container | null = null;

export function getContainer(): Container {
  if (!_container) {
    _container = new Container();
  }
  return _container;
}

export function resetContainer(): void {
  if (_container) {
    _container.clear();
    _container = null;
  }
}

// ─── Provider Registry ───────────────────────────────────────────────────────

/**
 * Register AI providers in the container.
 * This wraps the existing AIProviderFactory pattern with DI.
 */
export function registerProviders(
  container: Container,
  providerFactory: {
    getProvider: (name?: string) => AIProvider;
    chatWithFallback: (
      messages: ChatMessage[],
      options?: Record<string, unknown>
    ) => Promise<AIResponse>;
    chatStreamWithFallback: (
      messages: ChatMessage[],
      options?: Record<string, unknown>,
      onChunk?: (chunk: string) => void
    ) => Promise<AIResponse>;
  }
): void {
  container.registerInstance(Tokens.AI_PROVIDER_FACTORY, providerFactory);
}

// ─── Config Registration ─────────────────────────────────────────────────────

export function registerOrchestratorConfig(
  container: Container,
  config: OrchestratorConfig
): void {
  container.registerInstance(Tokens.ORCHESTRATOR_CONFIG, config);
}

export function getDefaultOrchestratorConfig(): OrchestratorConfig {
  return {
    defaultProvider: 'gemini',
    fallbackProvider: 'openai',
    maxParallelAgents: 5,
    globalTimeout: 30000,
    enablePostProcessing: true,
    mandatoryPostProcessors: ['safety-review', 'copyright-review', 'quality-review'],
  };
}
