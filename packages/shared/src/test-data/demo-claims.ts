import { HealthcareClaim, ClaimStatus, ClaimPriority } from '../types/healthcare-claim';
import { CPT_CODES, ICD10_CODES, DEMO_SCENARIOS } from '../constants/healthcare';

/**
 * Demo healthcare claims for executive presentation scenarios
 * All data is de-identified and designed for demonstration purposes only
 */

/**
 * CT Scan for chronic back pain - primary demo scenario
 */
export const demoClaimCtScanBackPain: HealthcareClaim = {
  claimId: 'CLAIM_20250825_001',
  patientId: 'DEMO_PATIENT_001',
  providerId: 'PROV_12345',
  serviceDate: '2025-08-15T09:00:00Z',
  procedureCode: CPT_CODES.CT_LUMBAR_SPINE_NO_CONTRAST,
  diagnosisCode: ICD10_CODES.LOW_BACK_PAIN,
  claimAmount: 1250.00,
  status: ClaimStatus.SUBMITTED,
  submittedAt: '2025-08-25T10:30:00Z',
  priority: ClaimPriority.ROUTINE,
  medicalNecessityContext: DEMO_SCENARIOS.CT_SCAN_CHRONIC_BACK_PAIN.medicalContext,
  supportingDocuments: [
    'physician-notes-chronic-pain.pdf',
    'previous-xray-results.pdf',
    'physical-therapy-records.pdf'
  ]
};

/**
 * MRI for disc disorder - secondary demo scenario
 */
export const demoClaimMriDiscDisorder: HealthcareClaim = {
  claimId: 'CLAIM_20250825_002',
  patientId: 'DEMO_PATIENT_002',
  providerId: 'PROV_12345',
  serviceDate: '2025-08-16T14:00:00Z',
  procedureCode: CPT_CODES.MRI_LUMBAR_SPINE_NO_CONTRAST,
  diagnosisCode: ICD10_CODES.DISC_DISORDER_RADICULOPATHY,
  claimAmount: 2100.00,
  status: ClaimStatus.SUBMITTED,
  submittedAt: '2025-08-25T11:15:00Z',
  priority: ClaimPriority.URGENT,
  medicalNecessityContext: DEMO_SCENARIOS.MRI_DISC_DISORDER.medicalContext,
  supportingDocuments: [
    'neurological-exam-findings.pdf',
    'emg-study-results.pdf',
    'conservative-treatment-records.pdf'
  ]
};

/**
 * Chest X-ray for routine screening - quick validation scenario
 */
export const demoClaimChestXray: HealthcareClaim = {
  claimId: 'CLAIM_20250825_003',
  patientId: 'DEMO_PATIENT_003',
  providerId: 'PROV_67890',
  serviceDate: '2025-08-17T08:30:00Z',
  procedureCode: CPT_CODES.CHEST_X_RAY,
  diagnosisCode: ICD10_CODES.ESSENTIAL_HYPERTENSION,
  claimAmount: 150.00,
  status: ClaimStatus.SUBMITTED,
  submittedAt: '2025-08-25T12:00:00Z',
  priority: ClaimPriority.ROUTINE,
  medicalNecessityContext: 'Routine chest X-ray for hypertensive patient as part of annual physical examination',
  supportingDocuments: [
    'annual-physical-exam.pdf',
    'blood-pressure-readings.pdf'
  ]
};

/**
 * All demo claims for batch processing scenarios
 */
export const allDemoClaims: HealthcareClaim[] = [
  demoClaimCtScanBackPain,
  demoClaimMriDiscDisorder,
  demoClaimChestXray
];

/**
 * Demo claims by priority for testing workflow scenarios
 */
export const demoClaimsByPriority = {
  routine: [demoClaimCtScanBackPain, demoClaimChestXray],
  urgent: [demoClaimMriDiscDisorder],
  emergency: [] as HealthcareClaim[]
};

/**
 * Demo claims by cost range for budget testing
 */
export const demoClaimsByCost = {
  low: [demoClaimChestXray], // < $500
  medium: [demoClaimCtScanBackPain], // $500 - $1500
  high: [demoClaimMriDiscDisorder] // > $1500
};

/**
 * Expected validation outcomes for testing AI integration
 */
export const expectedValidationOutcomes = {
  [demoClaimCtScanBackPain.claimId]: {
    expectedStatus: 'approved',
    expectedConfidence: 85,
    expectedReasoningKeywords: ['chronic pain', 'conservative treatment failed', 'medically necessary']
  },
  [demoClaimMriDiscDisorder.claimId]: {
    expectedStatus: 'approved',
    expectedConfidence: 92,
    expectedReasoningKeywords: ['disc disorder', 'radiculopathy', 'neurological findings']
  },
  [demoClaimChestXray.claimId]: {
    expectedStatus: 'approved',
    expectedConfidence: 78,
    expectedReasoningKeywords: ['routine screening', 'hypertensive patient', 'preventive care']
  }
};