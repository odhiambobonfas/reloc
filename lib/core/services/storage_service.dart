import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StorageService {
  static const String _prefsPrefix = 'reloc_';
  
  /// Shared Preferences Storage
  static Future<bool> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('$_prefsPrefix$key', value);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting string: $e');
      }
      return false;
    }
  }

  static Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_prefsPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting string: $e');
      }
      return null;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool('$_prefsPrefix$key', value);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting bool: $e');
      }
      return false;
    }
  }

  static Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_prefsPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bool: $e');
      }
      return null;
    }
  }

  static Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt('$_prefsPrefix$key', value);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting int: $e');
      }
      return false;
    }
  }

  static Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$_prefsPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting int: $e');
      }
      return null;
    }
  }

  static Future<bool> setDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setDouble('$_prefsPrefix$key', value);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting double: $e');
      }
      return false;
    }
  }

  static Future<double?> getDouble(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('$_prefsPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting double: $e');
      }
      return null;
    }
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList('$_prefsPrefix$key', value);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting string list: $e');
      }
      return false;
    }
  }

  static Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('$_prefsPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting string list: $e');
      }
      return null;
    }
  }

  /// JSON Storage
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting JSON: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting JSON: $e');
      }
      return null;
    }
  }

  /// Object Storage
  static Future<bool> setObject<T>(String key, T value) async {
    try {
      if (value is Map<String, dynamic>) {
        return await setJson(key, value);
      } else if (value is List) {
        final jsonString = jsonEncode(value);
        return await setString(key, jsonString);
      } else {
        final jsonString = jsonEncode(value);
        return await setString(key, jsonString);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting object: $e');
      }
      return false;
    }
  }

  static Future<T?> getObject<T>(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as T;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting object: $e');
      }
      return null;
    }
  }

  /// File Storage
  static Future<String?> getFilePath(String fileName) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory != null) {
        final relocDir = Directory('${directory.path}/reloc');
        if (!await relocDir.exists()) {
          await relocDir.create(recursive: true);
        }
        return '${relocDir.path}/$fileName';
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file path: $e');
      }
      return null;
    }
  }

  static Future<bool> saveFile(String fileName, String content) async {
    try {
      final filePath = await getFilePath(fileName);
      if (filePath != null) {
        final file = File(filePath);
        await file.writeAsString(content);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      return false;
    }
  }

  static Future<String?> readFile(String fileName) async {
    try {
      final filePath = await getFilePath(fileName);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading file: $e');
      }
      return null;
    }
  }

  static Future<bool> deleteFile(String fileName) async {
    try {
      final filePath = await getFilePath(fileName);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }

  /// Cache Management
  static Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_prefsPrefix));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      // Clear file cache
      final cacheDir = await getFilePath('cache');
      if (cacheDir != null) {
        final cacheDirectory = Directory(cacheDir);
        if (await cacheDirectory.exists()) {
          await cacheDirectory.delete(recursive: true);
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
      return false;
    }
  }

  static Future<bool> removeKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('$_prefsPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing key: $e');
      }
      return false;
    }
  }

  /// Storage Info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_prefsPrefix));
      
      int totalSize = 0;
      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          totalSize += value.length;
        }
      }
      
      return {
        'totalKeys': keys.length,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting storage info: $e');
      }
      return {
        'totalKeys': 0,
        'totalSize': 0,
        'totalSizeMB': '0.00',
      };
    }
  }
}
