import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized management of all image assets in the application.
/// 
/// Features:
/// - Organized asset categorization
/// - Resolution-aware image loading
/// - Automatic theme-based asset selection
/// - Pre-caching system
/// - Comprehensive error handling
/// 
/// Usage:
/// 1. Access assets via AppImages.{assetName}
/// 2. Pre-cache assets using precacheCriticalResources()
/// 3. Use getResolutionSpecificImage() for pixel-perfect assets
class AppImages {
  // Base directory structure
  static const String _basePath = 'assets/images';
  static const String _iconsPath = '$_basePath/icons';
  static const String _illustrationsPath = '$_basePath/illustrations';
  static const String _logosPath = '$_basePath/logos';
  static const String _backgroundsPath = '$_basePath/backgrounds';

  // App branding assets
  static const String logo = '$_logosPath/logo.png';
  static const String logoDark = '$_logosPath/logo_dark.png';
  static const String logoLight = '$_logosPath/logo_light.png';
  static const String logoIcon = '$_logosPath/app_icon.png';

  // Authentication assets
  static const String authBackground = '$_backgroundsPath/auth_bg.jpg';
  static const String welcomeIllustration = '$_illustrationsPath/welcome.svg';
  static const String loginHeader = '$_illustrationsPath/login_header.png';

  // Social authentication icons
  static const String googleIcon = '$_iconsPath/social/google.png';
  static const String appleIcon = '$_iconsPath/social/apple.png';
  static const String facebookIcon = '$_iconsPath/social/facebook.png';
  static const String twitterIcon = '$_iconsPath/social/twitter.png';

  // UI components
  static const String emptyState = '$_illustrationsPath/empty_state.svg';
  static const String errorState = '$_illustrationsPath/error_state.svg';
  static const String placeholder = '$_illustrationsPath/placeholder.png';
  static const String loadingAnimation = '$_illustrationsPath/loading.gif';

  // Onboarding illustrations
  static const String onboarding1 = '$_illustrationsPath/onboarding_1.svg';
  static const String onboarding2 = '$_illustrationsPath/onboarding_2.svg';
  static const String onboarding3 = '$_illustrationsPath/onboarding_3.svg';

  // Profile assets
  static const String defaultAvatar = '$_illustrationsPath/default_avatar.png';
  static const String profileHeader = '$_backgroundsPath/profile_header.jpg';

  /// Gets resolution-specific image path based on device pixel density
  /// 
  /// Example: getResolutionSpecificImage('logos/app_logo') returns:
  /// - 'assets/images/logos/app_logo@3x.png' for 3x devices
  /// - 'assets/images/logos/app_logo@2x.png' for 2x devices
  /// - 'assets/images/logos/app_logo.png' for 1x devices
  static String getResolutionSpecificImage(
    String baseName, {
    int? devicePixelRatio,
    String format = 'png',
  }) {
    final ratio = devicePixelRatio ?? WidgetsBinding.instance.window.devicePixelRatio;
    final suffix = ratio >= 3.0
        ? '@3x'
        : ratio >= 2.0
            ? '@2x'
            : '';
    
    return '$_basePath/$baseName$suffix.$format';
  }

  /// Pre-caches essential app images during startup
  static Future<void> precacheCriticalResources(BuildContext context) async {
    try {
      await Future.wait([
        _precacheImage(context, logo),
        _precacheImage(context, logoLight),
        _precacheImage(context, logoDark),
        _precacheImage(context, placeholder),
        _precacheImage(context, defaultAvatar),
      ]);
      debugPrint('✅ Critical images pre-cached successfully');
    } catch (e, stack) {
      debugPrint('❗ Error pre-caching images: $e\n$stack');
    }
  }

  /// Pre-caches images for specific features when needed
  static Future<void> precacheFeatureImages({
    required BuildContext context,
    required List<String> imagePaths,
    bool silent = false,
  }) async {
    try {
      await Future.wait(imagePaths.map((path) => _precacheImage(context, path)));
      if (!silent) debugPrint('✅ Feature images pre-cached: $imagePaths');
    } catch (e) {
      if (!silent) debugPrint('❗ Feature image pre-cache failed: $e');
    }
  }

  /// Returns theme-appropriate logo based on current brightness
  static String getThemeAwareLogo(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? logoDark : logoLight;
  }

  /// Internal image pre-caching helper
  static Future<void> _precacheImage(
    BuildContext context,
    String path, {
    bool silent = true,
  }) async {
    try {
      await precacheImage(AssetImage(path), context);
      if (!silent) debugPrint('🖼️ Pre-cached: $path');
    } catch (e) {
      debugPrint('❌ Failed to pre-cache $path: $e');
      rethrow;
    }
  }

  /// SVG-specific pre-caching (requires flutter_svg package)
  static Future<void> precacheSvg(
    BuildContext context,
    String path,
  ) async {
    try {
      final loader = SvgAssetLoader(path);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
      debugPrint('🖼️ Pre-cached SVG: $path');
    } catch (e) {
      debugPrint('❌ Failed to pre-cache SVG $path: $e');
    }
  }
}