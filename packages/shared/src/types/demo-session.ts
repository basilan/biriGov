import { z } from 'zod';

/**
 * System status for demonstration session tracking
 */
export enum SystemStatus {
  READY = 'ready',
  PROCESSING = 'processing',
  COMPLETE = 'complete',
  ERROR = 'error'
}

/**
 * Executive presentation metrics for stakeholder demonstrations
 */
export interface PresentationMetrics {
  /** Cost reduction percentage achieved (target: 60%) */
  costReductionPercentage: number;
  
  /** Time reduction percentage vs manual process */
  timeReductionPercentage: number;
  
  /** AI accuracy improvement over manual consistency */
  accuracyImprovement: number;
  
  /** Overall compliance score (0-100) */
  complianceScore: number;
}

/**
 * AWS infrastructure status for system health monitoring
 */
export interface InfrastructureStatus {
  /** All required AWS services operational */
  awsServicesOnline: boolean;
  
  /** OpenAI API connectivity status */
  openaiApiConnected: boolean;
  
  /** NVIDIA AI Enterprise API connectivity status */
  nvidiaApiConnected: boolean;
  
  /** Last successful health check timestamp */
  lastHealthCheck: string;
}

/**
 * Zod schema for demonstration session validation
 */
export const DemonstrationSessionSchema = z.object({
  sessionId: z.string().regex(/^DEMO_\d{8}_[A-Z0-9]+$/, 'Invalid session ID format'),
  executiveUserId: z.string().min(1, 'Executive user ID required'),
  startedAt: z.string().datetime('Invalid start timestamp'),
  completedAt: z.string().datetime('Invalid completion timestamp').optional(),
  totalCostUsd: z.number().nonnegative().max(50, 'Demo cost cannot exceed $50'),
  claimsProcessed: z.number().nonnegative('Claims processed must be non-negative'),
  avgProcessingTime: z.number().positive('Average processing time must be positive'),
  systemStatus: z.nativeEnum(SystemStatus),
  presentationMetrics: z.object({
    costReductionPercentage: z.number().min(0).max(100),
    timeReductionPercentage: z.number().min(0).max(100),
    accuracyImprovement: z.number().min(0).max(100),
    complianceScore: z.number().min(0).max(100)
  }),
  infrastructureStatus: z.object({
    awsServicesOnline: z.boolean(),
    openaiApiConnected: z.boolean(),
    nvidiaApiConnected: z.boolean(),
    lastHealthCheck: z.string().datetime()
  })
});

/**
 * Executive presentation session tracking for cost monitoring and 
 * performance metrics during healthcare AI demonstrations
 */
export interface DemonstrationSession {
  /** Unique demonstration session identifier (format: DEMO_YYYYMMDD_EXEC001) */
  sessionId: string;
  
  /** Executive user identifier for session tracking */
  executiveUserId: string;
  
  /** Demo initiation timestamp (ISO 8601) */
  startedAt: string;
  
  /** Demo completion timestamp (ISO 8601) - optional while running */
  completedAt?: string;
  
  /** Cumulative AWS + API costs in USD (must be < $50) */
  totalCostUsd: number;
  
  /** Total claims validated in this session */
  claimsProcessed: number;
  
  /** Average claim processing time in milliseconds */
  avgProcessingTime: number;
  
  /** Overall system health status */
  systemStatus: SystemStatus;
  
  /** Executive presentation metrics for stakeholder discussions */
  presentationMetrics: PresentationMetrics;
  
  /** Infrastructure health for system reliability */
  infrastructureStatus: InfrastructureStatus;
}

/**
 * Type guard to validate DemonstrationSession objects
 */
export const validateDemonstrationSession = (session: unknown): session is DemonstrationSession => {
  const validation = DemonstrationSessionSchema.safeParse(session);
  return validation.success;
};

/**
 * Create a valid session ID with current timestamp and executive identifier
 */
export const generateSessionId = (executiveId: string): string => {
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const execId = executiveId.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6);
  return `DEMO_${date}_${execId}`;
};

/**
 * Calculate cost reduction percentage for executive presentation
 */
export const calculateCostReduction = (manualCost: number, aiCost: number): number => {
  if (manualCost <= 0) return 0;
  return Math.round(((manualCost - aiCost) / manualCost) * 100);
};