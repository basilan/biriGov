# Healthcare AI Governance Agent - Frontend

Executive dashboard for AI-powered healthcare claims validation with cost reduction demonstration capabilities.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Open browser to http://localhost:3000
```

## 🏥 Healthcare Features

- **Executive Dashboard**: Real-time metrics and cost tracking
- **Claims Validation**: AI-powered medical necessity review  
- **Cost Management**: Budget monitoring with $50 demo limit
- **Healthcare Styling**: Professional medical interface design
- **Compliance Ready**: HIPAA-aware logging and audit trails

## 📱 Tech Stack

- **React 18.2.0** with TypeScript 5.2.2
- **Vite 4.4.9** for fast development and building
- **Tailwind CSS 3.3.3** with healthcare color palette
- **React Query** for API state management
- **Zustand** for local state management
- **Vitest** for testing with 85% coverage requirement

## 🎨 Healthcare Design System

### Color Palette
- **Medical Blue**: Primary healthcare professional colors
- **Health Green**: Success states and approvals
- **Clinical Gray**: Professional neutral tones
- **Alert Orange**: Warnings and compliance issues
- **Danger Red**: Errors and denied claims

### Typography
- **Font**: Inter for professional medical readability
- **Weights**: 300-700 for executive presentation hierarchy

## 📊 Executive Dashboard Features

- Real-time cost tracking with budget alerts
- Claims processing metrics and ROI calculations
- AI confidence scores and compliance validation
- Healthcare professional styling and components
- Screenshot-ready results for presentations

## 🧪 Testing

```bash
# Run tests
npm run test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:ui
```

## 🏗️ Build & Deploy

```bash
# Type checking
npm run type-check

# Linting
npm run lint

# Production build
npm run build

# Preview production build
npm run preview
```

## 🔧 Environment Configuration

Copy `.env.example` to `.env.local` and configure:

```env
VITE_API_BASE_URL=http://localhost:8000
VITE_DEMO_BUDGET_LIMIT=50.00
VITE_COST_ALERT_THRESHOLD=45.00
VITE_COMPANY_NAME="Your Healthcare Corp"
VITE_DEMO_MODE=true
```

## 📁 Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── common/         # Common utility components
│   ├── layout/         # Layout components
│   └── claims/         # Claims-specific components
├── pages/              # Route pages
├── services/           # API services
├── stores/             # Zustand state stores
├── hooks/              # Custom React hooks
├── utils/              # Utility functions
├── types/              # TypeScript type definitions
├── config/             # Configuration files
└── test/               # Test utilities and setup
```

## 🏥 Healthcare Compliance

- HIPAA-aware logging (configurable)
- Audit trail capabilities
- No PHI in frontend code
- Secure error handling
- Healthcare professional UI standards

## 📈 Performance

- Code splitting for optimal loading
- Lazy loading for large components
- Image optimization
- Service worker for offline capability
- Performance monitoring integration

## 🔒 Security

- CSP headers for XSS protection
- Secure environment variable handling
- Input sanitization
- Error boundary protection
- Healthcare data encryption ready