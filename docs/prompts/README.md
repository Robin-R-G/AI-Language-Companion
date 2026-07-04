# AI Language Coach — Prompt Library

**Location:** `docs/prompts/`
**Purpose:** Version-controlled, JSON-formatted prompt templates for all AI features.
**Status:** Draft (v1.0.0)
**Last Updated:** 2026-07-04

---

## Directory Structure

```
docs/prompts/
├── README.md                         # This file — library index
├── _templates/
│   └── new-prompt-schema.json        # Template for creating new prompts
├── system/
│   ├── global-system-prompt.json     # Shared baseline system prompt wrapper
│   └── l1-scaffolding.json           # CEFR-level-based L1 scaffolding rules
├── tutors/
│   ├── emma-friendly-esl.json        # Friendly English ESL tutor
│   ├── david-ielts-examiner.json     # Strict IELTS oral examiner
│   └── sophia-goethe-german.json     # Goethe German tutor
├── grammar/
│   └── grammar-correction.json       # JSON-enforced grammar parser
├── writing/
│   ├── ielts-writing.json            # IELTS Task 1 & Task 2 rubric
│   └── goethe-writing.json           # Goethe writing task rubric
├── speaking/
│   └── speaking-evaluation.json      # Pronunciation & fluency assessment
├── vocabulary/
│   └── vocabulary-template.json      # SRS vocabulary card generation
├── reading/
│   └── reading-lesson.json           # Reading passage & comprehension gen
├── listening/
│   └── listening-lesson.json         # Dictation & gap-fill exercise gen
├── flashcards/
│   └── flashcard-generation.json     # SRS flashcard generation
├── challenges/
│   └── daily-challenge.json          # Personalized daily challenge gen
└── errors/
    └── error-explanation.json        # Type-aware error breakdowns
```

## Template Format

Every prompt template is a JSON file with three top-level sections:

| Section | Description |
|---------|-------------|
| `metadata` | Version, author, CEFR range, supported models, cost estimate, status |
| `template` | System prompt, user template, output JSON schema, variable definitions |
| `testing` | Sample input/output pairs, test cases with validation assertions |

## Versioning

Prompts follow [SemVer](https://semver.org/):
- **MAJOR**: Breaking changes to output schemas or behavior
- **MINOR**: New features (new persona, new rubric criterion)
- **PATCH**: Minor fixes (tone adjustment, typo correction)

See `docs/20-Prompt-Versioning-Experiments.md` for full strategy.

## Lifecycle

1. **Draft** — Written in `docs/prompts/`, not yet deployed
2. **Review** — Audited by AI engineers and language teachers
3. **Testing** — Run benchmark suite against test cases
4. **Staging** — Deployed to staging Edge Functions
5. **Production** — Gradual rollout via feature flags
6. **Audit** — Weekly monitoring of quality metrics

## Key Reference Documents

| Document | Content |
|----------|---------|
| `docs/10-AI-Prompts.md` | Master system prompts (v1.0 production) |
| `docs/19-AI-Evaluation-Benchmark.md` | Evaluation metrics, benchmark datasets, quality targets |
| `docs/20-Prompt-Versioning-Experiments.md` | Versioning architecture, A/B testing, rollback procedures |
| `supabase/functions/shared/prompts.ts` | Production TypeScript runtime prompt builders |
