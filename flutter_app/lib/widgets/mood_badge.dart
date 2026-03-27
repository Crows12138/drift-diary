import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodBadge extends StatelessWidget {
  final String mood;
  final bool showLabel;
  final double size;
  final VoidCallback? onTap;

  const MoodBadge({
    super.key,
    required this.mood,
    this.showLabel = true,
    this.size = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.moodColor(mood);
    final label = AppTheme.moodLabel(mood);
    final icon = AppTheme.moodIcon(mood);

    final capsule = Container(
      height: size,
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 14 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size * 0.5),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: capsule);
    }
    return capsule;
  }
}
