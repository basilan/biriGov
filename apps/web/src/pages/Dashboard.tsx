import React, { useState, useEffect } from 'react'
import type { SystemStatus } from '@shared/types'

interface DashboardMetrics {
  claimsProcessed: number
  totalCostSavings: number
  avgProcessingTime: number
  budgetUsed: number
  budgetRemaining: number
  costReductionPercentage: number
  timeReductionPercentage: number
  complianceScore: number
  systemStatus: SystemStatus
  awsServicesOnline: boolean
  openaiConnected: boolean
  nvidiaConnected: boolean
  lastHealthCheck: string
}

const Dashboard: React.FC = () => {
  const [metrics, setMetrics] = useState<DashboardMetrics>({
    claimsProcessed: 0,
    totalCostSavings: 0,
    avgProcessingTime: 0,
    budgetUsed: 0,
    budgetRemaining: 50.0,
    costReductionPercentage: 0,
    timeReductionPercentage: 0,
    complianceScore: 0,
    systemStatus: 'ready' as SystemStatus,
    awsServicesOnline: true,
    openaiConnected: true,
    nvidiaConnected: true,
    lastHealthCheck: new Date().toISOString()
  })


  // Simulate real-time metrics updates (in real implementation, this would be API polling)
  useEffect(() => {
    const interval = setInterval(() => {
      // Simulate live demo data
      setMetrics(prev => ({
        ...prev,
        claimsProcessed: Math.min(prev.claimsProcessed + Math.floor(Math.random() * 3), 100),
        budgetUsed: Math.min(prev.budgetUsed + Math.random() * 0.5, 45),
        avgProcessingTime: 1800 + Math.random() * 400,
        totalCostSavings: prev.claimsProcessed * 125.50,
        costReductionPercentage: Math.min(60 + Math.random() * 5, 65),
        timeReductionPercentage: Math.min(80 + Math.random() * 10, 90),
        complianceScore: Math.min(90 + Math.random() * 8, 98),
        lastHealthCheck: new Date().toISOString()
      }))
    }, 5000)

    return () => clearInterval(interval)
  }, [])

  // Calculate budget remaining
  useEffect(() => {
    setMetrics(prev => ({
      ...prev,
      budgetRemaining: Math.max(0, 50.0 - prev.budgetUsed)
    }))
  }, [metrics.budgetUsed])

  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2
    }).format(amount)
  }

  const formatTime = (ms: number): string => {
    return `${(ms / 1000).toFixed(1)}s`
  }

  const getBudgetStatusColor = (used: number, total: number): string => {
    const percentage = (used / total) * 100
    if (percentage > 80) return 'text-danger-600'
    if (percentage > 60) return 'text-alert-600'
    return 'text-health-600'
  }

  const getSystemHealthStatus = (): { status: string; color: string } => {
    const allHealthy = metrics.awsServicesOnline && metrics.openaiConnected && metrics.nvidiaConnected
    return {
      status: allHealthy ? 'All Systems Operational' : 'Service Issues Detected',
      color: allHealthy ? 'text-health-600' : 'text-alert-600'
    }
  }

  const systemHealth = getSystemHealthStatus()

  return (
    <div className="px-4 py-8 bg-clinical-50 min-h-screen">
      {/* Executive Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl md:text-4xl font-bold text-clinical-900 text-balance">
              Healthcare AI Governance Dashboard
            </h1>
            <p className="text-clinical-600 mt-2 text-lg">
              Real-time Claims Validation & Cost Reduction Analytics
            </p>
          </div>
          <div className="hidden md:flex items-center space-x-4">
            <div className="text-right">
              <div className="text-sm text-clinical-500">Demo Session</div>
              <div className="text-lg font-semibold text-medical-600">DEMO_20250827_EXEC01</div>
            </div>
            <div className={`status-${metrics.systemStatus}`}>
              {metrics.systemStatus.toUpperCase()}
            </div>
          </div>
        </div>
      </div>

      {/* Key Performance Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {/* Claims Processed */}
        <div className="card-executive group hover:scale-105">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-clinical-900">Claims Processed</h3>
              <p className="text-3xl font-bold text-medical-600 mt-2">
                {metrics.claimsProcessed.toLocaleString()}
              </p>
              <div className="text-sm text-clinical-500 mt-1">
                +{Math.floor(Math.random() * 5)} in last hour
              </div>
            </div>
            <div className="text-medical-400 text-4xl">📋</div>
          </div>
        </div>

        {/* Cost Savings */}
        <div className="card-executive group hover:scale-105">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-clinical-900">Total Savings</h3>
              <p className="text-3xl font-bold text-health-600 mt-2">
                {formatCurrency(metrics.totalCostSavings)}
              </p>
              <div className="text-sm text-health-600 mt-1">
                {metrics.costReductionPercentage.toFixed(1)}% reduction
              </div>
            </div>
            <div className="text-health-400 text-4xl">💰</div>
          </div>
        </div>

        {/* Processing Performance */}
        <div className="card-executive group hover:scale-105">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-clinical-900">Avg Processing</h3>
              <p className="text-3xl font-bold text-medical-600 mt-2">
                {formatTime(metrics.avgProcessingTime)}
              </p>
              <div className="text-sm text-medical-600 mt-1">
                {metrics.timeReductionPercentage.toFixed(1)}% faster
              </div>
            </div>
            <div className="text-medical-400 text-4xl">⚡</div>
          </div>
        </div>

        {/* Budget Monitoring */}
        <div className="card-executive group hover:scale-105">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-clinical-900">Demo Budget</h3>
              <p className={`text-3xl font-bold mt-2 ${getBudgetStatusColor(metrics.budgetUsed, 50)}`}>
                {formatCurrency(metrics.budgetUsed)}
              </p>
              <div className="text-sm text-clinical-500 mt-1">
                {formatCurrency(metrics.budgetRemaining)} remaining
              </div>
            </div>
            <div className="text-clinical-400 text-4xl">📊</div>
          </div>
          {/* Budget Progress Bar */}
          <div className="mt-4">
            <div className="progress-bar">
              <div 
                className="progress-fill"
                style={{ width: `${(metrics.budgetUsed / 50) * 100}%` }}
              />
            </div>
            <div className="text-xs text-clinical-500 mt-1">
              {((metrics.budgetUsed / 50) * 100).toFixed(1)}% of $50 limit used
            </div>
          </div>
        </div>
      </div>

      {/* Executive Summary Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Business Impact Metrics */}
        <div className="card-executive">
          <h2 className="text-xl font-semibold text-clinical-900 mb-6 flex items-center">
            <span className="text-2xl mr-2">📈</span>
            Business Impact Summary
          </h2>
          <div className="space-y-4">
            <div className="flex justify-between items-center py-2 border-b border-clinical-100">
              <span className="text-clinical-700 font-medium">Cost Reduction Achievement</span>
              <span className="text-2xl font-bold text-health-600">
                {metrics.costReductionPercentage.toFixed(1)}%
              </span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-clinical-100">
              <span className="text-clinical-700 font-medium">Processing Time Improvement</span>
              <span className="text-2xl font-bold text-medical-600">
                {metrics.timeReductionPercentage.toFixed(1)}%
              </span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-clinical-100">
              <span className="text-clinical-700 font-medium">Compliance Score</span>
              <span className="text-2xl font-bold text-medical-600">
                {metrics.complianceScore.toFixed(1)}%
              </span>
            </div>
            <div className="flex justify-between items-center py-2">
              <span className="text-clinical-700 font-medium">ROI per Claim</span>
              <span className="text-2xl font-bold text-health-600">
                {formatCurrency(metrics.totalCostSavings / Math.max(metrics.claimsProcessed, 1))}
              </span>
            </div>
          </div>
        </div>

        {/* System Health Monitor */}
        <div className="card-executive">
          <h2 className="text-xl font-semibold text-clinical-900 mb-6 flex items-center">
            <span className="text-2xl mr-2">🏥</span>
            Infrastructure Health
          </h2>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className={`w-3 h-3 rounded-full ${metrics.awsServicesOnline ? 'bg-health-500' : 'bg-danger-500'}`} />
                <span className="text-clinical-700 font-medium">AWS Services</span>
              </div>
              <span className={metrics.awsServicesOnline ? 'text-health-600' : 'text-danger-600'}>
                {metrics.awsServicesOnline ? 'Online' : 'Offline'}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className={`w-3 h-3 rounded-full ${metrics.openaiConnected ? 'bg-health-500' : 'bg-danger-500'}`} />
                <span className="text-clinical-700 font-medium">OpenAI API</span>
              </div>
              <span className={metrics.openaiConnected ? 'text-health-600' : 'text-danger-600'}>
                {metrics.openaiConnected ? 'Connected' : 'Disconnected'}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className={`w-3 h-3 rounded-full ${metrics.nvidiaConnected ? 'bg-health-500' : 'bg-danger-500'}`} />
                <span className="text-clinical-700 font-medium">NVIDIA AI Enterprise</span>
              </div>
              <span className={metrics.nvidiaConnected ? 'text-health-600' : 'text-danger-600'}>
                {metrics.nvidiaConnected ? 'Connected' : 'Disconnected'}
              </span>
            </div>
            <div className="pt-4 border-t border-clinical-100">
              <div className="flex items-center justify-between">
                <span className="text-clinical-700 font-medium">Overall Status</span>
                <div className={`px-3 py-1 rounded-full text-sm font-medium ${systemHealth.color} bg-opacity-10`}>
                  {systemHealth.status}
                </div>
              </div>
              <div className="text-xs text-clinical-500 mt-2">
                Last checked: {new Date(metrics.lastHealthCheck).toLocaleTimeString()}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Live Processing Status */}
      <div className="card-executive">
        <h2 className="text-xl font-semibold text-clinical-900 mb-4 flex items-center">
          <span className="text-2xl mr-2">⚡</span>
          Live Processing Status
        </h2>
        <div className="bg-clinical-50 rounded-lg p-6 border-l-4 border-medical-500">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-lg font-semibold text-clinical-900">
                Healthcare AI Claims Validation System
              </div>
              <div className="text-clinical-600 mt-1">
                Ready to process healthcare claims with AI-powered validation
              </div>
            </div>
            <div className="flex space-x-3">
              <button className="btn-primary">
                Process New Claim
              </button>
              <button className="btn-secondary">
                View Reports
              </button>
            </div>
          </div>
          
          {/* Demo Controls */}
          <div className="mt-6 pt-4 border-t border-clinical-200">
            <div className="flex items-center justify-between">
              <div className="text-sm text-clinical-600">
                Executive Demo Controls
              </div>
              <div className="flex space-x-2">
                <button className="btn-success text-sm px-3 py-1">
                  Start Demo
                </button>
                <button className="btn-secondary text-sm px-3 py-1">
                  Generate Report
                </button>
                <button className="btn-danger text-sm px-3 py-1">
                  Emergency Stop
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Budget Alert Banner */}
      {metrics.budgetUsed > 40 && (
        <div className="mt-6 notification-warning animate-fade-in">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <span className="text-2xl">⚠️</span>
              <div>
                <div className="font-semibold">Budget Alert</div>
                <div className="text-sm">
                  Demo budget at {((metrics.budgetUsed / 50) * 100).toFixed(1)}%. 
                  System will auto-shutdown at $45 to prevent overages.
                </div>
              </div>
            </div>
            <button className="btn-secondary text-sm">
              View Details
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

export default Dashboard