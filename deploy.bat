@echo off
REM PM-AJAY Flutter Web Deployment Script for Windows
REM Usage: deploy.bat [environment]
REM Environments: dev, staging, prod (default: prod)

setlocal enabledelayedexpansion

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=prod

echo.
echo ========================================
echo PM-AJAY Flutter Web Deployment
echo Environment: %ENVIRONMENT%
echo ========================================
echo.

REM Validate environment
if not "%ENVIRONMENT%"=="dev" if not "%ENVIRONMENT%"=="staging" if not "%ENVIRONMENT%"=="prod" (
    echo [ERROR] Invalid environment. Use: dev, staging, or prod
    exit /b 1
)

REM Check Flutter installation
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

REM Check Vercel CLI installation
where vercel >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Vercel CLI not found. Install with: npm install -g vercel
    echo Continuing with build only...
    set VERCEL_AVAILABLE=false
) else (
    set VERCEL_AVAILABLE=true
)

echo [1/6] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo [ERROR] Flutter clean failed
    exit /b 1
)

echo.
echo [2/6] Installing dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Flutter pub get failed
    exit /b 1
)

echo.
echo [3/6] Running code analysis...
call flutter analyze
if %errorlevel% neq 0 (
    echo [WARNING] Analysis issues found, continuing...
)

echo.
echo [4/6] Running tests...
call flutter test
if %errorlevel% neq 0 (
    echo [WARNING] Some tests failed, continuing...
)

echo.
echo [5/6] Building Flutter web app for %ENVIRONMENT%...
if "%ENVIRONMENT%"=="dev" (
    call flutter build web --release --dart-define=ENVIRONMENT=development
) else if "%ENVIRONMENT%"=="staging" (
    call flutter build web --release --dart-define=ENVIRONMENT=staging
) else (
    call flutter build web --release --dart-define=ENVIRONMENT=production
)

if %errorlevel% neq 0 (
    echo [ERROR] Flutter build failed
    exit /b 1
)

echo.
echo [SUCCESS] Build completed successfully!
echo Build output: build\web\
echo.

if "%VERCEL_AVAILABLE%"=="true" (
    echo [6/6] Deploying to Vercel...
    set /p DEPLOY="Deploy to Vercel now? (y/n): "
    if /i "!DEPLOY!"=="y" (
        echo.
        echo Deploying to Vercel...
        if "%ENVIRONMENT%"=="prod" (
            call vercel --prod
        ) else (
            call vercel
        )
        if %errorlevel% neq 0 (
            echo [ERROR] Vercel deployment failed
            exit /b 1
        )
        echo.
        echo [SUCCESS] Deployment completed!
    ) else (
        echo.
        echo [INFO] Skipping Vercel deployment
        echo To deploy manually, run: vercel --prod
    )
) else (
    echo [6/6] Vercel deployment skipped
    echo.
    echo To deploy to Vercel:
    echo   1. Install Vercel CLI: npm install -g vercel
    echo   2. Run: vercel --prod
)

echo.
echo ========================================
echo Deployment Process Complete!
echo ========================================
echo.
echo Next steps:
echo   1. Test locally: cd build\web ^&^& python -m http.server 8000
echo   2. Configure environment variables in Vercel dashboard
echo   3. Set up custom domain (optional)
echo   4. Monitor deployment at https://vercel.com
echo.
echo Full deployment guide: docs\VERCEL_DEPLOYMENT_GUIDE.md
echo.

endlocal