import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveLayout {
  static bool get isMobile => defaultTargetPlatform == TargetPlatform.android || 
                              defaultTargetPlatform == TargetPlatform.iOS;
  
  static bool get isWeb => kIsWeb;
  
  static bool get isDesktop => defaultTargetPlatform == TargetPlatform.windows || 
                              defaultTargetPlatform == TargetPlatform.macOS || 
                              defaultTargetPlatform == TargetPlatform.linux;
  
  static bool get isTablet => _isTablet();
  
  static bool _isTablet() {
    if (isWeb) {
      // For web, check screen size
      final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
      return data.size.shortestSide >= 600;
    }
    return false; // For mobile, assume phone unless specified
  }
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static double getResponsiveValue(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double? web,
  }) {
    if (isWeb && web != null) return web;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isMobile && mobile != null) return mobile;
    
    // Default fallback
    return mobile ?? 16.0;
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? web,
  }) {
    if (isWeb && web != null) return web;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isMobile && mobile != null) return mobile;
    
    // Default fallback
    return mobile ?? const EdgeInsets.all(16.0);
  }
  
  static double getResponsiveFontSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double? web,
  }) {
    if (isWeb && web != null) return web;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isMobile && mobile != null) return mobile;
    
    // Default fallback
    return mobile ?? 16.0;
  }
  
  static Widget responsiveBuilder({
    required BuildContext context,
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? web,
  }) {
    if (isWeb && web != null) return web;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isMobile && mobile != null) return mobile;
    
    // Default fallback
    return mobile ?? const SizedBox.shrink();
  }
  
  static bool shouldShowMobileLayout(BuildContext context) {
    return isMobile || (isWeb && getScreenWidth(context) < 768);
  }
  
  static bool shouldShowTabletLayout(BuildContext context) {
    return isTablet || (isWeb && getScreenWidth(context) >= 768 && getScreenWidth(context) < 1024);
  }
  
  static bool shouldShowDesktopLayout(BuildContext context) {
    return isDesktop || (isWeb && getScreenWidth(context) >= 1024);
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.responsiveBuilder(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
      web: web ?? desktop ?? tablet ?? mobile,
    );
  }
}
