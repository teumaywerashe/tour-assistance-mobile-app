import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5000';

  static String imageUrl(String? filename) {
    if (filename == null || filename.isEmpty) return '';
    return '${apiBaseUrl}/uploads/buildings/$filename';
  }

  // Colors
  static const Color accent = Color(0xFF646cff);
  static const Color accentDark = Color(0xFF535bf2);
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color darkBg = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFF1F5F9);

  // Category colors
  static const Map<String, Color> categoryColors = {
    'Academic': Color(0xFF3b82f6),
    'Libraries': Color(0xFF3b82f6),
    'Outdoor': Color(0xFF22c55e),
    'Parking': Color(0xFFf97316),
    'Sports': Color(0xFFef4444),
  };

  static Color categoryColor(String category) =>
      categoryColors[category] ?? accent;

  static const List<String> categories = [
    'All',
    'Academic',
    'Libraries',
    'Sports',
    'Outdoor',
    'Parking',
  ];

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String usernameKey = 'auth_username';
  static const String emailKey = 'auth_email';
  static const String themeModeKey = 'theme_mode';
}
