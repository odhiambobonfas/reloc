import 'package:flutter/material.dart';

// Auth Screens
import '../views/auth/login_screen.dart';
import '../views/auth/registration_screen.dart';
import '../views/auth/forgot_password.dart';
import '../views/auth/auth_screen.dart';

// Admin Screens
import '../views/admin/admin_mover_screen.dart';
import '../views/admin/approve_mover_screen.dart';

// Mover Screens
import '../views/home/home_screen.dart'; // Mover's Home
import '../views/home/profile_screen.dart' as profile; // Mover's Profile

// Resident Screens
import '../views/users/resident/resident_profile_screen.dart';

// Shared Screens
import '../views/shared/splash_screen.dart';
import '../views/shared/not_found_screen.dart';
import '../views/home/saved_posts_screen.dart';
import '../views/home/settings/settings_screen.dart';
import '../views/shared/notifications_screen.dart';
import '../views/shared/notification_settings_screen.dart';

import '../views/home/community_screen.dart';

import '../views/chat/chat_listing_screen.dart';
import '../views/chat/chat_detail_screen.dart';

// Models
import '../models/resident_model.dart';

class AppRoutes {
  // 🔹 Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // 🔹 Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
  static const String reports = '/admin/reports';
  static const String approveMover = '/admin/approve-mover';

  // 🔹 Mover Routes
  static const String moverHome = '/mover/home';
  static const String moverDetail = '/mover/detail';
  static const String moverProfile = '/mover/profile';

  // 🔹 Resident Routes
  static const String residentHome = '/resident/home';
  static const String residentDetail = '/resident/detail';
  static const String residentProfile = '/resident/profile';

  // 💬 Chat Routes
  static const String chatList = '/chat';
  static const String chatDetail = '/chat/detail';

  // 🔹 Shared Routes
  static const String savedPosts = '/saved-posts';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notification-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("Navigating to: ${settings.name}");
    switch (settings.name) {
      // ✅ Splash
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      // ✅ Auth
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());

      // ✅ Admin
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminMoverScreen());

      case userManagement:
        return MaterialPageRoute(builder: (_) => const AdminMoverScreen());

      case reports:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());

      case approveMover:
        return MaterialPageRoute(builder: (_) => const ApproveMoverScreen());

      // ✅ Mover
      case moverHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case moverDetail:
        // Expecting a ResidentModel as argument
        if (settings.arguments is ResidentModel) {
          // TODO: Implement and return MoverDetailScreen using `settings.arguments`
          return MaterialPageRoute(builder: (_) => const NotFoundScreen());
        }
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());

      case moverProfile:
        return MaterialPageRoute(builder: (_) => const profile.ProfileScreen());

      // ✅ Resident
      case residentHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case residentProfile:
        return MaterialPageRoute(builder: (_) => const ResidentProfileScreen());

      // ✅ Shared
      case savedPosts:
        return MaterialPageRoute(builder: (_) => const SavedPostsScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case AppRoutes.notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());

      // 💬 Chat Routes
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case chatDetail:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: args['chatId'],
              peerId: args['peerId'],
              peerName: args['peerName'],
              peerPhotoUrl: args['peerPhotoUrl'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());

      // ❌ Unknown route → Not Found
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}
