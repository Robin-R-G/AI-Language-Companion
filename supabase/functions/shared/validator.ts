// supabase/functions/shared/validator.ts
// Request Validation Helpers

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

export function validateRequired(fields: Record<string, any>): ValidationResult {
  const errors: string[] = [];
  for (const [key, value] of Object.entries(fields)) {
    if (value === undefined || value === null || value === '') {
      errors.push(`Missing required field: ${key}`);
    }
  }
  return { isValid: errors.length === 0, errors };
}

export function validateString(value: any, fieldName: string, options?: {
  minLength?: number;
  maxLength?: number;
  pattern?: RegExp;
}): ValidationResult {
  const errors: string[] = [];
  if (typeof value !== 'string') {
    errors.push(`${fieldName} must be a string`);
    return { isValid: false, errors };
  }
  if (options?.minLength && value.length < options.minLength) {
    errors.push(`${fieldName} must be at least ${options.minLength} characters`);
  }
  if (options?.maxLength && value.length > options.maxLength) {
    errors.push(`${fieldName} must be at most ${options.maxLength} characters`);
  }
  if (options?.pattern && !options.pattern.test(value)) {
    errors.push(`${fieldName} format is invalid`);
  }
  return { isValid: errors.length === 0, errors };
}

export function validateNumber(value: any, fieldName: string, options?: {
  min?: number;
  max?: number;
  integer?: boolean;
}): ValidationResult {
  const errors: string[] = [];
  if (typeof value !== 'number' || isNaN(value)) {
    errors.push(`${fieldName} must be a number`);
    return { isValid: false, errors };
  }
  if (options?.min !== undefined && value < options.min) {
    errors.push(`${fieldName} must be at least ${options.min}`);
  }
  if (options?.max !== undefined && value > options.max) {
    errors.push(`${fieldName} must be at most ${options.max}`);
  }
  if (options?.integer && !Number.isInteger(value)) {
    errors.push(`${fieldName} must be an integer`);
  }
  return { isValid: errors.length === 0, errors };
}

export function validateEnum<T extends string>(value: any, fieldName: string, allowed: T[]): ValidationResult {
  const errors: string[] = [];
  if (!allowed.includes(value as T)) {
    errors.push(`${fieldName} must be one of: ${allowed.join(', ')}`);
  }
  return { isValid: errors.length === 0, errors };
}

export function combineValidations(...validations: ValidationResult[]): ValidationResult {
  const allErrors = validations.flatMap((v) => v.errors);
  return { isValid: allErrors.length === 0, errors: allErrors };
}
