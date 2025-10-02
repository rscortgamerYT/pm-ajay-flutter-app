# PM-AJAY - Government Project Management System

A comprehensive Flutter web application for managing government projects under the Prime Minister - Accelerated Jammu and Kashmir Yojana (PM-AJAY) program.

## 🚀 Quick Links

- **[Quick Start Guide](docs/QUICK_START.md)** - Get started in minutes
- **[Vercel Deployment Guide](docs/VERCEL_DEPLOYMENT_GUIDE.md)** - Complete deployment instructions
- **[API Documentation](docs/API_DOCUMENTATION.md)** - API reference
- **[Architecture Overview](docs/ARCHITECTURE.md)** - System design

## 📋 Overview

PM-AJAY is an enterprise-grade government project management platform built with Flutter for web, featuring:

- **Real-time Collaboration**: WebSocket-based live updates
- **Offline-First Architecture**: Hive local storage with Firebase sync
- **AI-Powered Features**: Intelligent project insights and recommendations
- **Blockchain Integration**: Secure and transparent project tracking
- **Comprehensive Security**: JWT authentication, encryption, and audit trails
- **Performance Optimized**: Dual-layer caching, lazy loading, code splitting
- **Citizen Portal**: Public transparency and engagement
- **Advanced Reporting**: Interactive dashboards and analytics

## 🛠 Technology Stack

### Frontend
- **Flutter**: 3.24.0 (Web)
- **Dart**: 3.0+
- **State Management**: Riverpod
- **UI Components**: Material Design 3

### Backend & Services
- **Database**: Firebase Firestore
- **Local Storage**: Hive
- **Authentication**: Firebase Auth + JWT
- **Real-time**: WebSocket
- **File Storage**: Firebase Storage
- **Analytics**: Custom Analytics Service
- **Monitoring**: Crash Reporting Service

### Deployment
- **Hosting**: Vercel
- **CI/CD**: GitHub Actions (optional)
- **Environment Management**: Multi-environment support

## 📦 Installation

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.0+
- Node.js & npm (for Vercel CLI)
- Git

### Setup

```bash
# Navigate to project directory
cd c:/Users/royal/Desktop/SIH_NEW_2

# Install dependencies
flutter pub get

# Run in development mode
flutter run -d chrome --dart-define=ENVIRONMENT=development
```

## 🚀 Deployment

### Quick Deploy to Vercel

**Windows:**
```bash
deploy.bat prod
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh prod
```

### Manual Deployment

```bash
# Build for production
flutter build web --release --dart-define=ENVIRONMENT=production

# Deploy with Vercel CLI
vercel --prod
```

See [Vercel Deployment Guide](docs/VERCEL_DEPLOYMENT_GUIDE.md) for detailed instructions.

## 📁 Project Structure

```
pm_ajay/
├── lib/
│   ├── core/
│   │   ├── config/           # App configuration
│   │   ├── constants/        # Constants and enums
│   │   ├── services/         # Core services
│   │   ├── theme/            # Theme configuration
│   │   └── utils/            # Utility functions
│   ├── features/
│   │   ├── auth/             # Authentication
│   │   ├── projects/         # Project management
│   │   ├── agencies/         # Agency management
│   │   ├── dashboard/        # Analytics dashboard
│   │   ├── documents/        # Document management
│   │   ├── reports/          # Reporting system
│   │   ├── collaboration/    # Collaboration tools
│   │   ├── citizen_portal/   # Public portal
│   │   └── compliance/       # Compliance monitoring
│   ├── shared/
│   │   ├── models/           # Data models
│   │   ├── widgets/          # Reusable widgets
│   │   └── providers/        # Shared providers
│   └── main.dart             # Application entry point
├── test/
│   ├── unit/                 # Unit tests
│   ├── widget/               # Widget tests
│   └── integration/          # Integration tests
├── docs/                     # Documentation
├── build/web/               # Build output
├── vercel.json              # Vercel configuration
├── deploy.bat               # Windows deployment script
└── deploy.sh                # Linux/Mac deployment script
```

## ✨ Features

### Core Features
- ✅ User Authentication & Authorization (Role-based)
- ✅ Project Creation & Management
- ✅ Real-time Updates (WebSocket)
- ✅ Offline Support (Hive + Firebase sync)
- ✅ Document Management
- ✅ Advanced Reporting & Analytics
- ✅ Interactive Dashboards
- ✅ Audit Trail & Compliance Monitoring

### Advanced Features
- ✅ AI-Powered Project Insights
- ✅ Blockchain Integration for Transparency
- ✅ Geofencing & Location Tracking
- ✅ Team Collaboration Tools
- ✅ Citizen Portal for Public Engagement
- ✅ Multi-language Support
- ✅ Responsive Design
- ✅ PWA Support

### Performance Features
- ✅ Dual-layer Caching (Memory + Disk)
- ✅ Lazy Loading & Code Splitting
- ✅ Image Optimization
- ✅ Data Prefetching
- ✅ Memory Management
- ✅ Network Request Optimization

### Security Features
- ✅ JWT Token Authentication
- ✅ Data Encryption (AES-256)
- ✅ Secure Storage
- ✅ HTTPS Enforcement
- ✅ XSS Protection
- ✅ CSRF Protection
- ✅ Role-based Access Control

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/performance_service_test.dart

# Run integration tests
flutter test integration_test/
```

**Test Coverage:**
- Unit Tests: Core services and utilities
- Widget Tests: UI components
- Integration Tests: User workflows

## 📊 Monitoring

### Analytics
Track user behavior and app usage through [`AnalyticsService`](lib/core/services/analytics_service.dart):
- Page views
- User events
- Feature adoption
- Performance metrics

### Crash Reporting
Monitor app stability with [`CrashReportingService`](lib/core/services/crash_reporting_service.dart):
- Error tracking
- Stack traces
- User impact analysis
- Crash trends

### Performance Monitoring
Optimize app performance using [`PerformanceService`](lib/core/services/performance_service.dart):
- Load times
- API response times
- Memory usage
- Network efficiency

## 🔧 Configuration

### Environment Variables

Create `.env` file in project root:

```env
# Environment
ENVIRONMENT=development

# API Configuration
API_KEY=your_api_key
API_BASE_URL=https://api.pm-ajay.gov.in

# Firebase
FIREBASE_PROJECT_ID=pm-ajay-prod
FIREBASE_API_KEY=your_firebase_key

# Security
ENCRYPTION_KEY=your_encryption_key
JWT_SECRET=your_jwt_secret

# Features
ENABLE_AI_FEATURES=true
ENABLE_BLOCKCHAIN=true
ENABLE_ANALYTICS=true
```

### Build Configurations

**Development:**
```bash
flutter build web --dart-define=ENVIRONMENT=development
```

**Staging:**
```bash
flutter build web --dart-define=ENVIRONMENT=staging
```

**Production:**
```bash
flutter build web --dart-define=ENVIRONMENT=production
```

## 📖 Documentation

- **[Quick Start Guide](docs/QUICK_START.md)** - Getting started
- **[Vercel Deployment](docs/VERCEL_DEPLOYMENT_GUIDE.md)** - Deployment instructions
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture
- **[API Documentation](docs/API_DOCUMENTATION.md)** - API reference
- **[Contributing](docs/CONTRIBUTING.md)** - Contribution guidelines

## 🏗 Development Phases

All 16 phases completed:

1. ✅ Core Architecture & State Management
2. ✅ Authentication & Security
3. ✅ Data Persistence & Offline Support
4. ✅ Real-time Updates & WebSocket
5. ✅ UI/UX Enhancements
6. ✅ AI Features Integration
7. ✅ Blockchain Integration
8. ✅ Citizen Portal
9. ✅ Document Management
10. ✅ Advanced Reporting
11. ✅ Geofencing & Location Services
12. ✅ Collaboration Tools
13. ✅ Compliance Monitoring
14. ✅ Performance Optimizations
15. ✅ Testing Infrastructure
16. ✅ Deployment & Monitoring

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Create an issue on GitHub
- Email: support@pm-ajay.gov.in
- Documentation: [docs/](docs/)

## 🎯 Roadmap

Future enhancements:
- [ ] Mobile app versions (iOS/Android)
- [ ] Advanced ML/AI features
- [ ] Enhanced blockchain features
- [ ] Multi-tenancy support
- [ ] Advanced workflow automation

## 👥 Team

Developed for the Smart India Hackathon 2024 by Team [Your Team Name]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Vercel for hosting platform
- Open source community

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Status:** Production Ready 🚀