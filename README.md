# PM-AJAY - Government Project Management System

A comprehensive Flutter application for managing PM-AJAY (Prime Minister's Adarsh Gram, GIA, and Hostel) projects across India.

## Overview

PM-AJAY is a government initiative comprising three major components:
- **Adarsh Gram**: Model village development projects
- **GIA (Grant-in-Aid)**: Financial assistance programs
- **Hostel**: Student accommodation facilities

This application streamlines coordination, improves transparency, and optimizes fund and project tracking across all implementing and executing agencies.

## Features

### 🏢 Agency Management
- Comprehensive agency mapping and tracking
- Support for implementing, executing, state, and UT agencies
- Detailed agency profiles with contact information
- Real-time agency status monitoring

### 📊 Digital Dashboard
- Centralized overview of all projects
- Real-time statistics and metrics
- Quick access to key information
- Component-wise breakdowns

### 💰 Fund Flow Tracking
- Track fund allocation and approvals
- Monitor fund utilization
- Transparent disbursement tracking
- Detailed fund statements

### 📁 Project Management
- Complete project lifecycle tracking
- Progress monitoring with visual indicators
- Project status updates
- Timeline management

### 🔔 Notifications System
- Real-time alerts for approvals
- Task assignment notifications
- Deadline reminders
- System-wide announcements

### 📈 Reports & Analytics
- Generate comprehensive reports
- Financial analytics
- Project performance metrics
- Export capabilities

## Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive
- **Backend**: Firebase (Authentication, Cloud Messaging, Analytics)
- **UI Components**: Material Design 3
- **Charts**: FL Chart, Syncfusion Charts

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd pm_ajay
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants and configurations
│   ├── routes/          # Navigation and routing
│   └── theme/           # App theming
├── features/
│   ├── auth/            # Authentication
│   ├── dashboard/       # Main dashboard
│   ├── agencies/        # Agency management
│   ├── projects/        # Project management
│   ├── funds/           # Fund tracking
│   ├── notifications/   # Notifications
│   ├── reports/         # Reports and analytics
│   └── profile/         # User profile
└── main.dart
```

## Key Components

### Authentication
- Secure login system
- Government ID integration support
- Session management

### Dashboard
- Quick stats overview
- Component-wise navigation
- Recent activities
- Action shortcuts

### Agency Module
- List and search agencies
- Filter by type and status
- Detailed agency information
- Project associations

### Project Module
- Track all project components
- Progress indicators
- Budget utilization
- Timeline management

### Fund Module
- Fund request management
- Approval workflow
- Disbursement tracking
- Utilization reports

## User Roles

The system supports multiple user roles:
- **Centre**: Central government officials
- **State**: State government officials
- **UT**: Union Territory officials
- **Agency**: Implementing agency personnel
- **Executing Agency**: Project execution teams

## Configuration

### Firebase Setup (Optional)
1. Create a Firebase project
2. Add Android/iOS apps to the project
3. Download configuration files
4. Place them in the appropriate directories
5. Uncomment Firebase initialization in `main.dart`

### API Configuration
Update the base URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'your-api-url';
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

This is a government project. For contributions, please follow the standard pull request process and ensure all code meets the project's quality standards.

## License

This project is owned by the Government of India and is intended for official use only.

## Support

For technical support or queries:
- Email: support@pmajay.gov.in
- Phone: +91-11-XXXXXXXX

## Version History

- **1.0.0** (October 2025): Initial release
  - Complete app structure
  - Core features implemented
  - Agency, project, and fund management
  - Dashboard and reporting

## Roadmap

### Upcoming Features
- [ ] Real-time monitoring dashboard
- [ ] Advanced analytics with AI insights
- [ ] Offline support with data synchronization
- [ ] Multi-language support
- [ ] Enhanced user role management
- [ ] Document management system
- [ ] Integration with e-governance platforms

---

**PM-AJAY** - Empowering Government Project Management