import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_badge.dart';
import '../theme/app_theme.dart';
import '../models/diary.dart';
import '../services/api_service.dart';

final _diaryDetailProvider = FutureProvider.family<Diary, int>((ref, id) async {
  final json = await ApiService().getDiary(id);
  return Diary.fromJson(json);
});

class AiResultPage extends ConsumerWidget {
  final int diaryId;
  const AiResultPage({super.key, required this.diaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryAsync = ref.watch(_diaryDetailProvider(diaryId));

    return diaryAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        appBar: AppBar(title: const Text('AI 分析')),
        body: Center(child: Text('加载失败: $e')),
      ),
      data: (diary) => _buildResult(context, diary),
    );
  }

  Widget _buildResult(BuildContext context, Diary diary) {
    final analysis = diary.aiAnalysis;
    final mood = analysis?.mood ?? diary.moodTag;

    return OceanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('AI 分析'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mood card
              GlassCard(
                child: Column(
                  children: [
                    Icon(
                      AppTheme.moodIcon(mood),
                      size: 48,
                      color: AppTheme.moodColor(mood),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppTheme.moodLabel(mood),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.moodColor(mood),
                      ),
                    ),
                    if (analysis != null) ...[
                      const SizedBox(height: 8),
                      // Intensity bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '情绪强度',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ...List.generate(10, (i) {
                            return Container(
                              width: 8,
                              height: 20,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: i < analysis.intensity
                                    ? AppTheme.moodColor(mood)
                                        .withOpacity(0.3 + 0.07 * i)
                                    : Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // AI response
              if (analysis != null && analysis.summary.isNotEmpty)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 18,
                              color: Colors.white.withOpacity(0.6)),
                          const SizedBox(width: 8),
                          Text(
                            'AI 的话',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        analysis.summary,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // Keywords
              if (analysis != null && analysis.keywords.isNotEmpty)
                GlassCard(
                  opacity: 0.08,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '关键词',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: analysis.keywords
                            .map((k) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.moodColor(mood)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.moodColor(mood)
                                          .withOpacity(0.25),
                                    ),
                                  ),
                                  child: Text(
                                    k,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.moodColor(mood),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // Original content
              GlassCard(
                opacity: 0.06,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '原文',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const Spacer(),
                        MoodBadge(mood: diary.moodTag, size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      diary.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Back button
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
