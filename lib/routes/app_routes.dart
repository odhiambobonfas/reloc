import 'package:flutter/material.dart';

// Auth Screens
import '../views/auth/login_screen.dart';
import '../views/auth/registration_screen.dart';

// Admin Screens
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/user_management_screen.dart';
import '../views/admin/reports_screen.dart';

// Mover Screens
import '../views/home/home_screen.dart'; // Mover's Home
import '../views/home/profile_screen.dart' as profile; // Mover's Profile

// Resident Screens
import '../views/users/resident/resident_profile_screen.dart';

// Shared Screens
import '../views/shared/splash_screen.dart';
import '../views/shared/not_found_screen.dart';

// Models
import '../models/resident_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
  static const String reports = '/admin/reports';

  // Mover Routes
  static const String moverHome = '/mover/home';
  static const String moverDetail = '/mover/detail';
  static const String moverProfile = '/mover/profile';

  // Resident Routes
  static const String residentHome = '/resident/home';
  static const String residentDetail = '/resident/detail';
  static const String residentProfile = '/resident/profile';

  static const String auth = '/auth';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => RegistrationScreen());

      // Admin Routes
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());

      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      // Mover Routes
      case moverHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case moverDetail:
        // Expecting a ResidentModel as argument
        if (settings.arguments is ResidentModel) {
          // TODO: Implement and return MoverDetailScreen using `settings.arguments` as ResidentModel
          return MaterialPageRoute(builder: (_) => const NotFoundScreen());
        }
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());

      case moverProfile:
        return MaterialPageRoute(builder: (_) => const profile.ProfileScreen());

      // Resident Routes
      case residentProfile:
        return MaterialPageRoute(builder: (_) => const ResidentProfileScreen());

      // Unknown Route
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}
