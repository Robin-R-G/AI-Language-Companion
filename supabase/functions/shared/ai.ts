// supabase/functions/shared/ai.ts
// AI Provider Abstraction Layer with OpenAI & Gemini Adapters

// ─── Unified Types ───────────────────────────────────────────────────────────

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface AIResponse {
  content: string;
  provider: string;
  model: string;
  tokensUsed: number;
  latencyMs: number;
}

export interface GrammarResult {
  isCorrect: boolean;
  original: string;
  corrected: string;
  explanation: string;
  explanationMalayalam: string;
  category: string;
  examples: string[];
}

export interface TranslationResult {
  translation: string;
  pronunciation: string;
  alternativeExpressions: { casual: string; formal: string };
  explanation: string;
}

export interface WritingEvaluation {
  estimatedBand: string;
  grammarScore: number;
  vocabularyScore: number;
  organizationScore: number;
  clarityScore: number;
  strengths: string[];
  mistakes: string[];
  improvedVersion: string;
  recommendations: string[];
}

export interface PronunciationEvaluation {
  fluencyScore: number;
  grammarScore: number;
  vocabularyScore: number;
  pronunciationScore: number;
  overallScore: number;
  feedback: string;
  strengths: string[];
  issues: string[];
  practiceWords: string[];
  shadowingExercise: string;
  estimatedProficiency: string;
}

export interface VocabularyWord {
  word: string;
  meaning: string;
  meaningMalayalam: string;
  pronunciation: string;
  exampleSentence: string;
  synonyms: string[];
  antonyms: string[];
  memoryTip: string;
  cefrLevel: string;
}

// ─── Provider Interface ──────────────────────────────────────────────────────

export abstract class AIProvider {
  abstract readonly name: string;
  abstract readonly models: {
    fast: string;
    standard: string;
    premium: string;
  };

  abstract chat(
    messages: ChatMessage[],
    options?: { model?: string; temperature?: number; maxTokens?: number; stream?: boolean }
  ): Promise<AIResponse>;

  abstract chatStream(
    messages: ChatMessage[],
    options?: { model?: string; temperature?: number; maxTokens?: number },
    onChunk?: (chunk: string) => void
  ): Promise<AIResponse>;
}

// ─── OpenAI Adapter ──────────────────────────────────────────────────────────

export class OpenAIProvider extends AIProvider {
  readonly name = 'openai';
  readonly models = {
    fast: 'gpt-4o-mini',
    standard: 'gpt-4o',
    premium: 'gpt-4o',
  };

  private apiKey: string;
  private baseUrl = 'https://api.openai.com/v1';

  constructor() {
    super();
    this.apiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
    if (!this.apiKey) {
      console.warn('OPENAI_API_KEY not set - OpenAI provider will fail');
    }
  }

  async chat(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number; stream?: boolean } = {}
  ): Promise<AIResponse> {
    const startTime = Date.now();
    const model = options.model ?? this.models.standard;

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages,
        temperature: options.temperature ?? 0.7,
        max_tokens: options.maxTokens ?? 2048,
        stream: false,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error (${response.status}): ${error}`);
    }

    const data = await response.json();
    const latencyMs = Date.now() - startTime;

    return {
      content: data.choices[0]?.message?.content ?? '',
      provider: this.name,
      model,
      tokensUsed: data.usage?.total_tokens ?? 0,
      latencyMs,
    };
  }

  async chatStream(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number } = {},
    onChunk?: (chunk: string) => void
  ): Promise<AIResponse> {
    const startTime = Date.now();
    const model = options.model ?? this.models.fast;

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages,
        temperature: options.temperature ?? 0.7,
        max_tokens: options.maxTokens ?? 2048,
        stream: true,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error (${response.status}): ${error}`);
    }

    let fullContent = '';
    let tokensUsed = 0;
    const reader = response.body!.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split('\n').filter((line) => line.startsWith('data: '));

      for (const line of lines) {
        const data = line.replace('data: ', '');
        if (data === '[DONE]') continue;

        try {
          const parsed = JSON.parse(data);
          const delta = parsed.choices?.[0]?.delta?.content;
          if (delta) {
            fullContent += delta;
            tokensUsed += 1;
            onChunk?.(delta);
          }
        } catch {
          // Skip malformed chunks
        }
      }
    }

    return {
      content: fullContent,
      provider: this.name,
      model,
      tokensUsed,
      latencyMs: Date.now() - startTime,
    };
  }
}

// ─── Gemini Adapter ──────────────────────────────────────────────────────────

export class GeminiProvider extends AIProvider {
  readonly name = 'gemini';
  readonly models = {
    fast: 'gemini-1.5-flash',
    standard: 'gemini-1.5-flash',
    premium: 'gemini-1.5-pro',
  };

  private apiKey: string;
  private baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  constructor() {
    super();
    this.apiKey = Deno.env.get('GEMINI_API_KEY') ?? '';
    if (!this.apiKey) {
      console.warn('GEMINI_API_KEY not set - Gemini provider will fail');
    }
  }

  private formatMessages(messages: ChatMessage[]): { contents: any[] } {
    const systemMsg = messages.find((m) => m.role === 'system');
    const chatMsgs = messages.filter((m) => m.role !== 'system');

    const contents = chatMsgs.map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    if (systemMsg) {
      contents.unshift({
        role: 'user',
        parts: [{ text: `[System Instructions]: ${systemMsg.content}` }],
      });
    }

    return { contents };
  }

  async chat(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number } = {}
  ): Promise<AIResponse> {
    const startTime = Date.now();
    const model = options.model ?? this.models.standard;
    const { contents } = this.formatMessages(messages);

    const response = await fetch(
      `${this.baseUrl}/models/${model}:generateContent?key=${this.apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents,
          generationConfig: {
            temperature: options.temperature ?? 0.7,
            maxOutputTokens: options.maxTokens ?? 2048,
          },
        }),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Gemini API error (${response.status}): ${error}`);
    }

    const data = await response.json();
    const latencyMs = Date.now() - startTime;
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

    return {
      content,
      provider: this.name,
      model,
      tokensUsed: data.usageMetadata?.totalTokenCount ?? 0,
      latencyMs,
    };
  }

  async chatStream(
    messages: ChatMessage[],
    options: { model?: string; temperature?: number; maxTokens?: number } = {},
    onChunk?: (chunk: string) => void
  ): Promise<AIResponse> {
    const startTime = Date.now();
    const model = options.model ?? this.models.fast;
    const { contents } = this.formatMessages(messages);

    const response = await fetch(
      `${this.baseUrl}/models/${model}:streamGenerateContent?alt=sse&key=${this.apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents,
          generationConfig: {
            temperature: options.temperature ?? 0.7,
            maxOutputTokens: options.maxTokens ?? 2048,
          },
        }),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Gemini API error (${response.status}): ${error}`);
    }

    let fullContent = '';
    let tokensUsed = 0;
    const reader = response.body!.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split('\n').filter((line) => line.startsWith('data: '));

      for (const line of lines) {
        const data = line.replace('data: ', '');
        try {
          const parsed = JSON.parse(data);
          const delta = parsed.candidates?.[0]?.content?.parts?.[0]?.text;
          if (delta) {
            fullContent += delta;
            tokensUsed += 1;
            onChunk?.(delta);
          }
        } catch {
          // Skip malformed chunks
        }
      }
    }

    return {
      content: fullContent,
      provider: this.name,
      model,
      tokensUsed,
      latencyMs: Date.now() - startTime,
    };
  }
}

// ─── Provider Factory with Fallback ──────────────────────────────────────────

export type ProviderName = 'openai' | 'gemini';

export class AIProviderFactory {
  private providers: Map<ProviderName, AIProvider> = new Map();
  private primaryProvider: ProviderName;
  private fallbackProvider: ProviderName;

  constructor(primary: ProviderName = 'openai', fallback: ProviderName = 'gemini') {
    this.primaryProvider = primary;
    this.fallbackProvider = fallback;
    this.providers.set('openai', new OpenAIProvider());
    this.providers.set('gemini', new GeminiProvider());
  }

  getProvider(name?: ProviderName): AIProvider {
    return this.providers.get(name ?? this.primaryProvider)!;
  }

  async chatWithFallback(
    messages: ChatMessage[],
    options: {
      model?: string;
      temperature?: number;
      maxTokens?: number;
      provider?: ProviderName;
      preferredProvider?: ProviderName;
    } = {}
  ): Promise<AIResponse> {
    const primary = options.preferredProvider ?? options.provider ?? this.primaryProvider;
    const fallback = primary === this.primaryProvider ? this.fallbackProvider : this.primaryProvider;

    try {
      const provider = this.getProvider(primary);
      return await provider.chat(messages, options);
    } catch (error) {
      console.error(`Primary provider (${primary}) failed:`, error);
      console.warn(`Falling back to ${fallback}...`);

      try {
        const fallbackProvider = this.getProvider(fallback);
        return await fallbackProvider.chat(messages, options);
      } catch (fallbackError) {
        console.error(`Fallback provider (${fallback}) also failed:`, fallbackError);
        throw new Error(`All AI providers failed. Primary: ${error}, Fallback: ${fallbackError}`);
      }
    }
  }

  async chatStreamWithFallback(
    messages: ChatMessage[],
    options: {
      model?: string;
      temperature?: number;
      maxTokens?: number;
      provider?: ProviderName;
      preferredProvider?: ProviderName;
    } = {},
    onChunk?: (chunk: string) => void
  ): Promise<AIResponse> {
    const primary = options.preferredProvider ?? options.provider ?? this.primaryProvider;
    const fallback = primary === this.primaryProvider ? this.fallbackProvider : this.primaryProvider;

    try {
      const provider = this.getProvider(primary);
      return await provider.chatStream(messages, options, onChunk);
    } catch (error) {
      console.error(`Primary stream provider (${primary}) failed:`, error);
      console.warn(`Falling back to ${fallback} for streaming...`);

      try {
        const fallbackProvider = this.getProvider(fallback);
        return await fallbackProvider.chatStream(messages, options, onChunk);
      } catch (fallbackError) {
        console.error(`Fallback stream provider (${fallback}) also failed:`, fallbackError);
        throw new Error(`All AI stream providers failed. Primary: ${error}, Fallback: ${fallbackError}`);
      }
    }
  }
}

// ─── Singleton ───────────────────────────────────────────────────────────────

let _factory: AIProviderFactory | null = null;

export function getAIProvider(): AIProviderFactory {
  if (!_factory) {
    const primary = (Deno.env.get('PRIMARY_AI_PROVIDER') as ProviderName) ?? 'gemini';
    const fallback = (Deno.env.get('FALLBACK_AI_PROVIDER') as ProviderName) ?? 'openai';
    _factory = new AIProviderFactory(primary, fallback);
  }
  return _factory;
}
