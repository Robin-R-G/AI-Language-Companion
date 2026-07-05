// agents/src/shared/ai.ts
// Cloudflare Worker compatible AI Client Supporting OpenAI, Gemini, and Claude

import type { Env } from '../types/declarations'

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

export interface AIResponse {
  content: string
  provider: string
  model: string
  tokensUsed: number
  latencyMs: number
}

// ─── OpenAI Provider ─────────────────────────────────────────────────────────

export class OpenAIProvider {
  readonly name = 'openai'
  readonly models = {
    fast: 'gpt-4o-mini',
    standard: 'gpt-4o-mini',
    premium: 'gpt-4o',
  }

  constructor(private env: Env) {}

  async chat(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number } = {}
  ): Promise<AIResponse> {
    const apiKey = this.env.OPENAI_API_KEY
    if (!apiKey) {
      throw new Error('OPENAI_API_KEY not configured in environment.')
    }

    const startTime = Date.now()
    const model = options.model || this.models.standard

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages,
        temperature: options.temperature ?? 0.7,
        max_tokens: options.maxTokens ?? 2048,
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`OpenAI API error (${response.status}): ${errorText}`)
    }

    const data: any = await response.json()
    const latencyMs = Date.now() - startTime

    return {
      content: data.choices?.[0]?.message?.content || '',
      provider: this.name,
      model,
      tokensUsed: data.usage?.total_tokens || 0,
      latencyMs,
    }
  }
}

// ─── Gemini Provider ─────────────────────────────────────────────────────────

export class GeminiProvider {
  readonly name = 'gemini'
  readonly models = {
    fast: 'gemini-1.5-flash',
    standard: 'gemini-1.5-flash',
    premium: 'gemini-1.5-pro',
  }

  constructor(private env: Env) {}

  private formatMessages(messages: ChatMessage[]): { contents: any[]; systemInstruction?: any } {
    const systemMsg = messages.find((m) => m.role === 'system')
    const chatMsgs = messages.filter((m) => m.role !== 'system')

    const contents = chatMsgs.map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }))

    const systemInstruction = systemMsg
      ? { parts: [{ text: systemMsg.content }] }
      : undefined

    return { contents, systemInstruction }
  }

  async chat(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number } = {}
  ): Promise<AIResponse> {
    const apiKey = this.env.GEMINI_API_KEY
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY not configured in environment.')
    }

    const startTime = Date.now()
    const model = options.model || this.models.standard
    const { contents, systemInstruction } = this.formatMessages(messages)

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents,
          systemInstruction,
          generationConfig: {
            temperature: options.temperature ?? 0.7,
            maxOutputTokens: options.maxTokens ?? 2048,
          },
        }),
      }
    )

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Gemini API error (${response.status}): ${errorText}`)
    }

    const data: any = await response.json()
    const latencyMs = Date.now() - startTime
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

    return {
      content,
      provider: this.name,
      model,
      tokensUsed: data.usageMetadata?.totalTokenCount || 0,
      latencyMs,
    }
  }
}

// ─── Claude Provider ─────────────────────────────────────────────────────────

export class ClaudeProvider {
  readonly name = 'claude'
  readonly models = {
    fast: 'claude-3-haiku-20240307',
    standard: 'claude-3-haiku-20240307',
    premium: 'claude-3-sonnet-20240229',
  }

  constructor(private env: Env) {}

  async chat(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number } = {}
  ): Promise<AIResponse> {
    const apiKey = this.env.CLAUDE_API_KEY
    if (!apiKey) {
      throw new Error('CLAUDE_API_KEY not configured in environment.')
    }

    const startTime = Date.now()
    const model = options.model || this.models.standard

    const systemMsg = messages.find((m) => m.role === 'system')
    const chatMsgs = messages.filter((m) => m.role !== 'system')

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: chatMsgs.map((m) => ({
          role: m.role === 'assistant' ? 'assistant' : 'user',
          content: m.content,
        })),
        system: systemMsg?.content,
        temperature: options.temperature ?? 0.7,
        max_tokens: options.maxTokens ?? 2048,
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Claude API error (${response.status}): ${errorText}`)
    }

    const data: any = await response.json()
    const latencyMs = Date.now() - startTime
    const content = data.content?.[0]?.text || ''

    return {
      content,
      provider: this.name,
      model,
      tokensUsed: (data.usage?.input_tokens || 0) + (data.usage?.output_tokens || 0),
      latencyMs,
    }
  }
}

// ─── Shared Client Orchestrator ──────────────────────────────────────────────

export type ProviderName = 'openai' | 'gemini' | 'claude'

export class AIClient {
  private providers: {
    openai: OpenAIProvider
    gemini: GeminiProvider
    claude: ClaudeProvider
  }

  constructor(private env: Env) {
    this.providers = {
      openai: new OpenAIProvider(env),
      gemini: new GeminiProvider(env),
      claude: new ClaudeProvider(env),
    }
  }

  async chatWithFallback(
    messages: ChatMessage[],
    options: {
      model?: string
      temperature?: number
      maxTokens?: number
      preferredProvider?: ProviderName
    } = {}
  ): Promise<AIResponse> {
    const providersQueue: ProviderName[] = []
    const preferred = options.preferredProvider || 'gemini'

    providersQueue.push(preferred)
    if (preferred !== 'gemini' && this.env.GEMINI_API_KEY) providersQueue.push('gemini')
    if (preferred !== 'openai' && this.env.OPENAI_API_KEY) providersQueue.push('openai')
    if (preferred !== 'claude' && this.env.CLAUDE_API_KEY) providersQueue.push('claude')

    // Remove duplicates
    const uniqueQueue = Array.from(new Set(providersQueue))

    let lastError: Error | null = null
    for (const providerName of uniqueQueue) {
      try {
        const provider = this.providers[providerName]
        return await provider.chat(messages, options)
      } catch (err: any) {
        console.error(`AI provider ${providerName} failed:`, err)
        lastError = err
      }
    }

    throw new Error(`All configured AI providers failed. Last error: ${lastError?.message}`)
  }
}
