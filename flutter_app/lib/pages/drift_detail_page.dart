import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_badge.dart';
import '../providers/drift_provider.dart';
import '../theme/app_theme.dart';

class DriftDetailPage extends ConsumerWidget {
  final int bottleId;
  const DriftDetailPage({super.key, required this.bottleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(bottleJourneyProvider(bottleId));

    return journeyAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        appBar: AppBar(title: const Text('漂流旅程')),
        body: Center(
          child: Text(
            e.toString().contains('403') ? '无权查看此漂流瓶旅程' : '加载失败',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
      data: (bottle) {
        final mood = bottle.moodTag;
        final color = AppTheme.moodColor(mood);

        return OceanBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('漂流旅程'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Original diary
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.article_outlined,
                                size: 16,
                                color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Text(
                              '原文',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const Spacer(),
                            MoodBadge(mood: mood, size: 22),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bottle.diaryContent,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(bottle.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Journey timeline
                  if (bottle.responses.isNotEmpty) ...[
                    Text(
                      '旅途足迹',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...bottle.responses.map((r) {
                      final isLast = r == bottle.responses.last;
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline
                            SizedBox(
                              width: 30,
                              child: Column(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withOpacity(0.2),
                                      border: Border.all(
                                          color: color.withOpacity(0.4)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${r.stationNumber}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 1.5,
                                        color: color.withOpacity(0.2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: GlassCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                opacity: 0.08,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateFormat('MM/dd HH:mm')
                                          .format(r.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else
                    GlassCard(
                      opacity: 0.06,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.waves,
                                  size: 36,
                                  color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 8),
                              Text(
                                '漂流瓶还在海上漂流...',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Status
                  GlassCard(
                    opacity: 0.06,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(
                          '经过',
                          '${bottle.currentStation} 站',
                          Icons.location_on_outlined,
                          color,
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _stat(
                          '状态',
                          bottle.status == 'drifting' ? '漂流中' : '已停靠',
                          Icons.sailing,
                          color,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.6)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.white.withOpacity(0.4))),
      ],
    );
  }
}
