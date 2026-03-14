import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodBadge extends StatelessWidget {
  final String mood;
  final bool showLabel;
  final double size;

  const MoodBadge({
    super.key,
    required this.mood,
    this.showLabel = true,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.moodColor(mood);
    final label = AppTheme.moodLabel(mood);
    final icon = AppTheme.moodIcon(mood);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 10 : 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size * 0.6),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
