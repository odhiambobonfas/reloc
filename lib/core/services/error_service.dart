import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_colors.dart';

class ErrorService {
  /// Initialize error service
  static Future<void> initialize() async {
    try {
      // Error service initialization
      print('Error service initialized');
    } catch (e) {
      print('Failed to initialize error service: $e');
    }
  }

  /// Log error to console
  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    print('❌ Error: $message');
    print('Details: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  /// Show error snackbar with proper styling
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Handle common Firebase errors and return user-friendly messages
  static String getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. You don\'t have permission to perform this action.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again later.';
        case 'not-found':
          return 'The requested resource was not found.';
        case 'already-exists':
          return 'This resource already exists.';
        case 'resource-exhausted':
          return 'Resource limit exceeded. Please try again later.';
        case 'failed-precondition':
          return 'Operation failed due to a precondition not being met.';
        case 'aborted':
          return 'Operation was aborted. Please try again.';
        case 'out-of-range':
          return 'Operation is out of valid range.';
        case 'unimplemented':
          return 'This operation is not implemented yet.';
        case 'internal':
          return 'Internal error occurred. Please try again later.';
        case 'data-loss':
          return 'Data loss occurred. Please check your data and try again.';
        case 'unauthenticated':
          return 'You need to be logged in to perform this action.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle common network errors
  static String getNetworkErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('HttpException')) {
      return 'Network error occurred. Please try again.';
    }
    return 'Network error: ${error.toString()}';
  }

  /// Handle common image/video errors
  static String getMediaErrorMessage(dynamic error) {
    if (error.toString().contains('FileSystemException')) {
      return 'Failed to access media file. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Unsupported media format. Please use a different file.';
    } else if (error.toString().contains('Permission')) {
      return 'Permission denied. Please grant media access and try again.';
    }
    return 'Media error: ${error.toString()}';
  }

  /// Show error dialog with retry option
  static Future<bool> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? retryText,
    String? cancelText,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          if (retryText != null)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(retryText),
            ),
        ],
      ),
    ) ?? false;
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Handle errors with appropriate user feedback
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    StackTrace? stackTrace,
    String? operation,
  }) {
    final operationText = operation != null ? ' during $operation' : '';
    final message = customMessage ?? _getErrorMessage(error);
    
    // Log the error
    logError('Error$operationText: $message', error, stackTrace);
    
    // Show error to user
    showErrorSnackBar(context, message);
  }

  /// Get appropriate error message based on error type
  static String _getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      return getFirebaseErrorMessage(error);
    } else if (error.toString().contains('SocketException') ||
               error.toString().contains('TimeoutException') ||
               error.toString().contains('HttpException')) {
      return getNetworkErrorMessage(error);
    } else if (error.toString().contains('FileSystemException') ||
               error.toString().contains('FormatException') ||
               error.toString().contains('Permission')) {
      return getMediaErrorMessage(error);
    }
    
    return error.toString();
  }

  /// Set user identifier (placeholder for future implementation)
  static Future<void> setUserIdentifier(String userId) async {
    try {
      print('User identifier set: $userId');
    } catch (e) {
      print('Failed to set user identifier: $e');
    }
  }

  /// Set custom key (placeholder for future implementation)
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      print('Custom key set: $key = $value');
    } catch (e) {
      print('Failed to set custom key: $e');
    }
  }

  /// Enable/disable error collection (placeholder for future implementation)
  static Future<void> setErrorCollectionEnabled(bool enabled) async {
    try {
      print('Error collection ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('Failed to set error collection: $e');
    }
  }
}
