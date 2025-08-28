import { Routes, Route, Navigate } from 'react-router-dom'

// Layout components
import Layout from '@components/layout/Layout'

// Page components (will be created in next steps)
import Dashboard from '@pages/Dashboard'
import ClaimsValidation from '@pages/ClaimsValidation'
import CostTracking from '@pages/CostTracking'
import SystemHealth from '@pages/SystemHealth'

// Error boundary for route-level error handling
import { ErrorBoundary } from '@components/common/ErrorBoundary'

// Environment configuration
const isDevelopment = import.meta.env.DEV

function App() {
  return (
    <div className="min-h-screen bg-clinical-50">
      <Layout>
        <ErrorBoundary>
          <Routes>
            {/* Executive Dashboard - Default route */}
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<Dashboard />} />
            
            {/* Healthcare Claims Validation */}
            <Route path="/claims" element={<ClaimsValidation />} />
            
            {/* Cost Tracking & Budget Management */}
            <Route path="/costs" element={<CostTracking />} />
            
            {/* System Health & Infrastructure Status */}
            <Route path="/health" element={<SystemHealth />} />
            
            {/* Fallback route */}
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </ErrorBoundary>
      </Layout>

      {/* Development tools */}
      {isDevelopment && (
        <div className="fixed bottom-4 left-4 z-50 no-print">
          <div className="bg-clinical-800 text-white px-3 py-1 rounded text-xs font-mono">
            Healthcare AI v{import.meta.env.VITE_APP_VERSION || '1.0.0'}
          </div>
        </div>
      )}

      {/* Healthcare compliance notice */}
      <div className="sr-only" aria-live="polite" id="healthcare-status">
        Healthcare AI Governance Agent - Executive Dashboard
      </div>
    </div>
  )
}

export default App