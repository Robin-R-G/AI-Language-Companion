// supabase/functions/shared/validator.ts
export interface ValidationResult {
  isValid: boolean
  errors: string[]
}

export function validateRequired(fields: Record<string, unknown>): ValidationResult {
  const errors: string[] = []

  for (const [key, value] of Object.entries(fields)) {
    if (value === undefined || value === null || value === '') {
      errors.push(`${key} is required`)
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  }
}

export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

export function validatePassword(password: string): ValidationResult {
  const errors: string[] = []

  if (password.length < 8) {
    errors.push('Password must be at least 8 characters')
  }
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter')
  }
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter')
  }
  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number')
  }

  return {
    isValid: errors.length === 0,
    errors,
  }
}

export function validateEnum<T extends string>(value: string, validValues: T[]): boolean {
  return validValues.includes(value as T)
}

export function sanitizeString(input: string): string {
  return input.trim().replace(/[<>]/g, '')
}

export function parsePagination(params: URLSearchParams): { limit: number; offset: number } {
  const limit = Math.min(Math.max(parseInt(params.get('limit') || '20'), 1), 100)
  const offset = Math.max(parseInt(params.get('offset') || '0'), 0)
  return { limit, offset }
}
