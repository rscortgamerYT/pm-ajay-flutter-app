# Vercel Deployment Guide for PM-AJAY Flutter Web App

## Prerequisites

1. **Flutter SDK** installed (3.0.0 or higher)
2. **Vercel CLI** installed: `npm install -g vercel`
3. **Git** repository initialized
4. **Vercel account** created at https://vercel.com

## Step 1: Build Flutter Web App

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web with release mode
flutter build web --release --dart-define=ENVIRONMENT=production
```

This creates optimized production build in `build/web/` directory.

## Step 2: Configure Vercel

The [`vercel.json`](../vercel.json) file is already configured with:
- Static file serving from `build/web/`
- Single Page Application routing
- Production environment variables

## Step 3: Deploy to Vercel

### Option A: Deploy via Vercel CLI

```bash
# Login to Vercel
vercel login

# Deploy (first time)
vercel

# Deploy to production
vercel --prod
```

### Option B: Deploy via Git Integration

1. **Push code to GitHub/GitLab/Bitbucket**
   ```bash
   git add .
   git commit -m "Deploy PM-AJAY to Vercel"
   git push origin main
   ```

2. **Connect Repository to Vercel**
   - Go to https://vercel.com/new
   - Import your Git repository
   - Vercel will auto-detect Flutter web project

3. **Configure Build Settings**
   - Framework Preset: `Other`
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

4. **Add Environment Variables** (in Vercel Dashboard)
   ```
   ENVIRONMENT=production
   API_KEY=your_api_key
   FIREBASE_PROJECT_ID=pm-ajay-prod
   ENCRYPTION_KEY=your_encryption_key
   ```

5. **Deploy**
   - Click "Deploy"
   - Vercel will build and deploy automatically

## Step 4: Custom Domain (Optional)

1. Go to your project settings in Vercel
2. Navigate to "Domains"
3. Add your custom domain: `pm-ajay.gov.in`
4. Configure DNS records as instructed by Vercel

## Step 5: Continuous Deployment

Once connected to Git:
- **Automatic deployments** on every push to main branch
- **Preview deployments** for pull requests
- **Instant rollbacks** if needed

## Build Optimization

### Enable Web Renderers

For better performance, specify the renderer:

```bash
# HTML renderer (smaller bundle, better for simple apps)
flutter build web --web-renderer html

# CanvasKit renderer (better performance for complex graphics)
flutter build web --web-renderer canvaskit

# Auto (default, chooses based on device)
flutter build web --web-renderer auto
```

### Code Splitting

The app uses lazy loading for better performance. See [`route_lazy_loading_config.dart`](../lib/core/config/route_lazy_loading_config.dart).

### PWA Support

Enable Progressive Web App features:

```bash
flutter build web --pwa-strategy=offline-first
```

## Monitoring

### Analytics

Analytics are automatically enabled in production via [`analytics_service.dart`](../lib/core/services/analytics_service.dart).

### Crash Reporting

Crash reporting is enabled via [`crash_reporting_service.dart`](../lib/core/services/crash_reporting_service.dart).

### Vercel Analytics

Enable in Vercel Dashboard:
1. Go to your project
2. Navigate to "Analytics"
3. Enable Vercel Analytics

## Troubleshooting

### Build Fails

```bash
# Clear Flutter cache
flutter clean
rm -rf build/

# Rebuild
flutter pub get
flutter build web --release
```

### Assets Not Loading

Ensure `pubspec.yaml` has correct asset paths:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

### CORS Issues

Configure CORS in your backend API or add Vercel headers in [`vercel.json`](../vercel.json):

```json
{
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" }
      ]
    }
  ]
}
```

### Firebase Not Working

1. Update Firebase config in [`firebase_options.dart`](../lib/firebase_options.dart)
2. Enable Firebase Hosting if needed
3. Configure authorized domains in Firebase Console

## Environment-Specific Builds

### Development
```bash
flutter build web --dart-define=ENVIRONMENT=development
```

### Staging
```bash
flutter build web --dart-define=ENVIRONMENT=staging
```

### Production
```bash
flutter build web --dart-define=ENVIRONMENT=production
```

## Performance Optimization

### 1. Enable Tree Shaking
Already enabled in release builds.

### 2. Compress Assets
```bash
# Install optimizer
flutter pub add flutter_native_splash

# Optimize images
flutter pub run flutter_native_splash:create
```

### 3. Minify JavaScript
Automatically done in release builds.

### 4. Use CDN
Vercel provides global CDN automatically.

## Security

### Environment Variables
Never commit sensitive data. Use Vercel environment variables:
- API keys
- Database credentials
- Encryption keys
- Third-party service tokens

### HTTPS
Vercel provides automatic HTTPS for all deployments.

### Security Headers
Add to [`vercel.json`](../vercel.json):
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-XSS-Protection", "value": "1; mode=block" }
      ]
    }
  ]
}
```

## Rollback

If deployment has issues:

```bash
# Via CLI
vercel rollback

# Via Dashboard
# Go to Deployments → Click previous deployment → "Promote to Production"
```

## CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build web
        run: flutter build web --release --dart-define=ENVIRONMENT=production
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

## Monitoring Deployments

### Vercel Dashboard
- Real-time build logs
- Deployment status
- Performance metrics
- Error tracking

### Custom Monitoring
Use built-in services:
- [`analytics_service.dart`](../lib/core/services/analytics_service.dart)
- [`crash_reporting_service.dart`](../lib/core/services/crash_reporting_service.dart)
- [`performance_service.dart`](../lib/core/services/performance_service.dart)

## Support

For issues:
1. Check Vercel deployment logs
2. Review Flutter web build output
3. Test locally: `flutter run -d chrome --release`
4. Check Vercel documentation: https://vercel.com/docs

## Deployment Checklist

- [ ] Flutter web build completes successfully
- [ ] All assets load correctly
- [ ] Environment variables configured
- [ ] Firebase initialized properly
- [ ] API endpoints configured
- [ ] Custom domain configured (if applicable)
- [ ] HTTPS enabled
- [ ] Analytics enabled
- [ ] Crash reporting enabled
- [ ] Performance monitoring active

## Next Steps

After deployment:
1. Test all features on production URL
2. Monitor analytics and error reports
3. Set up alerts for critical errors
4. Configure backup and disaster recovery
5. Document API endpoints and integrations

Your PM-AJAY Flutter web application is now deployed on Vercel! 🚀