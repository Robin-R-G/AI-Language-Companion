// docs/prompts/_tests_/validate-templates.test.ts
// Automated validation of all prompt templates in docs/prompts/
// Run: deno test docs/prompts/_tests_/validate-templates.test.ts

import { assert, assertEquals, assertExists, assertMatch } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

interface TemplateMetadata {
  id: string
  version: string
  author: string
  created: string
  description: string
  models: string[]
  cost_estimate: string
  target_languages: string[]
  cefr_range: string
  status: string
}

interface TemplateTest {
  id: string
  description: string
  input: Record<string, unknown>
  validates: string[]
  expected_output_contains?: string
  expected_behavior?: string
}

interface TemplateFile {
  metadata: TemplateMetadata
  template: {
    system: string
    user_template: string
    output_schema: Record<string, unknown>
    variables: Record<string, string>
  }
  testing: {
    sample_input: Record<string, unknown>
    sample_output: Record<string, unknown>
    test_cases: TemplateTest[]
  }
}

const REQUIRED_METADATA_FIELDS: (keyof TemplateMetadata)[] = [
  'id', 'version', 'author', 'created', 'description', 'models', 'cost_estimate', 'target_languages', 'cefr_range', 'status',
]

const REQUIRED_TEMPLATE_FIELDS: (keyof TemplateFile['template'])[] = [
  'system', 'output_schema', 'variables',
]

const REQUIRED_TEST_FIELDS: (keyof TemplateTest)[] = [
  'id', 'description',
]

const VALID_STATUSES = ['draft', 'review', 'testing', 'staging', 'production']
const VALID_CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
const SEMVER_REGEX = /^\d+\.\d+\.\d+$/

// ─── Helpers ────────────────────────────────────────────────────────────────

function parseCefrRange(range: string): string[] {
  const parts = range.split('-')
  if (parts.length !== 2) return []
  const levels: string[] = []
  let started = false
  for (const level of VALID_CEFR_LEVELS) {
    if (level === parts[0].trim()) started = true
    if (started) levels.push(level)
    if (level === parts[1].trim()) break
  }
  return levels
}

// ─── Test Suite ─────────────────────────────────────────────────────────────

const templateFiles: string[] = []

// Recursively find all JSON template files (excluding the schema template and test files)
async function findTemplates(dir: string): Promise<string[]> {
  const files: string[] = []
  for await (const entry of Deno.readDir(dir)) {
    const path = `${dir}/${entry.name}`
    if (entry.isDirectory && !entry.name.startsWith('_')) {
      files.push(...await findTemplates(path))
    } else if (entry.isFile && entry.name.endsWith('.json') && entry.name !== 'new-prompt-schema.json') {
      files.push(path)
    }
  }
  return files
}

// Load and validate all templates
async function loadTemplates(): Promise<Map<string, TemplateFile>> {
  const baseDir = new URL('..', import.meta.url).pathname
  const files = await findTemplates(baseDir)
  const templates = new Map<string, TemplateFile>()

  for (const filePath of files) {
    const content = await Deno.readTextFile(filePath)
    try {
      const parsed: TemplateFile = JSON.parse(content)
      const relativePath = filePath.replace(baseDir, '')
      templates.set(relativePath, parsed)
    } catch (e) {
      throw new Error(`Failed to parse ${filePath}: ${e instanceof Error ? e.message : String(e)}`)
    }
  }

  return templates
}

let templates: Map<string, TemplateFile>

Deno.test('All template files should be valid JSON', async () => {
  templates = await loadTemplates()
  assert(templates.size > 0, `No template files found. Expected at least 1 template.`)
  console.log(`  Found ${templates.size} template files to validate.`)
})

Deno.test('Each template should have complete metadata', () => {
  for (const [path, tmpl] of templates) {
    for (const field of REQUIRED_METADATA_FIELDS) {
      assertExists(tmpl.metadata[field], `${path}: missing metadata.${field}`)
    }
    assertMatch(tmpl.metadata.version, SEMVER_REGEX, `${path}: metadata.version '${tmpl.metadata.version}' is not valid SemVer`)
    assert(tmpl.metadata.models.length > 0, `${path}: metadata.models must have at least one model`)
    assert(tmpl.metadata.target_languages.length > 0, `${path}: metadata.target_languages must have at least one language`)
    assert(VALID_STATUSES.includes(tmpl.metadata.status), `${path}: metadata.status '${tmpl.metadata.status}' is not valid (${VALID_STATUSES.join(', ')})`)

    const parsedLevels = parseCefrRange(tmpl.metadata.cefr_range)
    assert(parsedLevels.length > 0, `${path}: metadata.cefr_range '${tmpl.metadata.cefr_range}' is not a valid range`)
  }
})

Deno.test('Each template should have complete template section', () => {
  for (const [path, tmpl] of templates) {
    for (const field of REQUIRED_TEMPLATE_FIELDS) {
      assertExists(tmpl.template[field as keyof typeof tmpl.template], `${path}: missing template.${field}`)
    }
    assertEquals(typeof tmpl.template.system, 'string', `${path}: template.system must be a string`)
    assertEquals(typeof tmpl.template.output_schema, 'object', `${path}: template.output_schema must be an object`)

    // Variables must exist
    const vars = tmpl.template.variables
    assertEquals(typeof vars, 'object', `${path}: template.variables must be an object`)
    for (const [varName, varDesc] of Object.entries(vars)) {
      assertEquals(typeof varDesc, 'string', `${path}: template.variables.${varName} must be a string description`)
    }
  }
})

Deno.test('Each template should have test cases', () => {
  for (const [path, tmpl] of templates) {
    assertExists(tmpl.testing, `${path}: missing testing section`)
    assertExists(tmpl.testing.sample_input, `${path}: missing testing.sample_input`)
    assertExists(tmpl.testing.sample_output, `${path}: missing testing.sample_output`)
    assert(tmpl.testing.test_cases.length >= 1, `${path}: must have at least 1 test case`)

    for (const tc of tmpl.testing.test_cases) {
      for (const field of REQUIRED_TEST_FIELDS) {
        assertExists(tc[field], `${path}: test case '${tc.id}': missing field '${field}'`)
      }
      assert(tc.validates.length >= 1, `${path}: test case '${tc.id}': must have at least 1 validation assertion`)
    }
  }
})

Deno.test('Output schemas should define required fields and types', () => {
  for (const [path, tmpl] of templates) {
    const schema = tmpl.template.output_schema as Record<string, unknown>
    // Skip templates with empty output_schema (e.g., global system prompt)
    if (Object.keys(schema).length === 0) continue

    if (schema.required) {
      const required = schema.required as string[]
      assert(Array.isArray(required), `${path}: output_schema.required must be an array`)
      assert(required.length >= 1, `${path}: output_schema.required must have at least one field`)
    }

    if (schema.properties) {
      const props = schema.properties as Record<string, unknown>
      for (const [propName, propDef] of Object.entries(props)) {
        const def = propDef as Record<string, unknown>
        assertExists(def.type, `${path}: output_schema.properties.${propName} missing type`)
        if (def.type === 'array') {
          assertExists(def.items, `${path}: output_schema.properties.${propName} is array but missing items`)
        }
      }
    }
  }
})

Deno.test('Global system prompt should contain injection shield', () => {
  const globalTmpl = templates.get('/system/global-system-prompt.json')
  if (globalTmpl) {
    assert(globalTmpl.template.system.includes('prompt injection shield'.toLowerCase()) ||
           globalTmpl.template.system.toLowerCase().includes('injection'),
           'Global system prompt must contain injection shield rules')
    assert(globalTmpl.template.system.includes('CONTEXT VARIABLES'),
           'Global system prompt must define CONTEXT VARIABLES')
  }
})

Deno.test('L1 scaffolding rules should cover all CEFR levels', () => {
  const l1Tmpl = templates.get('/system/l1-scaffolding.json')
  if (l1Tmpl) {
    for (const level of ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
      assert(l1Tmpl.template.system.includes(level),
             `L1 scaffolding must reference CEFR level ${level}`)
    }
    // Should reference the fading decay model
    assert(l1Tmpl.template.system.includes('DECAY'),
           'L1 scaffolding must include a decay/ fade model')
  }
})

Deno.test('All V1.0.0 templates should have same created date', () => {
  const createdDates = new Set<string>()
  for (const [, tmpl] of templates) {
    if (tmpl.metadata.version === '1.0.0') {
      createdDates.add(tmpl.metadata.created)
    }
  }
  // All templates created in this batch should share the same date
  assert(createdDates.size <= 2, `Found ${createdDates.size} different created dates for v1.0.0 templates (expected 1, or 2 if some were pre-existing): ${[...createdDates].join(', ')}`)
})

Deno.test('Tutor persona templates should reference appropriate output schemas', () => {
  const tutorFiles = ['/tutors/emma-friendly-esl.json', '/tutors/david-ielts-examiner.json', '/tutors/sophia-goethe-german.json']
  for (const tf of tutorFiles) {
    const tmpl = templates.get(tf)
    if (tmpl) {
      const schema = tmpl.template.output_schema as Record<string, unknown>
      assertExists(schema.properties, `${tf}: output_schema must define properties`)
      const props = schema.properties as Record<string, unknown>
      assertExists(props['message'], `${tf}: output_schema must include 'message' property for conversational response`)
    }
  }
})

Deno.test('IELTS writing template must include score disclaimer', () => {
  const ieltsTmpl = templates.get('/writing/ielts-writing.json')
  if (ieltsTmpl) {
    assert(ieltsTmpl.template.system.includes('advisory'),
           'IELTS writing template must include disclaimer about advisory estimates')
    const schema = ieltsTmpl.template.output_schema as Record<string, unknown>
    const props = schema.properties as Record<string, unknown>
    const disclaimerProp = props['disclaimer'] as Record<string, unknown> | undefined
    assertExists(disclaimerProp, 'IELTS writing output_schema must have a disclaimer property')
    if (disclaimerProp?.description) {
      assert((disclaimerProp.description as string).includes('NOT an official IELTS result'),
             'Disclaimer must state scores are NOT official IELTS results')
    }
  }
})

Deno.test('Grammar correction template should support both English and German', () => {
  const grammarTmpl = templates.get('/grammar/grammar-correction.json')
  if (grammarTmpl) {
    assert(grammarTmpl.metadata.target_languages.includes('en'),
           'Grammar template must support English')
    assert(grammarTmpl.metadata.target_languages.includes('de'),
           'Grammar template must support German')
    assert(grammarTmpl.template.system.includes('German'),
           'Grammar template must reference German-specific grammar concerns (cases, separable prefixes, verb-second)')
  }
})

Deno.test('Spaced repetition flashcard template should produce SRS-compatible output', () => {
  const flashTmpl = templates.get('/flashcards/flashcard-generation.json')
  if (flashTmpl) {
    const schema = flashTmpl.template.output_schema as Record<string, unknown>
    const props = schema.properties as Record<string, unknown>
    const cardsProp = props['cards'] as Record<string, unknown> | undefined
    assertExists(cardsProp, 'Flashcard template must have cards array in output_schema')
    if (cardsProp && typeof cardsProp === 'object') {
      const items = (cardsProp as Record<string, unknown>)['items'] as Record<string, unknown> | undefined
      assertExists(items, 'Flashcard cards property must define items schema')
      if (items) {
        const itemProps = items['properties'] as Record<string, unknown> | undefined
        assertExists(itemProps, 'Flashcard card items must define properties')
        if (itemProps) {
          assertExists((itemProps as Record<string, unknown>)['front'], 'Each flashcard must have a front property')
          assertExists((itemProps as Record<string, unknown>)['back'], 'Each flashcard must have a back property')
        }
      }
    }
  }
})

Deno.test('All test cases should reference real template variables', () => {
  for (const [path, tmpl] of templates) {
    const vars = new Set(Object.keys(tmpl.template.variables))
    // Check test case inputs reference defined variables
    for (const tc of tmpl.testing.test_cases) {
      for (const [key] of Object.entries(tc.input)) {
        // Some test cases may have test-only keys (like 'mode', 'expected')
        // that are not template variables — that's OK
        if (key !== 'mode' && key !== 'expected_output_contains' && key !== 'expected_behavior') {
          assert(vars.has(key) || ['target_language', 'native_language', 'learning_level', 'target_exam'].includes(key),
                 `${path}: test case '${tc.id}' references variable '${key}' which is not in template.variables`)
        }
      }
    }
  }
})

Deno.test('All templates should have unique IDs across the library', () => {
  const ids = new Map<string, string>()
  for (const [path, tmpl] of templates) {
    if (ids.has(tmpl.metadata.id)) {
      assert(false, `Duplicate template ID '${tmpl.metadata.id}' in ${path} (also in ${ids.get(tmpl.metadata.id)})`)
    }
    ids.set(tmpl.metadata.id, path)
  }
})

console.log('Template validation test file loaded. Run with: deno test docs/prompts/_tests_/validate-templates.test.ts')
