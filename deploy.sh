#!/bin/bash

# PM-AJAY Flutter Web Deployment Script
# Usage: ./deploy.sh [environment]
# Environments: dev, staging, prod (default: prod)

set -e

ENVIRONMENT=${1:-prod}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting PM-AJAY deployment for environment: $ENVIRONMENT"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "❌ Error: Invalid environment. Use: dev, staging, or prod"
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    exit 1
fi

# Check Vercel CLI installation
if ! command -v vercel &> /dev/null; then
    echo "⚠️  Warning: Vercel CLI not found. Install with: npm install -g vercel"
    echo "Continuing with build only..."
    VERCEL_AVAILABLE=false
else
    VERCEL_AVAILABLE=true
fi

echo "📦 Cleaning previous builds..."
flutter clean

echo "📥 Installing dependencies..."
flutter pub get

echo "🔍 Running code analysis..."
flutter analyze || echo "⚠️  Warning: Analysis issues found, continuing..."

echo "🧪 Running tests..."
flutter test || echo "⚠️  Warning: Some tests failed, continuing..."

echo "🏗️  Building Flutter web app..."
case $ENVIRONMENT in
    dev)
        flutter build web --release --dart-define=ENVIRONMENT=development
        ;;
    staging)
        flutter build web --release --dart-define=ENVIRONMENT=staging
        ;;
    prod)
        flutter build web --release --dart-define=ENVIRONMENT=production
        ;;
esac

echo "✅ Build completed successfully!"
echo "📁 Build output: build/web/"

if [ "$VERCEL_AVAILABLE" = true ]; then
    echo ""
    read -p "🤔 Deploy to Vercel now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Deploying to Vercel..."
        
        if [ "$ENVIRONMENT" = "prod" ]; then
            vercel --prod
        else
            vercel
        fi
        
        echo "✅ Deployment completed!"
    else
        echo "⏭️  Skipping Vercel deployment"
        echo "💡 To deploy manually, run: vercel --prod"
    fi
else
    echo ""
    echo "💡 To deploy to Vercel:"
    echo "   1. Install Vercel CLI: npm install -g vercel"
    echo "   2. Run: vercel --prod"
fi

echo ""
echo "🎉 Done! Your PM-AJAY app is ready."
echo ""
echo "📚 Next steps:"
echo "   1. Test the build locally: cd build/web && python -m http.server 8000"
echo "   2. Configure environment variables in Vercel dashboard"
echo "   3. Set up custom domain (optional)"
echo "   4. Monitor deployment at https://vercel.com"
echo ""
echo "📖 Full deployment guide: docs/VERCEL_DEPLOYMENT_GUIDE.md"