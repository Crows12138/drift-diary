import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Night palette (from sailboat photo) ──
  static const nightGradient = [
    Color(0xFF020B1A),
    Color(0xFF001C31),
    Color(0xFF023249),
    Color(0xFF093B56),
    Color(0xFF46718A),
  ];
  static const nightText = Color(0xFFCDD1DA);
  static const nightAccent = Color(0xFF5B9DB8);
  static const nightSurface = Color(0xFF0A1929);
  static const nightBg = Color(0xFF020B1A);

  // ── Day palette ──
  static const dayGradient = [
    Color(0xFF5A9FCA), // top sky
    Color(0xFF7EB2DD), // sky reflection
    Color(0xFF9DC8E8), // mid sky
    Color(0xFFB8D8F0), // horizon
    Color(0xFF7EB2DD), // ocean
  ];
  static const dayText = Color(0xFF2A3A4A);
  static const dayAccent = Color(0xFF083D77);   // regal navy
  static const dayWood = Color(0xFF7C6354);     // olive wood
  static const dayIvory = Color(0xFFF5F9E9);
  static const daySurface = Color(0xFFF5F9E9);
  static const dayBg = Color(0xFF7EB2DD);

  // ── Helper methods ──
  static List<Color> gradientColors(bool isDayMode) =>
      isDayMode ? dayGradient : nightGradient;

  static Color accentColor(bool isDayMode) =>
      isDayMode ? dayAccent : nightAccent;

  static Color textColor(bool isDayMode) =>
      isDayMode ? dayText : nightText;

  static Color subtextColor(bool isDayMode) =>
      (isDayMode ? dayText : nightText).withOpacity(0.5);

  static Color surfaceColor(bool isDayMode) =>
      isDayMode ? daySurface : nightSurface;

  // ── Night ThemeData ──
  static final night = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      surface: nightSurface,
      primary: nightAccent,
      secondary: Color(0xFFF4C95D),
      onPrimary: Colors.white,
      onSurface: nightText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w500, color: nightText,
      ),
      iconTheme: IconThemeData(color: nightText.withOpacity(0.9)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: nightAccent);
        }
        return TextStyle(fontSize: 12, color: nightText.withOpacity(0.5));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: nightAccent, size: 24);
        }
        return IconThemeData(color: nightText.withOpacity(0.5), size: 24);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: nightText.withOpacity(0.3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: nightAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: nightAccent),
    ),
  );

  // ── Day ThemeData ──
  static final day = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      surface: daySurface,
      primary: dayAccent,
      secondary: dayWood,
      onPrimary: dayIvory,
      onSurface: dayText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w500, color: dayText,
      ),
      iconTheme: IconThemeData(color: dayText.withOpacity(0.9)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: dayAccent);
        }
        return TextStyle(fontSize: 12, color: dayText.withOpacity(0.5));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: dayAccent, size: 24);
        }
        return IconThemeData(color: dayText.withOpacity(0.5), size: 24);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dayAccent.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: dayText.withOpacity(0.3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: dayAccent,
        foregroundColor: dayIvory,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: dayAccent),
    ),
  );

  // ── Mood colors (theme-independent) ──
  static Color moodColor(String mood) {
    return switch (mood) {
      'happy' => const Color(0xFFFFD93D),
      'calm' => const Color(0xFF5BB8A9),
      'anxious' => const Color(0xFFFF8C32),
      'sad' => const Color(0xFF4D96FF),
      'angry' => const Color(0xFFFF6B6B),
      'confused' => const Color(0xFFC084FC),
      'grateful' => const Color(0xFFF472B6),
      _ => nightAccent,
    };
  }

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
