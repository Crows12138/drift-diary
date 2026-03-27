import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class WeeklyCalendarStrip extends ConsumerWidget {
  const WeeklyCalendarStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    final diariesAsync = ref.watch(diaryListProvider);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final accent = AppTheme.accentColor(isDayMode);
    final textColor = AppTheme.textColor(isDayMode);

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      opacity: 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = startOfWeek.add(Duration(days: i));
          final isToday =
              day.day == now.day && day.month == now.month && day.year == now.year;
          final hasEntry = diariesAsync.whenOrNull(
                data: (diaries) => diaries.any((d) =>
                    d.createdAt.day == day.day &&
                    d.createdAt.month == day.month &&
                    d.createdAt.year == day.year),
              ) ??
              false;

          return _DayCell(
            weekday: const ['一', '二', '三', '四', '五', '六', '日'][i],
            dayNumber: day.day,
            isToday: isToday,
            hasEntry: hasEntry,
            accent: accent,
            textColor: textColor,
          );
        }),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String weekday;
  final int dayNumber;
  final bool isToday;
  final bool hasEntry;
  final Color accent;
  final Color textColor;

  const _DayCell({
    required this.weekday,
    required this.dayNumber,
    required this.isToday,
    required this.hasEntry,
    required this.accent,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          weekday,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: isToday
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.2),
                  border: Border.all(color: accent, width: 1.5),
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            '$dayNumber',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              color: isToday ? accent : textColor.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasEntry ? accent : Colors.transparent,
          ),
        ),
      ],
    );
  }
}
