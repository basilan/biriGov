/**
 * Healthcare constants for medical codes, claim processing, and business metrics
 * Used across frontend and backend for consistent healthcare data handling
 */

/**
 * Common CPT procedure codes for demonstration scenarios
 */
export const CPT_CODES = {
  /** CT scan of lumbar spine without contrast */
  CT_LUMBAR_SPINE_NO_CONTRAST: '72148',
  
  /** CT scan of lumbar spine with contrast */
  CT_LUMBAR_SPINE_WITH_CONTRAST: '72149',
  
  /** MRI of lumbar spine without contrast */
  MRI_LUMBAR_SPINE_NO_CONTRAST: '72148',
  
  /** Diagnostic imaging of chest */
  CHEST_X_RAY: '71020',
  
  /** Office visit - established patient */
  OFFICE_VISIT_ESTABLISHED: '99213'
} as const;

/**
 * Common ICD-10 diagnosis codes for demonstration scenarios
 */
export const ICD10_CODES = {
  /** Low back pain, unspecified */
  LOW_BACK_PAIN: 'M54.5',
  
  /** Chronic pain due to trauma */
  CHRONIC_PAIN_TRAUMA: 'G89.21',
  
  /** Intervertebral disc disorder with radiculopathy */
  DISC_DISORDER_RADICULOPATHY: 'M50.1',
  
  /** Essential hypertension */
  ESSENTIAL_HYPERTENSION: 'I10',
  
  /** Type 2 diabetes mellitus */
  TYPE_2_DIABETES: 'E11.9'
} as const;

/**
 * Manual review cost benchmarks for ROI calculations
 */
export const COST_BENCHMARKS = {
  /** Average manual review cost per claim (USD) */
  MANUAL_REVIEW_COST_MIN: 15,
  MANUAL_REVIEW_COST_MAX: 25,
  MANUAL_REVIEW_COST_AVG: 20,
  
  /** Target AI processing cost per claim (USD) */
  AI_PROCESSING_COST_TARGET: 3,
  
  /** Maximum demo session budget (USD) */
  MAX_DEMO_BUDGET: 50,
  
  /** Budget warning threshold (USD) */
  BUDGET_WARNING_THRESHOLD: 45,
  
  /** Target cost reduction percentage */
  TARGET_COST_REDUCTION: 60
} as const;

/**
 * Processing time benchmarks for performance metrics
 */
export const TIME_BENCHMARKS = {
  /** Manual review time (days) */
  MANUAL_REVIEW_DAYS_MIN: 3,
  MANUAL_REVIEW_DAYS_MAX: 7,
  
  /** Target AI processing time (minutes) */
  AI_PROCESSING_TIME_TARGET: 2,
  
  /** Maximum acceptable processing time (minutes) */
  AI_PROCESSING_TIME_MAX: 5,
  
  /** Demo cycle time limit (minutes) */
  DEMO_CYCLE_TIME_LIMIT: 5
} as const;

/**
 * OpenAI API configuration constants
 */
export const OPENAI_CONFIG = {
  /** Primary model for medical reasoning */
  PRIMARY_MODEL: 'gpt-4',
  
  /** Fallback model for cost optimization */
  FALLBACK_MODEL: 'gpt-3.5-turbo',
  
  /** Max tokens for healthcare responses */
  MAX_TOKENS: 1000,
  
  /** Temperature for consistent medical reasoning */
  TEMPERATURE: 0.1,
  
  /** Estimated cost per token (USD) */
  COST_PER_TOKEN: 0.00003
} as const;

/**
 * NVIDIA AI Enterprise configuration constants
 */
export const NVIDIA_CONFIG = {
  /** Compliance validation timeout (seconds) */
  COMPLIANCE_TIMEOUT: 90,
  
  /** Maximum retry attempts */
  MAX_RETRIES: 3,
  
  /** Estimated cost per compliance check (USD) */
  COST_PER_COMPLIANCE_CHECK: 0.10
} as const;

/**
 * Healthcare regulatory frameworks for compliance checking
 */
export const REGULATORY_FRAMEWORKS = {
  HIPAA: 'Health Insurance Portability and Accountability Act',
  FDA: 'Food and Drug Administration',
  CMS: 'Centers for Medicare & Medicaid Services',
  HITECH: 'Health Information Technology for Economic and Clinical Health Act'
} as const;

/**
 * Demo scenario templates for executive presentations
 */
export const DEMO_SCENARIOS = {
  CT_SCAN_CHRONIC_BACK_PAIN: {
    name: 'CT Scan for Chronic Back Pain',
    procedureCode: CPT_CODES.CT_LUMBAR_SPINE_NO_CONTRAST,
    diagnosisCode: ICD10_CODES.LOW_BACK_PAIN,
    claimAmount: 1250,
    medicalContext: 'Patient with chronic lower back pain, conservative treatment failed, imaging requested for surgical planning'
  },
  MRI_DISC_DISORDER: {
    name: 'MRI for Disc Disorder',
    procedureCode: CPT_CODES.MRI_LUMBAR_SPINE_NO_CONTRAST,
    diagnosisCode: ICD10_CODES.DISC_DISORDER_RADICULOPATHY,
    claimAmount: 2100,
    medicalContext: 'Intervertebral disc disorder with radiculopathy, MRI needed to evaluate nerve compression'
  }
} as const;

/**
 * API endpoint paths for consistent URL construction
 */
export const API_ENDPOINTS = {
  HEALTH_CHECK: '/health',
  CLAIMS_SUBMIT: '/api/v1/claims',
  CLAIMS_STATUS: '/api/v1/claims/{claimId}',
  DEMO_START: '/api/v1/demonstrations',
  DEMO_STATUS: '/api/v1/demonstrations/{sessionId}',
  DEMO_CLEANUP: '/api/v1/demonstrations/{sessionId}'
} as const;

/**
 * Executive dashboard color scheme for healthcare professional styling
 */
export const HEALTHCARE_COLORS = {
  PRIMARY_BLUE: '#2E5C87',
  SECONDARY_BLUE: '#4A90B8',
  SUCCESS_GREEN: '#28A745',
  WARNING_AMBER: '#FFC107',
  ERROR_RED: '#DC3545',
  NEUTRAL_GRAY: '#6C757D',
  LIGHT_BACKGROUND: '#F8F9FA',
  WHITE: '#FFFFFF'
} as const;