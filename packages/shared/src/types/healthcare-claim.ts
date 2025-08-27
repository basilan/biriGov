import { z } from 'zod';

/**
 * Healthcare claim priority levels for processing urgency
 */
export enum ClaimPriority {
  ROUTINE = 'routine',
  URGENT = 'urgent',
  EMERGENCY = 'emergency'
}

/**
 * Healthcare claim processing status
 */
export enum ClaimStatus {
  SUBMITTED = 'submitted',
  PROCESSING = 'processing',
  AI_REVIEW = 'ai_review',
  APPROVED = 'approved',
  DENIED = 'denied',
  REQUIRES_HUMAN_REVIEW = 'requires_human_review'
}

/**
 * Zod schema for healthcare claim validation
 */
export const HealthcareClaimSchema = z.object({
  claimId: z.string().regex(/^CLAIM_\d{8}_\d{3}$/, 'Invalid claim ID format'),
  patientId: z.string().regex(/^DEMO_PATIENT_\d+$/, 'Invalid patient ID format'),
  providerId: z.string().regex(/^PROV_\d+$/, 'Invalid provider ID format'),
  serviceDate: z.string().datetime('Invalid service date format'),
  procedureCode: z.string().regex(/^\d{5}$/, 'Invalid CPT procedure code'),
  diagnosisCode: z.string().regex(/^[A-Z]\d{2}\.\d$/, 'Invalid ICD-10 diagnosis code'),
  claimAmount: z.number().positive('Claim amount must be positive'),
  status: z.nativeEnum(ClaimStatus),
  submittedAt: z.string().datetime('Invalid submission timestamp'),
  priority: z.nativeEnum(ClaimPriority),
  medicalNecessityContext: z.string().optional(),
  supportingDocuments: z.array(z.string()).optional()
});

/**
 * Primary business entity representing a medical claim requiring validation
 * against healthcare guidelines for cost reduction demonstration
 */
export interface HealthcareClaim {
  /** Unique claim identifier for audit trail (format: CLAIM_YYYYMMDD_NNN) */
  claimId: string;
  
  /** De-identified patient reference (format: DEMO_PATIENT_NNN) */
  patientId: string;
  
  /** Healthcare provider identifier (format: PROV_NNN) */
  providerId: string;
  
  /** Date of medical service (ISO 8601 format) */
  serviceDate: string;
  
  /** CPT/HCPCS procedure code (5 digits) */
  procedureCode: string;
  
  /** ICD-10 diagnosis code (format: A00.0) */
  diagnosisCode: string;
  
  /** Requested reimbursement amount in USD */
  claimAmount: number;
  
  /** Current validation state */
  status: ClaimStatus;
  
  /** Initial submission timestamp (ISO 8601 format) */
  submittedAt: string;
  
  /** Processing urgency level */
  priority: ClaimPriority;
  
  /** Optional medical context for AI reasoning */
  medicalNecessityContext?: string;
  
  /** Optional supporting document references */
  supportingDocuments?: string[];
}

/**
 * Type guard to validate HealthcareClaim objects
 */
export const validateHealthcareClaim = (claim: unknown): claim is HealthcareClaim => {
  const result = HealthcareClaimSchema.safeParse(claim);
  return result.success;
};

/**
 * Create a valid claim ID with current timestamp
 */
export const generateClaimId = (): string => {
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const sequence = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `CLAIM_${date}_${sequence}`;
};