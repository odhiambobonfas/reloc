import 'package:intl/intl.dart';
import 'dart:math';

class Helpers {
  /// Format timestamp or DateTime to 'MMM dd, yyyy'
  static String formatDate(dynamic date) {
    try {
      if (date == null) return 'N/A';

      DateTime dt;
      if (date is DateTime) {
        dt = date;
      } else if (date is String) {
        dt = DateTime.parse(date);
      } else {
        dt = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
      }

      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Format time to 'hh:mm a'
  static String formatTime(dynamic time) {
    try {
      final dt = (time is DateTime) ? time : DateTime.parse(time.toString());
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return 'Invalid time';
    }
  }

  /// Capitalize first letter
  static String capitalize(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  /// Convert string to title case
  static String titleCase(String input) {
    return input
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }

  /// Generate a random short ID
  static String generateRandomId([int length = 8]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Safe parsing to int
  static int tryParseInt(String? input, [int fallback = 0]) {
    return int.tryParse(input ?? '') ?? fallback;
  }

  /// Safe parsing to double
  static double tryParseDouble(String? input, [double fallback = 0.0]) {
    return double.tryParse(input ?? '') ?? fallback;
  }

  /// Basic email validation
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  /// Check if a string is null, empty, or only spaces
  static bool isNullOrBlank(String? input) {
    return input == null || input.trim().isEmpty;
  }
}
