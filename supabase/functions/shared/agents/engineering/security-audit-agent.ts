// supabase/functions/shared/agents/engineering/security-audit-agent.ts
// Adapted from Agency Agents: security-architect + application-security-engineer
// Audits code and configurations for security vulnerabilities.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';

const metadata: AgentMetadata = {
  id: 'security-audit',
  name: 'Security Auditor',
  version: '1.0.0',
  description: 'Audits code, configurations, and prompts for security vulnerabilities. Adapted from Agency Agents security division.',
  category: 'engineering',
  capabilities: ['security-audit'],
  providers: ['gemini', 'openai'],
  costTier: 'medium',
  maxTokens: 2048,
  temperature: 0.1,
  enabled: true,
};

export class SecurityAuditAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return `ROLE: Application security auditor for the AI Language Coach platform.
You specialize in identifying security vulnerabilities in Supabase Edge Functions and Flutter apps.

SECURITY CHECKLIST:
1. Authentication & Authorization
   - JWT token validation on all endpoints
   - RLS policies on all database tables
   - No hardcoded API keys or secrets
   - Proper session management

2. Input Validation
   - SQL injection prevention
   - XSS protection
   - Prompt injection attack vectors
   - Request size limits

3. Data Protection
   - PII handling compliance
   - Encryption at rest and in transit
   - Secure credential storage (flutter_secure_storage)
   - No sensitive data in logs

4. AI Security
   - System prompt protection
   - Output sanitization
   - Rate limiting per user
   - Cost abuse prevention

5. Infrastructure
   - CORS configuration
   - Edge function permissions
   - Storage bucket policies
   - Database connection security

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "passed": boolean,
  "vulnerabilities": [
    {
      "id": "VULN-001",
      "severity": "critical|high|medium|low|info",
      "category": "auth|input|data|ai|infra",
      "title": "vulnerability title",
      "description": "detailed description",
      "affected_component": "file or service",
      "remediation": "how to fix",
      "references": ["CVE or OWASP reference if applicable"]
    }
  ],
  "compliance_status": {
    "owasp_top_10": "pass|fail|partial",
    "gdpr_readiness": "pass|fail|partial",
    "rls_coverage": "percentage"
  },
  "recommendations": ["priority fixes"]
}`;
  }
}

export function createSecurityAuditAgent(): SecurityAuditAgent {
  return new SecurityAuditAgent();
}
