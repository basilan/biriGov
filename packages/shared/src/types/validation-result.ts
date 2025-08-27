import { z } from 'zod';

/**
 * AI validation decision status
 */
export enum ValidationStatus {
  APPROVED = 'approved',
  DENIED = 'denied',
  PARTIAL_APPROVAL = 'partial_approval',
  COMPLIANCE_VIOLATION = 'compliance_violation',
  INSUFFICIENT_DATA = 'insufficient_data'
}

/**
 * NVIDIA AI Enterprise compliance check result
 */
export interface ComplianceCheck {
  /** Type of compliance check performed */
  checkType: string;
  
  /** Whether the check passed */
  passed: boolean;
  
  /** Detailed compliance check results */
  details: string;
  
  /** Regulatory framework used (e.g., HIPAA, FDA) */
  regulatoryFramework: string;
}

/**
 * Business metrics for executive presentation
 */
export interface BusinessMetrics {
  /** Cost avoided by using AI vs manual review */
  manualReviewCostAvoided: number;
  
  /** Time reduction percentage vs manual process */
  processingTimeReduction: number;
  
  /** AI accuracy improvement over manual consistency */
  accuracyImprovement: number;
}

/**
 * Zod schema for validation result validation
 */
export const ValidationResultSchema = z.object({
  resultId: z.string().regex(/^RESULT_\d{8}_\d{3}$/, 'Invalid result ID format'),
  claimId: z.string().regex(/^CLAIM_\d{8}_\d{3}$/, 'Invalid claim ID format'),
  validationStatus: z.nativeEnum(ValidationStatus),
  confidenceScore: z.number().min(0).max(100, 'Confidence score must be 0-100'),
  costReduction: z.number().nonnegative('Cost reduction must be non-negative'),
  processingTimeMs: z.number().positive('Processing time must be positive'),
  aiReasoningText: z.string().min(1, 'AI reasoning text required'),
  complianceChecks: z.array(z.object({
    checkType: z.string(),
    passed: z.boolean(),
    details: z.string(),
    regulatoryFramework: z.string()
  })),
  createdAt: z.string().datetime('Invalid creation timestamp'),
  requiresHumanReview: z.boolean(),
  businessMetrics: z.object({
    manualReviewCostAvoided: z.number(),
    processingTimeReduction: z.number(),
    accuracyImprovement: z.number()
  })
});

/**
 * AI validation outcome combining OpenAI medical reasoning with 
 * NVIDIA compliance checking for executive demonstration
 */
export interface ValidationResult {
  /** Unique validation result identifier (format: RESULT_YYYYMMDD_NNN) */
  resultId: string;
  
  /** Reference to source claim */
  claimId: string;
  
  /** Final validation decision */
  validationStatus: ValidationStatus;
  
  /** AI confidence percentage (0-100) */
  confidenceScore: number;
  
  /** Calculated savings vs manual review in USD */
  costReduction: number;
  
  /** Total validation time in milliseconds */
  processingTimeMs: number;
  
  /** OpenAI medical necessity explanation */
  aiReasoningText: string;
  
  /** NVIDIA compliance validation results */
  complianceChecks: ComplianceCheck[];
  
  /** Validation completion timestamp (ISO 8601) */
  createdAt: string;
  
  /** Whether human review is recommended */
  requiresHumanReview: boolean;
  
  /** Executive presentation metrics */
  businessMetrics: BusinessMetrics;
}

/**
 * Type guard to validate ValidationResult objects
 */
export const validateValidationResult = (result: unknown): result is ValidationResult => {
  const validation = ValidationResultSchema.safeParse(result);
  return validation.success;
};

/**
 * Create a valid result ID with current timestamp
 */
export const generateResultId = (): string => {
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const sequence = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `RESULT_${date}_${sequence}`;
};