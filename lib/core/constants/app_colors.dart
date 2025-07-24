import 'package:flutter/material.dart';

class AppColors {
  // Core Theme Colors (Dark Mode Inspired)
  static const Color background = Color(0xFF121212);       // Deep background
  static const Color surface = Color(0xFF1E1E1E);           // Cards, sheets, containers
  static const Color primary = Color(0xFF2196F3);           // Blue accent (Samsung-like)
  static const Color primaryVariant = Color(0xFF1976D2);    // Darker blue
  static const Color secondary = Color(0xFFFFA726);         // Orange for contrast
  static const Color secondaryVariant = Color(0xFFF57C00);  // Deeper orange

  static const Color bgDark = Color(0xFF121212); // Replace with your desired dark background color

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);       // White
  static const Color textSecondary = Color(0xFFB0BEC5);     // Light gray
  static const Color textMuted = Color(0xFF757575);         // Dimmer text

  // Status & Feedback Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF29B6F6);

  // Divider and Borders
  static const Color divider = Color(0xFF2C2C2C);
  static const Color border = Color(0xFF3D3D3D);

// Existing color definitions
  // static const Color primary = Color(0xFF123456); // Removed duplicate definition
  static const Color backgroundLight = Color(0xFFF5F5F5); // Renamed to avoid conflict
  static const Color primaryText = Color(0xFF222222);
  // ... other color definitions

  static const Color card = Color(0xFFFFFFFF); // Add this line or choose your preferred card color
  // Button Colors
  static const Color buttonBackground = primary;
  static const Color buttonText = Colors.white;
  static const Color buttonDisabled = Color(0xFF616161);

  // ... other color definitions

  static const Color accent = Color(0xFF00BFAE); // Add this line for accent color
  static const Color cardDark = Color(0xFF23262B);
  static const Color navBar = Color(0xFF1F222A);
  static const Color inputField = Color(0xFF23262B);
  // ... other color definitions

  // Card & Modal Colors
  static const Color cardBackground = surface;
  static const Color modalBackground = Color(0xFF1A1A1A);

  // Icon Colors
  static const Color iconColor = Colors.white70;

  // Shadows
  static const Color shadow = Colors.black45;

  // Gradient Example (if used)
  static const LinearGradient appGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
