import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

import App from './App.tsx'
import './index.css'

// React Query client configuration for healthcare data
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Healthcare data should be fresh for executive presentations
      staleTime: 30 * 1000, // 30 seconds
      cacheTime: 5 * 60 * 1000, // 5 minutes
      retry: 3,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
      // Refetch on window focus for real-time dashboard updates
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
    },
    mutations: {
      retry: 1,
    },
  },
})

// Error boundary for healthcare application reliability
class HealthcareErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error?: Error }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Healthcare AI Application Error:', error, errorInfo)
    
    // In production, this would send to healthcare-compliant logging service
    if (import.meta.env.PROD) {
      // Log to CloudWatch or healthcare-compliant logging service
    }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen bg-clinical-50 flex items-center justify-center px-4">
          <div className="max-w-md w-full bg-white rounded-lg shadow-clinical p-6 text-center">
            <div className="w-16 h-16 mx-auto bg-danger-100 rounded-full flex items-center justify-center mb-4">
              <svg className="w-8 h-8 text-danger-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            
            <h2 className="text-xl font-semibold text-clinical-900 mb-2">
              System Temporarily Unavailable
            </h2>
            
            <p className="text-clinical-600 mb-4">
              The Healthcare AI Governance system encountered an unexpected error. 
              Please refresh the page or contact support if the issue persists.
            </p>
            
            <button
              onClick={() => window.location.reload()}
              className="w-full bg-medical-500 text-white px-4 py-2 rounded-lg hover:bg-medical-600 transition-colors font-medium"
            >
              Refresh Application
            </button>
            
            <p className="text-xs text-clinical-400 mt-4">
              Error ID: {Math.random().toString(36).substring(7).toUpperCase()}
            </p>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

// Performance monitoring for executive dashboard
if (import.meta.env.DEV) {
  // Development performance monitoring
  const observer = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      console.log(`⚡ ${entry.name}: ${entry.duration.toFixed(2)}ms`)
    }
  })
  observer.observe({ entryTypes: ['navigation', 'paint'] })
}

// Healthcare AI Application Bootstrap
const root = ReactDOM.createRoot(document.getElementById('root')!)

root.render(
  <React.StrictMode>
    <HealthcareErrorBoundary>
      <BrowserRouter>
        <QueryClientProvider client={queryClient}>
          <App />
          {import.meta.env.DEV && (
            <ReactQueryDevtools 
              initialIsOpen={false} 
              position="bottom-right"
            />
          )}
        </QueryClientProvider>
      </BrowserRouter>
    </HealthcareErrorBoundary>
  </React.StrictMode>,
)