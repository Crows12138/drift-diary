import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Ocean palette
  static const _bg = Color(0xFF0B1026);
  static const _surface = Color(0xFF142850);
  static const _primary = Color(0xFF5BB8A9);    // seafoam teal
  static const _secondary = Color(0xFFF4C95D);  // warm lantern amber

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent, // let ocean show through
    colorScheme: const ColorScheme.dark(
      surface: _surface,
      primary: _primary,
      secondary: _secondary,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white.withOpacity(0.9)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _primary);
        }
        return TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _primary, size: 24);
        }
        return IconThemeData(color: Colors.white.withOpacity(0.5), size: 24);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _primary),
    ),
  );

  /// 心情对应的颜色
  static Color moodColor(String mood) {
    return switch (mood) {
      'happy' => const Color(0xFFFFD93D),
      'calm' => const Color(0xFF5BB8A9),
      'anxious' => const Color(0xFFFF8C32),
      'sad' => const Color(0xFF4D96FF),
      'angry' => const Color(0xFFFF6B6B),
      'confused' => const Color(0xFFC084FC),
      'grateful' => const Color(0xFFF472B6),
      _ => _primary,
    };
  }

  /// 心情中文名
  static String moodLabel(String mood) {
    return switch (mood) {
      'happy' => '开心',
      'calm' => '平静',
      'anxious' => '焦虑',
      'sad' => '难过',
      'angry' => '生气',
      'confused' => '迷茫',
      'grateful' => '感恩',
      _ => mood,
    };
  }

  /// 心情图标
  static IconData moodIcon(String mood) {
    return switch (mood) {
      'happy' => Icons.sentiment_very_satisfied,
      'calm' => Icons.spa,
      'anxious' => Icons.psychology,
      'sad' => Icons.sentiment_dissatisfied,
      'angry' => Icons.whatshot,
      'confused' => Icons.help_outline,
      'grateful' => Icons.favorite,
      _ => Icons.circle,
    };
  }
}
