// supabase/functions/grammar-api/index.ts
// Grammar Topics, Rules & Exercise Evaluation
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, notFound, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequired, parsePagination } from '../shared/validator.ts'
import { getAIProvider } from '../shared/ai.ts'

const GRAMMAR_TOPICS = [
  {
    id: 'tenses',
    name: 'Tenses',
    description: 'Present, past, and future tenses in English',
    level: 'A1',
    rules: [
      {
        rule: 'Simple Present: Subject + base verb (+ s/es for third person)',
        examples: ['I walk to school.', 'She walks to school.'],
      },
      {
        rule: 'Present Continuous: Subject + am/is/are + verb-ing',
        examples: ['I am walking to school.', 'She is walking to school.'],
      },
      {
        rule: 'Simple Past: Subject + verb-ed (or irregular form)',
        examples: ['I walked to school.', 'She walked to school.'],
      },
    ],
  },
  {
    id: 'articles',
    name: 'Articles',
    description: 'Using a, an, and the correctly',
    level: 'A1',
    rules: [
      {
        rule: 'Use "a" before consonant sounds',
        examples: ['a cat', 'a university (sounds like "yoo-")'],
      },
      {
        rule: 'Use "an" before vowel sounds',
        examples: ['an apple', 'an hour (silent h)'],
      },
      {
        rule: 'Use "the" for specific or previously mentioned nouns',
        examples: ['the sun', 'the book I told you about'],
      },
    ],
  },
  {
    id: 'conditionals',
    name: 'Conditionals',
    description: 'Zero, first, second, third, and mixed conditionals',
    level: 'B1',
    rules: [
      {
        rule: 'Zero Conditional: If + present, present (general truths)',
        examples: ['If you heat water to 100°C, it boils.'],
      },
      {
        rule: 'First Conditional: If + present, will + base verb',
        examples: ['If it rains, I will take an umbrella.'],
      },
      {
        rule: 'Second Conditional: If + past simple, would + base verb',
        examples: ['If I had more time, I would learn Japanese.'],
      },
      {
        rule: 'Third Conditional: If + past perfect, would have + past participle',
        examples: ['If I had studied harder, I would have passed the exam.'],
      },
    ],
  },
  {
    id: 'passive-voice',
    name: 'Passive Voice',
    description: 'Forming passive sentences in different tenses',
    level: 'B1',
    rules: [
      {
        rule: 'Passive = object + be + past participle (+ by agent)',
        examples: ['The cake was baked by my mother.', 'English is spoken here.'],
      },
      {
        rule: 'Match the "be" form to the tense of the active sentence',
        examples: [
          'Present: is/are + past participle',
          'Past: was/were + past participle',
          'Future: will be + past participle',
        ],
      },
    ],
  },
  {
    id: 'relative-clauses',
    name: 'Relative Clauses',
    description: 'Defining and non-defining relative clauses',
    level: 'B1',
    rules: [
      {
        rule: 'Use who/that for people',
        examples: ['The woman who called you is my sister.'],
      },
      {
        rule: 'Use which/that for things',
        examples: ['The book which I read was amazing.'],
      },
      {
        rule: 'Non-defining clauses use commas (extra info)',
        examples: ['My brother, who lives in London, is visiting.'],
      },
    ],
  },
  {
    id: 'reported-speech',
    name: 'Reported Speech',
    description: 'Reporting what others have said',
    level: 'B2',
    rules: [
      {
        rule: 'Shift tenses back: present → past, past → past perfect',
        examples: [
          'Direct: "I am tired." → Reported: She said she was tired.',
          'Direct: "I went home." → Reported: He said he had gone home.',
        ],
      },
      {
        rule: 'Pronouns and time expressions also shift',
        examples: [
          'today → that day',
          'tomorrow → the next day / the following day',
          'here → there',
        ],
      },
    ],
  },
  {
    id: 'modal-verbs',
    name: 'Modal Verbs',
    description: 'Using can, could, may, might, must, should, etc.',
    level: 'A2',
    rules: [
      {
        rule: 'Can/Could: ability and possibility',
        examples: ['I can swim.', 'She could run fast when she was young.'],
      },
      {
        rule: 'Must/Have to: obligation and necessity',
        examples: ['You must wear a seatbelt.', 'I have to wake up early.'],
      },
      {
        rule: 'Should/Ought to: advice and recommendation',
        examples: ['You should eat more vegetables.', "You ought to apologize."],
      },
      {
        rule: 'May/Might: permission and possibility',
        examples: ['May I come in?', 'It might rain later.'],
      },
    ],
  },
]

function getTopicById(topicId: string) {
  return GRAMMAR_TOPICS.find((t) => t.id === topicId)
}

function filterByLevel(level: string | null) {
  if (!level) return GRAMMAR_TOPICS
  const upper = level.toUpperCase()
  return GRAMMAR_TOPICS.filter((t) => t.level === upper)
}

async function handleListTopics(url: URL): Promise<Response> {
  const level = url.searchParams.get('level')
  const { limit, offset } = parsePagination(url.searchParams)

  const filtered = filterByLevel(level)
  const paged = filtered.slice(offset, offset + limit)

  return successResponse(
    { items: paged, total: filtered.length, limit, offset },
    'Grammar topics retrieved successfully',
  )
}

async function handleGetTopic(topicId: string): Promise<Response> {
  const topic = getTopicById(topicId)
  if (!topic) {
    return notFound(`Grammar topic "${topicId}" not found`)
  }
  return successResponse(topic, 'Grammar topic retrieved successfully')
}

async function handleSubmitExercise(
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { topic_id, answers } = body

  const validation = validateRequired({ topic_id, answers })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  if (!Array.isArray(answers) || answers.length === 0) {
    return badRequest('answers must be a non-empty array')
  }

  const topic = getTopicById(topic_id)
  if (!topic) {
    return notFound(`Grammar topic "${topic_id}" not found`)
  }

  const provider = getAIProvider()

  const systemPrompt = `You are an English grammar tutor. Evaluate the user's answers for the grammar topic "${topic.name}".

Rules for this topic:
${topic.rules.map((r) => `- ${r.rule}`).join('\n')}

For each answer, determine if it is correct or incorrect. Provide:
- isCorrect: boolean
- corrected: the correct version if wrong, or the original if correct
- explanation: brief explanation of the grammar rule applied

Return a JSON array where each element corresponds to one answer, in the same order.
Also include an overall "score" (0-100) and a "summary" string.

Response format (JSON only, no markdown):
{
  "results": [
    { "isCorrect": true, "corrected": "...", "explanation": "..." },
    ...
  ],
  "score": 85,
  "summary": "..."
}`

  const answersText = answers
    .map((a: any, i: number) => `${i + 1}. Question: ${a.question}\n   Answer: ${a.answer}`)
    .join('\n\n')

  const userPrompt = `Evaluate these answers for the grammar topic "${topic.name}":\n\n${answersText}`

  try {
    const response = await provider.chatWithFallback(
      [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
      ],
      { temperature: 0.3, maxTokens: 2048 },
    )

    let parsed: any
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(response.content)
    } catch {
      return serverError('Failed to parse AI response for grammar evaluation')
    }

    return successResponse(
      {
        topic_id,
        topic_name: topic.name,
        results: parsed.results || [],
        score: parsed.score ?? 0,
        summary: parsed.summary ?? '',
        total_questions: answers.length,
      },
      'Grammar exercise evaluated successfully',
    )
  } catch (error) {
    console.error('Grammar evaluation error:', error)
    return serverError('Failed to evaluate grammar exercise')
  }
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const userId = authResult.user.id
    const url = new URL(req.url)
    const path = url.pathname

    const basePath = '/grammar-api'

    if (path === `${basePath}/grammar` && req.method === 'GET') {
      return await handleListTopics(url)
    }

    if (path === `${basePath}/grammar/submit` && req.method === 'POST') {
      return await handleSubmitExercise(userId, req)
    }

    const topicMatch = path.match(/^\/grammar-api\/grammar\/([a-z-]+)$/)
    if (topicMatch && req.method === 'GET') {
      return await handleGetTopic(topicMatch[1])
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Grammar API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
