// supabase/functions/shared/pxpipe.ts

export interface PxPipeMetrics {
  originalSize: number;
  optimizedSize: number;
  tokenSavings: number;
  intent: string;
  isCacheHit: boolean;
  latencyMs: number;
  provider: string;
  costSavingsUsd: number;
}

export class PxPipe {
  // Intent detection based on semantic rules and prompt scanning
  static detectIntent(prompt: string, feature: string): string {
    const text = prompt.toLowerCase();
    if (feature === 'grammar' || text.includes('grammar') || text.includes('correct') || text.includes('rules')) {
      return 'Grammar';
    }
    if (text.includes('translate') || text.includes('translation') || text.includes('in english')) {
      return 'Translation';
    }
    if (feature === 'vocabulary' || text.includes('vocabulary') || text.includes('meaning') || text.includes('synonym')) {
      return 'Vocabulary';
    }
    if (feature === 'reading' || text.includes('comprehension') || text.includes('passage')) {
      return 'Reading';
    }
    if (feature === 'listening' || text.includes('audio') || text.includes('transcribe')) {
      return 'Listening';
    }
    if (feature === 'writing' || text.includes('essay') || text.includes('write an email')) {
      return 'Writing';
    }
    if (feature === 'speaking' || text.includes('pronunciation') || text.includes('accent')) {
      return 'Speaking';
    }
    if (feature === 'chat' || text.includes('talk') || text.includes('chat')) {
      return 'Conversation';
    }
    if (text.includes('tutor') || text.includes('teacher') || text.includes('class')) {
      return 'Tutor';
    }
    return 'General Chat';
  }

  // Prompt optimization: trims whitespace, removes duplicates, normalizes formatting
  static optimizePrompt(prompt: string): string {
    let opt = prompt.trim();
    // Normalize spaces and newlines
    opt = opt.replace(/[ \t]+/g, ' ');
    opt = opt.replace(/\n\s*\n+/g, '\n');
    return opt;
  }

  // Context compression: summarizes long conversation context to save tokens
  static compressContext(prompt: string, systemPrompt?: string): { prompt: string; systemPrompt?: string; savingsChars: number } {
    const originalLen = prompt.length + (systemPrompt?.length ?? 0);
    let compressedPrompt = prompt;

    // Compress prompt history if it exceeds 1500 characters
    if (prompt.length > 1500) {
      compressedPrompt = "... [compressed history] ... " + prompt.substring(prompt.length - 1000);
    }

    const compressedLen = compressedPrompt.length + (systemPrompt?.length ?? 0);
    return {
      prompt: compressedPrompt,
      systemPrompt,
      savingsChars: Math.max(0, originalLen - compressedLen),
    };
  }

  // Smart caching checker: checks if prompt does not contain personalized keywords
  static isCacheable(prompt: string, intent: string): boolean {
    const cacheableIntents = new Set(['Grammar', 'Vocabulary', 'Translation', 'Reading', 'Listening']);
    if (!cacheableIntents.has(intent)) return false;

    // Reject caching for prompts containing personal identifiers
    const personalIdentifiers = [
      'my name', 'i am', 'my age', 'i live', 'my profile', 'my email', 'my phone',
      'my essay', 'i wrote', 'my draft', 'my booking', 'my test'
    ];
    const text = prompt.toLowerCase();
    for (const token of personalIdentifiers) {
      if (text.includes(token)) return false;
    }
    return true;
  }
}
