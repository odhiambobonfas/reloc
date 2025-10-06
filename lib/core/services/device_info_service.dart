import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  PackageInfo? _packageInfo;

  /// Initialize device info service
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing device info service: $e');
      }
    }
  }

  /// Get comprehensive device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<String, dynamic> info = {};
      
      // Add package info
      if (_packageInfo != null) {
        info['appName'] = _packageInfo!.appName;
        info['packageName'] = _packageInfo!.packageName;
        info['version'] = _packageInfo!.version;
        info['buildNumber'] = _packageInfo!.buildNumber;
      }
      
      // Add platform-specific info
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        info.addAll({
          'platform': 'Android',
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
          'manufacturer': androidInfo.manufacturer,
          'fingerprint': androidInfo.fingerprint,
          'bootloader': androidInfo.bootloader,
          'host': androidInfo.host,
          'tags': androidInfo.tags,
          'type': androidInfo.type,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'supportedAbis': androidInfo.supportedAbis,
          'supported32BitAbis': androidInfo.supported32BitAbis,
          'supported64BitAbis': androidInfo.supported64BitAbis,
        });
        
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        info.addAll({
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'utsname': {
            'sysname': iosInfo.utsname.sysname,
            'nodename': iosInfo.utsname.nodename,
            'release': iosInfo.utsname.release,
            'version': iosInfo.utsname.version,
            'machine': iosInfo.utsname.machine,
          },
        });
        
      } else if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        info.addAll({
          'platform': 'Web',
          'browserName': webInfo.browserName.name,
          'appVersion': webInfo.appVersion,
          'appName': webInfo.appName,
          'userAgent': webInfo.userAgent,
          'webPlatform': webInfo.platform,
          'vendor': webInfo.vendor,
          'language': webInfo.language,
          'languages': webInfo.languages,
          'hardwareConcurrency': webInfo.hardwareConcurrency,
          'maxTouchPoints': webInfo.maxTouchPoints,
        });
        
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        info.addAll({
          'platform': 'Windows',
          'computerName': windowsInfo.computerName,
        });
        
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macosInfo = await _deviceInfo.macOsInfo;
        info.addAll({
          'platform': 'macOS',
          'computerName': macosInfo.computerName,
          'hostName': macosInfo.hostName,
          'osRelease': macosInfo.osRelease,
          'kernelVersion': macosInfo.kernelVersion,
          'activeCPUs': macosInfo.activeCPUs,
          'memorySize': macosInfo.memorySize,
        });
        
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        info.addAll({
          'platform': 'Linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
          'idLike': linuxInfo.idLike,
          'versionCodename': linuxInfo.versionCodename,
          'versionId': linuxInfo.versionId,
          'prettyName': linuxInfo.prettyName,
          'buildId': linuxInfo.buildId,
          'variant': linuxInfo.variant,
          'variantId': linuxInfo.variantId,
          'machineId': linuxInfo.machineId,
        });
      }
      
      // Add common info
      info['timestamp'] = DateTime.now().toIso8601String();
      info['isDebugMode'] = kDebugMode;
      
      return info;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device info: $e');
      }
      return {
        'platform': 'Unknown',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get simplified device info for display
  Future<Map<String, String>> getSimpleDeviceInfo() async {
    try {
      final fullInfo = await getDeviceInfo();
      final simpleInfo = <String, String>{};
      
      if (fullInfo['platform'] == 'Android') {
        simpleInfo['Device'] = '${fullInfo['brand']} ${fullInfo['model']}';
        simpleInfo['Android Version'] = fullInfo['androidVersion'];
        simpleInfo['SDK Level'] = fullInfo['sdkInt'].toString();
      } else if (fullInfo['platform'] == 'iOS') {
        simpleInfo['Device'] = '${fullInfo['name']} ${fullInfo['model']}';
        simpleInfo['iOS Version'] = fullInfo['systemVersion'];
      } else if (fullInfo['platform'] == 'Web') {
        simpleInfo['Browser'] = fullInfo['browserName'];
        simpleInfo['Platform'] = fullInfo['platform'];
      } else if (fullInfo['platform'] == 'Windows') {
        simpleInfo['Computer'] = fullInfo['computerName'];
        simpleInfo['Windows Version'] = '${fullInfo['majorVersion']}.${fullInfo['minorVersion']}';
      } else if (fullInfo['platform'] == 'macOS') {
        simpleInfo['Computer'] = fullInfo['computerName'];
        simpleInfo['macOS Version'] = fullInfo['version'];
      } else if (fullInfo['platform'] == 'Linux') {
        simpleInfo['Distribution'] = fullInfo['prettyName'];
        simpleInfo['Version'] = fullInfo['version'];
      }
      
      simpleInfo['App Version'] = '${fullInfo['version']} (${fullInfo['buildNumber']})';
      
      return simpleInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting simple device info: $e');
      }
      return {
        'Platform': 'Unknown',
        'Error': 'Failed to get device info',
      };
    }
  }

  /// Check if device supports specific features
  Future<bool> supportsFeature(String feature) async {
    try {
      final info = await getDeviceInfo();
      
      switch (feature.toLowerCase()) {
        case 'camera':
          return info['platform'] == 'Android' || 
                 info['platform'] == 'iOS' || 
                 info['platform'] == 'Web';
        
        case 'location':
          return info['platform'] == 'Android' || 
                 info['platform'] == 'iOS' || 
                 info['platform'] == 'Web';
        
        case 'biometrics':
          if (info['platform'] == 'Android') {
            return info['sdkInt'] >= 23; // Android 6.0+
          } else if (info['platform'] == 'iOS') {
            return info['systemVersion'] != null;
          }
          return false;
        
        case 'notifications':
          return info['platform'] == 'Android' || 
                 info['platform'] == 'iOS' || 
                 info['platform'] == 'Web';
        
        case 'file_system':
          return info['platform'] == 'Android' || 
                 info['platform'] == 'iOS';
        
        case 'webview':
          return info['platform'] == 'Android' || 
                 info['platform'] == 'iOS';
        
        default:
          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking feature support: $e');
      }
      return false;
    }
  }

  /// Get device capabilities summary
  Future<Map<String, bool>> getDeviceCapabilities() async {
    try {
      final capabilities = <String, bool>{};
      
      final features = [
        'camera',
        'location',
        'biometrics',
        'notifications',
        'file_system',
        'webview',
        'bluetooth',
        'nfc',
        'fingerprint',
        'face_id',
      ];
      
      for (final feature in features) {
        capabilities[feature] = await supportsFeature(feature);
      }
      
      return capabilities;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device capabilities: $e');
      }
      return {};
    }
  }

  /// Check if device is a physical device (not emulator)
  Future<bool> isPhysicalDevice() async {
    try {
      final info = await getDeviceInfo();
      
      if (info['platform'] == 'Android') {
        return info['isPhysicalDevice'] ?? false;
      } else if (info['platform'] == 'iOS') {
        return info['isPhysicalDevice'] ?? false;
      }
      
      // For other platforms, assume it's a physical device
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if device is physical: $e');
      }
      return true;
    }
  }

  /// Get device performance category
  Future<String> getDevicePerformanceCategory() async {
    try {
      final info = await getDeviceInfo();
      
      if (info['platform'] == 'Android') {
        final sdkInt = info['sdkInt'] ?? 0;
        if (sdkInt >= 30) return 'High Performance'; // Android 11+
        if (sdkInt >= 26) return 'Good Performance'; // Android 8+
        if (sdkInt >= 21) return 'Medium Performance'; // Android 5+
        return 'Low Performance';
      } else if (info['platform'] == 'iOS') {
        final version = info['systemVersion'] ?? '';
        if (version.startsWith('15') || version.startsWith('16') || version.startsWith('17')) {
          return 'High Performance';
        } else if (version.startsWith('13') || version.startsWith('14')) {
          return 'Good Performance';
        } else if (version.startsWith('11') || version.startsWith('12')) {
          return 'Medium Performance';
        }
        return 'Low Performance';
      }
      
      return 'Unknown';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device performance category: $e');
      }
      return 'Unknown';
    }
  }
}

/// Global instance for easy access
final deviceInfoService = DeviceInfoService();
