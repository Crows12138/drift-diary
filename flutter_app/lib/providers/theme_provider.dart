import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { system, day, night }

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Resolves to actual day/night based on user choice or system time
final isDayModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeModeProvider);
  switch (mode) {
    case AppThemeMode.day:
      return true;
    case AppThemeMode.night:
      return false;
    case AppThemeMode.system:
      final hour = DateTime.now().hour;
      return hour >= 6 && hour < 18;
  }
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.system);

  void setMode(AppThemeMode mode) => state = mode;

  void toggle() {
    state = AppThemeMode.values[(state.index + 1) % 3];
  }
}
