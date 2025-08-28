import React, { useState } from 'react'
import { healthcareAPI } from '../services/api'
import type { ClaimSubmissionResponse } from '../services/api'

const ClaimsValidation: React.FC = () => {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [result, setResult] = useState<ClaimSubmissionResponse | null>(null)
  const [error, setError] = useState<string | null>(null)

  const handleTestClaimSubmission = async () => {
    setIsSubmitting(true)
    setError(null)
    setResult(null)

    try {
      const response = await healthcareAPI.submitTestClaim()
      setResult(response)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error occurred')
    } finally {
      setIsSubmitting(false)
    }
  }

  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2
    }).format(amount)
  }

  return (
    <div className="px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-clinical-900">Claims Validation</h1>
        <p className="text-clinical-600 mt-2">
          AI-powered healthcare claims processing and validation
        </p>
      </div>

      {/* Steel-Thread API Testing */}
      <div className="card-executive mb-6">
        <h2 className="text-xl font-semibold text-clinical-900 mb-4">
          Steel-Thread API Integration Test
        </h2>
        <div className="flex items-center space-x-4 mb-4">
          <button 
            onClick={handleTestClaimSubmission}
            disabled={isSubmitting}
            className={`px-6 py-2 rounded-lg font-medium ${
              isSubmitting 
                ? 'bg-clinical-200 text-clinical-500 cursor-not-allowed' 
                : 'bg-medical-600 text-white hover:bg-medical-700'
            }`}
          >
            {isSubmitting ? 'Processing...' : 'Submit Test Claim'}
          </button>
          {isSubmitting && (
            <div className="flex items-center text-clinical-600">
              <div className="animate-spin h-4 w-4 border-2 border-medical-600 border-t-transparent rounded-full mr-2"></div>
              Testing steel-thread connection...
            </div>
          )}
        </div>

        {/* Error Display */}
        {error && (
          <div className="bg-danger-50 border border-danger-200 rounded-lg p-4 mb-4">
            <div className="flex items-center">
              <span className="text-danger-600 text-xl mr-2">❌</span>
              <div>
                <h3 className="font-semibold text-danger-800">API Connection Error</h3>
                <p className="text-danger-600 text-sm mt-1">{error}</p>
              </div>
            </div>
          </div>
        )}

        {/* Success Results */}
        {result && (
          <div className="bg-health-50 border border-health-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <span className="text-health-600 text-xl mr-2">✅</span>
              <h3 className="font-semibold text-health-800">Steel-Thread Connection Successful!</h3>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Claim Details */}
              <div>
                <h4 className="font-semibold text-clinical-900 mb-2">Claim Details</h4>
                <div className="space-y-1 text-sm">
                  <div><strong>Claim ID:</strong> {result.claim_id}</div>
                  <div><strong>Status:</strong> 
                    <span className={`ml-1 px-2 py-1 rounded text-xs font-medium ${
                      result.status === 'APPROVED' ? 'bg-health-100 text-health-800' :
                      result.status === 'DENIED' ? 'bg-danger-100 text-danger-800' :
                      'bg-alert-100 text-alert-800'
                    }`}>
                      {result.status}
                    </span>
                  </div>
                  <div><strong>Processing Time:</strong> {result.processing_time_ms}ms</div>
                  <div><strong>AI Confidence:</strong> {result.ai_confidence_score}%</div>
                </div>
              </div>

              {/* Business Metrics */}
              <div>
                <h4 className="font-semibold text-clinical-900 mb-2">Business Impact</h4>
                <div className="space-y-1 text-sm">
                  <div><strong>Cost Reduction:</strong> {formatCurrency(result.business_metrics.cost_reduction)}</div>
                  <div><strong>Time Saved:</strong> {result.business_metrics.processing_time_reduction_percent}%</div>
                  <div><strong>Accuracy Gain:</strong> {result.business_metrics.accuracy_improvement_percent}%</div>
                </div>
              </div>
            </div>

            {/* AI Reasoning */}
            <div className="mt-4">
              <h4 className="font-semibold text-clinical-900 mb-2">AI Medical Reasoning</h4>
              <div className="bg-clinical-50 rounded p-3 text-sm text-clinical-700">
                {result.ai_reasoning}
              </div>
            </div>

            {/* Compliance Checks */}
            <div className="mt-4">
              <h4 className="font-semibold text-clinical-900 mb-2">Compliance Checks</h4>
              <div className="space-y-2">
                {result.compliance_checks.map((check, index) => (
                  <div key={index} className="flex items-center text-sm">
                    <span className={`mr-2 ${check.passed ? 'text-health-600' : 'text-danger-600'}`}>
                      {check.passed ? '✅' : '❌'}
                    </span>
                    <span className="font-medium mr-2">{check.check_name}:</span>
                    <span className="text-clinical-600">{check.details}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Additional Features Placeholder */}
      <div className="card-executive">
        <h2 className="text-xl font-semibold text-clinical-900 mb-4">
          Full Claims Processing Interface
        </h2>
        <p className="text-clinical-600">
          Complete claims validation interface will be implemented here after steel-thread validation is complete.
          This will include batch processing, detailed reporting, and executive dashboard integration.
        </p>
      </div>
    </div>
  )
}

export default ClaimsValidation