#!/bin/bash

# Reloc - Cross-Platform Build Script
# This script builds the Flutter app for all supported platforms

set -e

echo "🚀 Starting Reloc Cross-Platform Build Process..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    print_status "Checking Flutter installation..."
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    flutter --version
    print_success "Flutter is available"
}

# Clean previous builds
clean_builds() {
    print_status "Cleaning previous builds..."
    flutter clean
    print_success "Builds cleaned"
}

# Get dependencies
get_dependencies() {
    print_status "Getting Flutter dependencies..."
    flutter pub get
    print_success "Dependencies updated"
}

# Build for Android
build_android() {
    print_status "Building for Android..."
    
    # Check if Android build is possible
    if ! flutter doctor | grep -q "Android toolchain"; then
        print_warning "Android toolchain not found, skipping Android build"
        return 0
    fi
    
    # Build APK
    flutter build apk --release
    print_success "Android APK built successfully"
    
    # Build App Bundle (for Play Store)
    flutter build appbundle --release
    print_success "Android App Bundle built successfully"
    
    echo "Android builds located in:"
    echo "  APK: build/app/outputs/flutter-apk/app-release.apk"
    echo "  Bundle: build/app/outputs/bundle/release/app-release.aab"
}

# Build for iOS
build_ios() {
    print_status "Building for iOS..."
    
    # Check if iOS build is possible
    if ! flutter doctor | grep -q "Xcode"; then
        print_warning "Xcode not found, skipping iOS build"
        return 0
    fi
    
    # Build iOS
    flutter build ios --release --no-codesign
    print_success "iOS build completed successfully"
    
    echo "iOS build located in: build/ios/archive/Runner.xcarchive"
}

# Build for Web
build_web() {
    print_status "Building for Web..."
    
    # Build web
    flutter build web --release
    print_success "Web build completed successfully"
    
    echo "Web build located in: build/web/"
}

# Build for Desktop (if supported)
build_desktop() {
    print_status "Building for Desktop platforms..."
    
    # Check if desktop builds are supported
    if ! flutter config --list | grep -q "enable-windows-desktop\|enable-macos-desktop\|enable-linux-desktop"; then
        print_warning "Desktop builds not enabled, skipping desktop builds"
        return 0
    fi
    
    # Build for Windows
    if flutter config --list | grep -q "enable-windows-desktop.*true"; then
        print_status "Building for Windows..."
        flutter build windows --release
        print_success "Windows build completed"
    fi
    
    # Build for macOS
    if flutter config --list | grep -q "enable-macos-desktop.*true"; then
        print_status "Building for macOS..."
        flutter build macos --release
        print_success "macOS build completed"
    fi
    
    # Build for Linux
    if flutter config --list | grep -q "enable-linux-desktop.*true"; then
        print_status "Building for Linux..."
        flutter build linux --release
        print_success "Linux build completed"
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    # Unit tests
    flutter test
    print_success "Unit tests passed"
    
    # Integration tests (if they exist)
    if [ -d "integration_test" ]; then
        print_status "Running integration tests..."
        flutter test integration_test/
        print_success "Integration tests passed"
    fi
}

# Analyze code
analyze_code() {
    print_status "Analyzing code..."
    flutter analyze
    print_success "Code analysis completed"
}

# Show build summary
show_summary() {
    echo ""
    echo "🎉 Build Summary"
    echo "================"
    echo "All builds completed successfully!"
    echo ""
    echo "Build outputs:"
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "✅ Android APK: build/app/outputs/flutter-apk/app-release.apk"
    fi
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        echo "✅ Android Bundle: build/app/outputs/bundle/release/app-release.aab"
    fi
    
    if [ -d "build/ios/archive" ]; then
        echo "✅ iOS: build/ios/archive/"
    fi
    
    if [ -d "build/web" ]; then
        echo "✅ Web: build/web/"
    fi
    
    if [ -d "build/windows" ]; then
        echo "✅ Windows: build/windows/"
    fi
    
    if [ -d "build/macos" ]; then
        echo "✅ macOS: build/macos/"
    fi
    
    if [ -d "build/linux" ]; then
        echo "✅ Linux: build/linux/"
    fi
    
    echo ""
    echo "📱 Next steps:"
    echo "  - Test the builds on target devices"
    echo "  - Deploy web build to hosting service"
    echo "  - Submit mobile apps to app stores"
    echo ""
}

# Main build process
main() {
    local start_time=$(date +%s)
    
    print_status "Starting build process at $(date)"
    
    # Pre-build checks
    check_flutter
    clean_builds
    get_dependencies
    
    # Code quality checks
    analyze_code
    run_tests
    
    # Platform builds
    build_android
    build_ios
    build_web
    build_desktop
    
    # Show results
    show_summary
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Build process completed in ${duration} seconds"
}

# Handle command line arguments
case "${1:-all}" in
    "android")
        check_flutter
        clean_builds
        get_dependencies
        build_android
        ;;
    "ios")
        check_flutter
        clean_builds
        get_dependencies
        build_ios
        ;;
    "web")
        check_flutter
        clean_builds
        get_dependencies
        build_web
        ;;
    "desktop")
        check_flutter
        clean_builds
        get_dependencies
        build_desktop
        ;;
    "test")
        check_flutter
        get_dependencies
        run_tests
        ;;
    "analyze")
        check_flutter
        get_dependencies
        analyze_code
        ;;
    "clean")
        clean_builds
        ;;
    "all"|*)
        main
        ;;
esac

echo ""
print_success "Build script completed!"
