import React from 'react'

const SystemHealth: React.FC = () => {
  return (
    <div className="px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-clinical-900">System Health</h1>
        <p className="text-clinical-600 mt-2">
          Infrastructure status and system monitoring
        </p>
      </div>

      <div className="card-executive">
        <h2 className="text-xl font-semibold text-clinical-900 mb-4">
          Infrastructure Status
        </h2>
        <p className="text-clinical-600">
          System health monitoring will be implemented here.
        </p>
      </div>
    </div>
  )
}

export default SystemHealth