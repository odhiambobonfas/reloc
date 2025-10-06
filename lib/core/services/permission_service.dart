import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      if (kIsWeb) {
        // Web doesn't need explicit permission for camera
        return true;
      }
      
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting camera permission: $e');
      }
      return false;
    }
  }

  /// Request photo library permission
  static Future<bool> requestPhotoLibraryPermission() async {
    try {
      if (kIsWeb) {
        // Web doesn't need explicit permission for photo library
        return true;
      }
      
      final status = await Permission.photos.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting photo library permission: $e');
      }
      return false;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      if (kIsWeb) {
        // Web location permission is handled by browser
        return true;
      }
      
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return false;
    }
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      if (kIsWeb) {
        // Web microphone permission is handled by browser
        return true;
      }
      
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting microphone permission: $e');
      }
      return false;
    }
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      if (kIsWeb) {
        // Web notification permission is handled by browser
        return true;
      }
      
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
      return false;
    }
  }

  /// Check if permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    try {
      if (kIsWeb) {
        // For web, assume permission is granted (handled by browser)
        return true;
      }
      
      return await permission.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permission status: $e');
      }
      return false;
    }
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      if (kIsWeb) {
        return false;
      }
      
      return await permission.isPermanentlyDenied;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if permission is permanently denied: $e');
      }
      return false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      if (kIsWeb) {
        // Web doesn't have app settings
        return false;
      }
      
      return await ph.openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
      return false;
    }
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    try {
      if (kIsWeb) {
        // For web, return granted status for all permissions
        final Map<Permission, PermissionStatus> result = {};
        for (final permission in permissions) {
          result[permission] = PermissionStatus.granted;
        }
        return result;
      }
      
      return await permissions.request();
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting multiple permissions: $e');
      }
      return {};
    }
  }

  /// Get device-specific permission requirements
  static Future<Map<String, dynamic>> getDevicePermissionInfo() async {
    try {
      final Map<String, dynamic> info = {};
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        info['platform'] = 'Android';
        info['version'] = androidInfo.version.release;
        info['sdkInt'] = androidInfo.version.sdkInt;
        info['brand'] = androidInfo.brand;
        info['model'] = androidInfo.model;
        
        // Android-specific permission requirements
        info['permissions'] = {
          'camera': 'Camera access for taking photos',
          'photos': 'Photo library access for selecting images',
          'location': 'Location access for finding nearby services',
          'microphone': 'Microphone access for voice messages',
          'notification': 'Notification access for updates',
        };
        
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        info['platform'] = 'iOS';
        info['version'] = iosInfo.systemVersion;
        info['model'] = iosInfo.model;
        info['name'] = iosInfo.name;
        
        // iOS-specific permission requirements
        info['permissions'] = {
          'camera': 'Camera access for taking photos',
          'photos': 'Photo library access for selecting images',
          'location': 'Location access for finding nearby services',
          'microphone': 'Microphone access for voice messages',
          'notification': 'Notification access for updates',
        };
        
      } else if (kIsWeb) {
        info['platform'] = 'Web';
        info['permissions'] = {
          'camera': 'Camera access handled by browser',
          'photos': 'Photo library access handled by browser',
          'location': 'Location access handled by browser',
          'microphone': 'Microphone access handled by browser',
          'notification': 'Notification access handled by browser',
        };
      }
      
      return info;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device permission info: $e');
      }
      return {'platform': 'Unknown', 'permissions': {}};
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> checkAllRequiredPermissions() async {
    try {
      final requiredPermissions = [
        Permission.camera,
        Permission.photos,
        Permission.location,
        Permission.microphone,
        Permission.notification,
      ];
      
      for (final permission in requiredPermissions) {
        if (!await isPermissionGranted(permission)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking all required permissions: $e');
      }
      return false;
    }
  }

  /// Get permission status summary
  static Future<Map<String, String>> getPermissionStatusSummary() async {
    try {
      final permissions = [
        Permission.camera,
        Permission.photos,
        Permission.location,
        Permission.microphone,
        Permission.notification,
      ];
      
      final Map<String, String> summary = {};
      
      for (final permission in permissions) {
        final status = await permission.status;
        summary[permission.toString().split('.').last] = status.toString().split('.').last;
      }
      
      return summary;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting permission status summary: $e');
      }
      return {};
    }
  }
}
