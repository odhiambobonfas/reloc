import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          if (kDebugMode) {
            print('Connectivity error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing connectivity service: $e');
      }
    }
  }

  /// Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
      
      if (kDebugMode) {
        print('Connection status changed: ${_isConnected ? 'Connected' : 'Disconnected'}');
        print('Connection type: $result');
      }
    }
  }

  /// Check current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return ConnectivityResult.none;
    }
  }

  /// Get detailed connection info
  Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final info = <String, dynamic>{
        'isConnected': result != ConnectivityResult.none,
        'connectionType': result.toString().split('.').last,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add platform-specific information
      if (kIsWeb) {
        info['platform'] = 'Web';
        info['userAgent'] = 'Web Browser';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        info['platform'] = 'Android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        info['platform'] = 'iOS';
      }

      return info;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting connection info: $e');
      }
      return {
        'isConnected': false,
        'connectionType': 'Unknown',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Wait for connection to be available
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;
    
    try {
      await connectionStatus
          .where((connected) => connected)
          .first
          .timeout(timeout);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Timeout waiting for connection: $e');
      }
      return false;
    }
  }

  /// Check if connection is stable (connected for a minimum duration)
  Future<bool> isConnectionStable({Duration minimumDuration = const Duration(seconds: 5)}) async {
    if (!_isConnected) return false;
    
    try {
      // Wait for the minimum duration to ensure connection is stable
      await Future.delayed(minimumDuration);
      return _isConnected;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connection stability: $e');
      }
      return false;
    }
  }

  /// Get connection quality indicator
  Future<String> getConnectionQuality() async {
    try {
      if (!_isConnected) return 'No Connection';
      
      final result = await _connectivity.checkConnectivity();
      
      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi - Excellent';
        case ConnectivityResult.mobile:
          return 'Mobile - Good';
        case ConnectivityResult.ethernet:
          return 'Ethernet - Excellent';
        case ConnectivityResult.vpn:
          return 'VPN - Good';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth - Fair';
        case ConnectivityResult.other:
          return 'Other - Unknown';
        case ConnectivityResult.none:
        default:
          return 'No Connection';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting connection quality: $e');
      }
      return 'Unknown';
    }
  }

  /// Check if connection is suitable for specific operations
  Future<bool> isConnectionSuitableFor({
    required String operation,
    Duration? timeout,
  }) async {
    try {
      if (!_isConnected) return false;
      
      final result = await _connectivity.checkConnectivity();
      
      switch (operation.toLowerCase()) {
        case 'upload':
        case 'download':
          // High bandwidth operations need stable connections
          return result == ConnectivityResult.wifi || 
                 result == ConnectivityResult.ethernet ||
                 result == ConnectivityResult.mobile;
        
        case 'streaming':
        case 'video':
          // Video streaming needs good bandwidth
          return result == ConnectivityResult.wifi || 
                 result == ConnectivityResult.ethernet;
        
        case 'chat':
        case 'message':
          // Basic messaging works with any connection
          return result != ConnectivityResult.none;
        
        case 'location':
        case 'gps':
          // Location services work offline
          return true;
        
        default:
          return result != ConnectivityResult.none;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connection suitability: $e');
      }
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}

/// Global instance for easy access
final connectivityService = ConnectivityService();
