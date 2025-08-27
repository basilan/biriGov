/**
 * Environment Configuration
 * Type-safe access to environment variables for Healthcare AI Governance Agent
 */

interface EnvironmentConfig {
  // API Configuration
  API_BASE_URL: string
  API_TIMEOUT: number
  AWS_REGION: string

  // Healthcare AI Configuration
  OPENAI_MODEL: string
  MAX_CLAIMS_PER_SESSION: number
  DEMO_BUDGET_LIMIT: number

  // Cost Tracking
  COST_ALERT_THRESHOLD: number
  COST_WARNING_THRESHOLD: number

  // Session Configuration
  SESSION_TIMEOUT_MINUTES: number
  AUTO_REFRESH_INTERVAL: number

  // Development Configuration
  ENABLE_DEV_TOOLS: boolean
  ENABLE_MOCK_DATA: boolean
  LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error'

  // Executive Presentation Settings
  COMPANY_NAME: string
  DEMO_EXECUTIVE_NAME: string
  DEMO_MODE: boolean

  // Healthcare Compliance
  HIPAA_COMPLIANT_LOGGING: boolean
  AUDIT_TRAIL_ENABLED: boolean

  // Performance Monitoring
  PERFORMANCE_MONITORING: boolean
  ERROR_REPORTING: boolean

  // Application Metadata
  APP_VERSION: string
  APP_BUILD_DATE: string
  APP_ENVIRONMENT: 'development' | 'staging' | 'production'
}

// Helper function to parse boolean environment variables
const parseBoolean = (value: string | undefined, defaultValue: boolean = false): boolean => {
  if (!value) return defaultValue
  return value.toLowerCase() === 'true' || value === '1'
}

// Helper function to parse numeric environment variables
const parseNumber = (value: string | undefined, defaultValue: number): number => {
  if (!value) return defaultValue
  const parsed = Number(value)
  return isNaN(parsed) ? defaultValue : parsed
}

// Environment configuration with type safety and defaults
export const env: EnvironmentConfig = {
  // API Configuration
  API_BASE_URL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000',
  API_TIMEOUT: parseNumber(import.meta.env.VITE_API_TIMEOUT, 30000),
  AWS_REGION: import.meta.env.VITE_AWS_REGION || 'us-west-2',

  // Healthcare AI Configuration
  OPENAI_MODEL: import.meta.env.VITE_OPENAI_MODEL || 'gpt-4',
  MAX_CLAIMS_PER_SESSION: parseNumber(import.meta.env.VITE_MAX_CLAIMS_PER_SESSION, 100),
  DEMO_BUDGET_LIMIT: parseNumber(import.meta.env.VITE_DEMO_BUDGET_LIMIT, 50.0),

  // Cost Tracking
  COST_ALERT_THRESHOLD: parseNumber(import.meta.env.VITE_COST_ALERT_THRESHOLD, 45.0),
  COST_WARNING_THRESHOLD: parseNumber(import.meta.env.VITE_COST_WARNING_THRESHOLD, 35.0),

  // Session Configuration
  SESSION_TIMEOUT_MINUTES: parseNumber(import.meta.env.VITE_SESSION_TIMEOUT_MINUTES, 60),
  AUTO_REFRESH_INTERVAL: parseNumber(import.meta.env.VITE_AUTO_REFRESH_INTERVAL, 30000),

  // Development Configuration
  ENABLE_DEV_TOOLS: parseBoolean(import.meta.env.VITE_ENABLE_DEV_TOOLS, import.meta.env.DEV),
  ENABLE_MOCK_DATA: parseBoolean(import.meta.env.VITE_ENABLE_MOCK_DATA, import.meta.env.DEV),
  LOG_LEVEL: (import.meta.env.VITE_LOG_LEVEL as any) || (import.meta.env.DEV ? 'debug' : 'info'),

  // Executive Presentation Settings
  COMPANY_NAME: import.meta.env.VITE_COMPANY_NAME || 'Healthcare Corporation',
  DEMO_EXECUTIVE_NAME: import.meta.env.VITE_DEMO_EXECUTIVE_NAME || 'Healthcare Executive',
  DEMO_MODE: parseBoolean(import.meta.env.VITE_DEMO_MODE, true),

  // Healthcare Compliance
  HIPAA_COMPLIANT_LOGGING: parseBoolean(import.meta.env.VITE_HIPAA_COMPLIANT_LOGGING, !import.meta.env.DEV),
  AUDIT_TRAIL_ENABLED: parseBoolean(import.meta.env.VITE_AUDIT_TRAIL_ENABLED, true),

  // Performance Monitoring
  PERFORMANCE_MONITORING: parseBoolean(import.meta.env.VITE_PERFORMANCE_MONITORING, true),
  ERROR_REPORTING: parseBoolean(import.meta.env.VITE_ERROR_REPORTING, !import.meta.env.DEV),

  // Application Metadata
  APP_VERSION: import.meta.env.VITE_APP_VERSION || '1.0.0',
  APP_BUILD_DATE: import.meta.env.VITE_APP_BUILD_DATE || new Date().toISOString(),
  APP_ENVIRONMENT: (import.meta.env.VITE_APP_ENVIRONMENT as any) || (import.meta.env.DEV ? 'development' : 'production')
}

// Validation for required environment variables
const requiredEnvVars = [
  'API_BASE_URL',
  'AWS_REGION',
  'DEMO_BUDGET_LIMIT'
] as const

// Validate environment configuration
export const validateEnvironment = (): void => {
  const missing: string[] = []
  
  for (const key of requiredEnvVars) {
    if (!env[key]) {
      missing.push(key)
    }
  }
  
  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}\n` +
      'Please check your .env file and ensure all required variables are set.'
    )
  }
  
  // Validate budget constraints for healthcare demos
  if (env.DEMO_BUDGET_LIMIT <= 0 || env.DEMO_BUDGET_LIMIT > 100) {
    console.warn('⚠️ Demo budget limit should be between $1-$100 for healthcare demonstrations')
  }
  
  if (env.COST_ALERT_THRESHOLD >= env.DEMO_BUDGET_LIMIT) {
    console.warn('⚠️ Cost alert threshold should be less than demo budget limit')
  }
  
  if (import.meta.env.DEV) {
    console.info('🏥 Healthcare AI Governance Agent - Environment Configuration')
    console.info(`   Environment: ${env.APP_ENVIRONMENT}`)
    console.info(`   API Base URL: ${env.API_BASE_URL}`)
    console.info(`   Demo Budget: $${env.DEMO_BUDGET_LIMIT}`)
    console.info(`   Mock Data: ${env.ENABLE_MOCK_DATA ? 'Enabled' : 'Disabled'}`)
    console.info(`   HIPAA Logging: ${env.HIPAA_COMPLIANT_LOGGING ? 'Enabled' : 'Disabled'}`)
  }
}

// Initialize environment validation
validateEnvironment()