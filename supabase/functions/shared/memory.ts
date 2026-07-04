// supabase/functions/shared/memory.ts
// Conversation Memory & Context Management

import { ChatMessage } from './ai.ts';

// ─── Memory Types ────────────────────────────────────────────────────────────

export interface ConversationContext {
  conversationId: string;
  userId: string;
  recentMessages: ChatMessage[];
  userProfile: UserProfile | null;
  memories: MemoryEntry[];
}

export interface UserProfile {
  id: string;
  fullName: string;
  nativeLanguage: string;
  targetLanguage: string;
  proficiencyLevel: string;
  targetExam: string;
  dailyGoalMinutes: number;
}

export interface MemoryEntry {
  id: string;
  memoryType: string;
  content: string;
  importance: number;
}

// ─── Context Builder ─────────────────────────────────────────────────────────

const MAX_RECENT_TURNS = 10;
const MAX_CONTEXT_TOKENS = 3000;

export class ConversationMemory {
  private supabase: any;

  constructor(supabaseClient: any) {
    this.supabase = supabaseClient;
  }

  /**
   * Load full conversation context for an AI request.
   */
  async loadContext(
    conversationId: string,
    userId: string
  ): Promise<ConversationContext> {
    const [recentMessages, userProfile, memories] = await Promise.all([
      this.loadRecentMessages(conversationId),
      this.loadUserProfile(userId),
      this.loadMemories(userId),
    ]);

    return {
      conversationId,
      userId,
      recentMessages: this.truncateContext(recentMessages),
      userProfile,
      memories,
    };
  }

  /**
   * Load recent chat messages for a conversation.
   */
  private async loadRecentMessages(conversationId: string): Promise<ChatMessage[]> {
    const { data, error } = await this.supabase
      .from('chat_messages')
      .select('role, content')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: false })
      .limit(MAX_RECENT_TURNS);

    if (error) {
      console.error('Failed to load messages:', error);
      return [];
    }

    return (data || [])
      .reverse()
      .map((msg: any) => ({
        role: msg.role as 'user' | 'assistant',
        content: msg.content,
      }));
  }

  /**
   * Load user profile for personalization.
   */
  private async loadUserProfile(userId: string): Promise<UserProfile | null> {
    const { data, error } = await this.supabase
      .from('user_profiles')
      .select('*')
      .eq('auth_user_id', userId)
      .single();

    if (error || !data) {
      console.error('Failed to load user profile:', error);
      return null;
    }

    return {
      id: data.id,
      fullName: data.full_name,
      nativeLanguage: data.native_language,
      targetLanguage: data.target_language,
      proficiencyLevel: data.proficiency_level,
      targetExam: data.target_exam,
      dailyGoalMinutes: 20,
    };
  }

  /**
   * Load AI memory entries for the user.
   */
  private async loadMemories(userId: string): Promise<MemoryEntry[]> {
    const { data: profile } = await this.supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single();

    if (!profile) return [];

    const { data, error } = await this.supabase
      .from('ai_memory')
      .select('*')
      .eq('user_id', profile.id)
      .order('importance', { ascending: false })
      .limit(10);

    if (error) {
      console.error('Failed to load memories:', error);
      return [];
    }

    return (data || []).map((m: any) => ({
      id: m.id,
      memoryType: m.memory_type,
      content: m.content,
      importance: m.importance,
    }));
  }

  /**
   * Save a new memory entry.
   */
  async saveMemory(
    userId: string,
    memoryType: string,
    content: string,
    importance: number = 1
  ): Promise<void> {
    const { data: profile } = await this.supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single();

    if (!profile) return;

    await this.supabase.from('ai_memory').insert({
      user_id: profile.id,
      memory_type: memoryType,
      content,
      importance,
    });
  }

  /**
   * Save a chat message to the database.
   */
  async saveMessage(
    conversationId: string,
    role: 'user' | 'assistant',
    content: string,
    metadata?: {
      grammarFeedback?: any;
      translation?: any;
      tokenCount?: number;
      latencyMs?: number;
    }
  ): Promise<void> {
    const insertData: any = {
      conversation_id: conversationId,
      role,
      content,
    };

    if (metadata?.grammarFeedback) {
      insertData.grammar_feedback = metadata.grammarFeedback;
    }
    if (metadata?.translation) {
      insertData.translation = metadata.translation;
    }
    if (metadata?.tokenCount) {
      insertData.token_count = metadata.tokenCount;
    }
    if (metadata?.latencyMs) {
      insertData.latency_ms = metadata.latencyMs;
    }

    const { error } = await this.supabase.from('chat_messages').insert(insertData);
    if (error) {
      console.error('Failed to save message:', error);
    }
  }

  /**
   * Create a new conversation.
   */
  async createConversation(
    userId: string,
    title: string,
    provider: string,
    model: string
  ): Promise<string | null> {
    const { data: profile } = await this.supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single();

    if (!profile) return null;

    const { data, error } = await this.supabase
      .from('ai_conversations')
      .insert({
        user_id: profile.id,
        title,
        provider,
        model,
      })
      .select('id')
      .single();

    if (error) {
      console.error('Failed to create conversation:', error);
      return null;
    }

    return data?.id ?? null;
  }

  /**
   * Truncate context to fit within token limits.
   */
  private truncateContext(messages: ChatMessage[]): ChatMessage[] {
    let totalChars = 0;
    const truncated: ChatMessage[] = [];

    for (let i = messages.length - 1; i >= 0; i--) {
      const msg = messages[i];
      totalChars += msg.content.length;
      if (totalChars > MAX_CONTEXT_TOKENS * 4) break;
      truncated.unshift(msg);
    }

    return truncated;
  }
}

// ─── Memory Extraction ───────────────────────────────────────────────────────

/**
 * Extract learning insights from a conversation turn to store as memories.
 */
export function extractMemoryInsights(
  userMessage: string,
  aiResponse: string,
  grammarFeedback?: any
): { type: string; content: string; importance: number }[] {
  const insights: { type: string; content: string; importance: number }[] = [];

  if (grammarFeedback && !grammarFeedback.is_correct) {
    insights.push({
      type: 'grammar_weakness',
      content: `User made a ${grammarFeedback.category || 'grammar'} error: "${grammarFeedback.original}" → "${grammarFeedback.corrected}". Rule: ${grammarFeedback.explanation}`,
      importance: 3,
    });
  }

  const lowerMsg = userMessage.toLowerCase();
  if (lowerMsg.includes('i don\'t understand') || lowerMsg.includes('can you explain')) {
    insights.push({
      type: 'learning_gap',
      content: `User requested clarification on a topic. Review area of confusion.`,
      importance: 2,
    });
  }

  return insights;
}
