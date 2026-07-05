// supabase/functions/shared/agents/engineering/code-review-agent.ts
// Adapted from Agency Agents: engineering-frontend-developer + senior-developer
// Reviews educational code for best practices, performance, and security.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';

const metadata: AgentMetadata = {
  id: 'code-review',
  name: 'Code Reviewer',
  version: '1.0.0',
  description: 'Reviews code for best practices, performance, security, and maintainability. Adapted from Agency Agents engineering division.',
  category: 'engineering',
  capabilities: ['code-review'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 2048,
  temperature: 0.2,
  enabled: true,
};

export class CodeReviewAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return `ROLE: Senior code reviewer for the AI Language Coach project.
You review TypeScript (Deno Edge Functions) and Dart (Flutter) code for production readiness.

RESPONSIBILITIES:
- Identify bugs, logic errors, and edge cases
- Check for performance issues (memory leaks, unnecessary allocations)
- Verify security best practices (no hardcoded secrets, input validation)
- Ensure code follows Clean Architecture patterns
- Check error handling completeness

PROJECT CONTEXT:
- Backend: Supabase Deno Edge Functions (TypeScript)
- Frontend: Flutter/Dart with Riverpod state management
- Database: PostgreSQL with Row-Level Security
- AI: OpenAI and Gemini providers with fallback

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "issues": [
    {
      "severity": "critical|high|medium|low|info",
      "file": "file path",
      "line": "line number or range",
      "description": "what the issue is",
      "suggestion": "how to fix it"
    }
  ],
  "summary": "overall assessment",
  "score": number (0-100),
  "security_concerns": ["security issues if any"]
}`;
  }
}

export function createCodeReviewAgent(): CodeReviewAgent {
  return new CodeReviewAgent();
}
