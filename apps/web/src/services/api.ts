/**
 * Healthcare AI Governance API Service
 * Handles communication with the backend Lambda functions
 */

import { env } from '../config/env'

// API Response Types
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: {
    code: string
    message: string
    timestamp: string
  }
  timestamp: string
  steel_thread: string
  environment: string
}

interface ClaimSubmissionResponse {
  message: string
  claim_id: string
  status: string
  processing_time_ms: number
  ai_confidence_score: number
  ai_reasoning: string
  business_metrics: {
    cost_reduction: number
    manual_review_cost_avoided: number
    processing_time_reduction_percent: number
    accuracy_improvement_percent: number
  }
  compliance_checks: Array<{
    check_name: string
    passed: boolean
    details: string
  }>
  validation_summary: {
    medical_necessity: string
    coding_accuracy: string
    fraud_indicators: string
    compliance_status: string
  }
}

interface ClaimStatusResponse {
  claim: {
    claimId: string
    status: string
    processed_at: string
    ai_confidence_score: number
    cost_reduction: number
    processing_time_ms: number
    [key: string]: any
  }
  processing_complete: boolean
}

// Claim Submission Data
interface ClaimData {
  claimId?: string
  patientId: string
  providerId: string
  procedureCode: string
  diagnosisCode: string
  claimAmount: number
  dateOfService: string
  priority: 'routine' | 'standard' | 'urgent'
}

class HealthcareAIAPI {
  private baseURL: string
  private timeout: number

  constructor() {
    this.baseURL = env.API_BASE_URL
    this.timeout = env.API_TIMEOUT
  }

  /**
   * Submit a healthcare claim for AI validation
   */
  async submitClaim(claimData: ClaimData): Promise<ClaimSubmissionResponse> {
    const response = await this.makeRequest<ClaimSubmissionResponse>('/claims', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(claimData)
    })

    if (!response.success || !response.data) {
      throw new Error(response.error?.message || 'Failed to submit claim')
    }

    return response.data
  }

  /**
   * Get the status of a submitted claim
   */
  async getClaimStatus(claimId: string): Promise<ClaimStatusResponse> {
    const response = await this.makeRequest<ClaimStatusResponse>(`/claims/${claimId}`, {
      method: 'GET'
    })

    if (!response.success || !response.data) {
      throw new Error(response.error?.message || 'Failed to get claim status')
    }

    return response.data
  }

  /**
   * Test API connectivity
   */
  async healthCheck(): Promise<boolean> {
    try {
      // Try a simple GET request to see if API is accessible
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 5000)
      
      const response = await fetch(`${this.baseURL}/claims`, {
        method: 'OPTIONS',
        signal: controller.signal
      })
      
      clearTimeout(timeoutId)
      return response.status < 500
    } catch (error) {
      console.warn('API health check failed:', error)
      return false
    }
  }

  /**
   * Submit a test claim for demonstration purposes
   */
  async submitTestClaim(): Promise<ClaimSubmissionResponse> {
    const testClaim: ClaimData = {
      claimId: `DEMO_${Date.now()}`,
      patientId: 'PAT_DEMO_001',
      providerId: 'PROV_DEMO_001',
      procedureCode: '99213',
      diagnosisCode: 'Z00.00',
      claimAmount: 185.0,
      dateOfService: new Date().toISOString().split('T')[0] || new Date().toISOString(),
      priority: 'routine'
    }

    return this.submitClaim(testClaim)
  }

  /**
   * Make an HTTP request with proper error handling
   */
  private async makeRequest<T>(
    endpoint: string, 
    options: RequestInit
  ): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`
    
    try {
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), this.timeout)

      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      })

      clearTimeout(timeoutId)

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`HTTP ${response.status}: ${errorText}`)
      }

      const data = await response.json()
      return data as ApiResponse<T>

    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') {
        throw new Error('Request timeout - API may be experiencing high latency')
      }
      
      console.error('API Request failed:', {
        url,
        error: error instanceof Error ? error.message : String(error)
      })
      
      throw error
    }
  }
}

// Export singleton instance
export const healthcareAPI = new HealthcareAIAPI()

// Export types for use in components
export type {
  ClaimData,
  ClaimSubmissionResponse,
  ClaimStatusResponse,
  ApiResponse
}