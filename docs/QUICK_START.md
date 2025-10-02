# PM-AJAY Quick Start Guide

Get your PM-AJAY Flutter web application running locally or deployed to Vercel in minutes.

## Prerequisites

- **Flutter SDK**: 3.24.0 or higher
- **Dart SDK**: 3.0.0 or higher  
- **Git**: For version control
- **Node.js & npm**: For Vercel CLI (optional, for deployment)

## Local Development

### 1. Clone and Setup

```bash
# Navigate to project directory
cd c:/Users/royal/Desktop/SIH_NEW_2

# Install dependencies
flutter pub get
```

### 2. Configure Environment

Create a `.env` file in the project root:

```env
ENVIRONMENT=development
API_KEY=your_dev_api_key
FIREBASE_PROJECT_ID=pm-ajay-dev
ENCRYPTION_KEY=your_dev_encryption_key
```

### 3. Run the Application

```bash
# Run in development mode
flutter run -d chrome --dart-define=ENVIRONMENT=development

# Or run with hot reload
flutter run -d chrome
```

The app will open in Chrome at `http://localhost:XXXX`

### 4. Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/performance_service_test.dart

# Run with coverage
flutter test --coverage
```

## Building for Production

### Quick Build

```bash
# Windows
deploy.bat prod

# Linux/Mac
chmod +x deploy.sh
./deploy.sh prod
```

### Manual Build

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web --release --dart-define=ENVIRONMENT=production
```

Build output will be in `build/web/`

## Deploy to Vercel

### Option 1: Automated Deployment Script

**Windows:**
```bash
deploy.bat prod
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh prod
```

Follow the prompts to deploy.

### Option 2: Manual Vercel CLI Deployment

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Build the app
flutter build web --release --dart-define=ENVIRONMENT=production

# Deploy
vercel --prod
```

### Option 3: Git Integration

1. **Push to Git repository:**
   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

2. **Connect to Vercel:**
   - Go to https://vercel.com/new
   - Import your repository
   - Configure:
     - Framework: Other
     - Build Command: `flutter build web --release`
     - Output Directory: `build/web`
     - Install Command: `flutter pub get`

3. **Add Environment Variables in Vercel Dashboard:**
   - `ENVIRONMENT=production`
   - `API_KEY=your_prod_api_key`
   - `FIREBASE_PROJECT_ID=pm-ajay-prod`
   - `ENCRYPTION_KEY=your_prod_encryption_key`

4. **Deploy**

## Testing the Deployment

### Local Testing

```bash
# Serve the built app locally
cd build/web
python -m http.server 8000
```

Visit `http://localhost:8000`

### Production Testing

After Vercel deployment, test:

1. **Core Features:**
   - User authentication
   - Project creation/viewing
   - Dashboard functionality
   - Offline mode (disable network)

2. **Performance:**
   - Page load times
   - Asset loading
   - Network requests

3. **Monitoring:**
   - Check Vercel Analytics dashboard
   - Monitor error rates in crash reporting
   - Verify analytics events

## Environment Configuration

### Development (`development`)
- Local API endpoints
- Debug logging enabled
- Mock data available
- Relaxed security

### Staging (`staging`)
- Staging API endpoints
- Limited logging
- Test data
- Production-like security

### Production (`production`)
- Production API endpoints
- Error logging only
- Real data
- Full security enabled

## Common Tasks

### Update Dependencies

```bash
flutter pub upgrade
```

### Clear Cache

```bash
flutter clean
flutter pub get
```

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
flutter format .
```

### Generate Code

```bash
# Generate model files
flutter pub run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
pm_ajay/
├── lib/
│   ├── core/              # Core functionality
│   ├── features/          # Feature modules
│   ├── shared/            # Shared components
│   └── main.dart          # Entry point
├── test/                  # Test files
├── build/web/            # Web build output
├── docs/                  # Documentation
├── vercel.json           # Vercel config
├── deploy.bat            # Windows deployment
└── deploy.sh             # Linux/Mac deployment
```

## Key Features

### Implemented Features
✅ Authentication & Authorization  
✅ Project Management  
✅ Real-time Updates (WebSocket)  
✅ Offline Support (Hive)  
✅ Document Management  
✅ Reporting & Analytics  
✅ Geofencing & Location Tracking  
✅ Collaboration Tools  
✅ Compliance Monitoring  
✅ AI Features  
✅ Blockchain Integration  
✅ Citizen Portal  
✅ Performance Optimization  
✅ Comprehensive Testing  
✅ Deployment Configuration  

### Performance Features
- Dual-layer caching
- Lazy loading
- Image optimization
- Code splitting
- Data prefetching
- Memory management

### Security Features
- JWT authentication
- Data encryption
- Secure storage
- HTTPS enforcement
- XSS protection
- CSRF protection

## Monitoring

### Analytics
View user behavior and app usage:
- Event tracking
- User flows
- Feature adoption
- Performance metrics

### Crash Reporting
Monitor app stability:
- Error tracking
- Stack traces
- User impact analysis
- Crash trends

### Performance Monitoring
Track app performance:
- Load times
- API response times
- Memory usage
- Network efficiency

## Troubleshooting

### Build Fails

```bash
flutter clean
rm -rf build/
flutter pub get
flutter build web --release
```

### Assets Not Loading

Check `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

### CORS Errors

Configure backend CORS or update [`vercel.json`](../vercel.json) headers.

### Firebase Issues

1. Update [`firebase_options.dart`](../lib/firebase_options.dart)
2. Check Firebase Console settings
3. Verify authorized domains

## Getting Help

- **Full Deployment Guide**: [`docs/VERCEL_DEPLOYMENT_GUIDE.md`](VERCEL_DEPLOYMENT_GUIDE.md)
- **Project README**: [`README.md`](../README.md)
- **Vercel Documentation**: https://vercel.com/docs
- **Flutter Documentation**: https://flutter.dev/docs

## Next Steps

After successful deployment:

1. ✅ Verify all features work in production
2. ✅ Set up monitoring alerts
3. ✅ Configure custom domain (optional)
4. ✅ Enable backups
5. ✅ Document API integrations
6. ✅ Train users on the system

Your PM-AJAY application is now ready for production use! 🎉