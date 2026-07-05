# AI Language Coach
# AI Multi-Agent Framework

Version: 1.0
Status: Production
Last Updated: July 2026

---

## Purpose

This document defines the AI Multi-Agent System used throughout the application.

The objective is NOT to use one large AI model for everything.

Instead, every task should be delegated to specialized AI agents with clearly defined responsibilities.

This improves:
- Accuracy
- Educational quality
- Maintainability
- Lower AI cost
- Better personalization
- Faster responses
- Easier testing

---

## Core Principle

One Agent → One Responsibility → One Output → Reviewed by Another Agent

Never allow one agent to perform every task.

---

## Agent Roster

| Agent | Role | Stateful |
|-------|------|----------|
| Master Orchestrator | Coordinates all agents | Yes (Workflow) |
| User Profile | Maintains learner profile | Yes (DO) |
| Memory | Stores learning history | Yes (DO) |
| Curriculum Planner | Creates learning plans | Yes (DO) |
| Lesson Generator | Creates educational content | No (Stateless) |
| Vocabulary | Word/phrase generation | No (Stateless) |
| Grammar | Grammar explanations | No (Stateless) |
| Conversation | Dialogue generation | No (Stateless) |
| Pronunciation | Speech evaluation | No (Stateless) |
| Writing Coach | Essay review | No (Stateless) |
| Speaking Coach | Speaking interviews | No (Stateless) |
| Reading Coach | Reading exercises | No (Stateless) |
| Listening Coach | Listening exercises | No (Stateless) |
| Translation | L1 assistance | No (Stateless) |
| Exam Pattern | Exam-specific content | No (Stateless) |
| Difficulty Adjustment | CEFR level management | Yes (DO) |
| Motivation | Streaks & encouragement | Yes (DO) |
| Learning Analytics | Progress analysis | Yes (DO) |
| AI Safety | Content safety review | No (Stateless) |
| Copyright Compliance | Original content check | No (Stateless) |
| Prompt Optimizer | Token/cost optimization | No (Stateless) |
| Quality Reviewer | Output quality scoring | No (Stateless) |

---

## Agent Workflow

```
User
  ↓
Intent Detection
  ↓
Master Orchestrator
  ↓
Profile Agent → Memory Agent
  ↓
Specialized Agent(s)
  ↓
Safety Review → Quality Review
  ↓
Response Generation
  ↓
Learning Analytics Update → Memory Update
```

---

## Rules

Every agent must:
- Follow project documentation
- Use structured outputs
- Avoid hallucinations
- Admit uncertainty
- Explain reasoning when educationally useful
- Personalize where appropriate

---

## Success Criteria

The AI system succeeds when:
- Learning is personalized
- Responses are consistent
- AI costs remain sustainable
- Educational quality is high
- New agents can be added without affecting existing ones
