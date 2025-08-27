import React from 'react'

interface ErrorBoundaryProps {
  children: React.ReactNode
  fallback?: React.ComponentType<{ error: Error }>
}

interface ErrorBoundaryState {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Healthcare AI Error Boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      const Fallback = this.props.fallback
      
      if (Fallback && this.state.error) {
        return <Fallback error={this.state.error} />
      }

      return (
        <div className="min-h-screen bg-clinical-50 flex items-center justify-center px-4">
          <div className="max-w-md w-full bg-white rounded-lg shadow-clinical p-6 text-center">
            <h2 className="text-xl font-semibold text-clinical-900 mb-2">
              Something went wrong
            </h2>
            <p className="text-clinical-600 mb-4">
              Please refresh the page or contact support.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="btn-primary"
            >
              Refresh Page
            </button>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}