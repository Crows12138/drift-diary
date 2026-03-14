import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/floating_card.dart';
import '../widgets/mood_badge.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，记录一下今天';
    if (hour < 12) return '早安，新的一天开始了';
    if (hour < 18) return '午后时光，随手记录';
    return '晚安，今天过得怎么样？';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diariesAsync = ref.watch(diaryListProvider);
    final now = DateTime.now();
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final dateStr = '${now.month}月${now.day}日 星期${weekdays[now.weekday - 1]}';

    return OceanBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(diaryListProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Write diary button
              SliverToBoxAdapter(
                child: FloatingCard(
                  margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  onTap: () => context.push('/write'),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.moodColor('calm').withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_note, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '写一篇日记',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '记录此刻的心情，AI 会温柔地倾听',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),

              // Inspiration quote
              SliverToBoxAdapter(
                child: GlassCard(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  opacity: 0.08,
                  child: Row(
                    children: [
                      Text('💡',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white.withOpacity(0.8))),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '「把心情装进漂流瓶，让温暖传递给陌生人」',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        '最近日记',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/mine'),
                        child: const Text('查看全部'),
                      ),
                    ],
                  ),
                ),
              ),

              // Diary list
              diariesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text('加载失败: $e',
                          style: const TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
                data: (diaries) {
                  if (diaries.isEmpty) {
                    return SliverToBoxAdapter(
                      child: GlassCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        opacity: 0.06,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.book_outlined,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.2)),
                                const SizedBox(height: 12),
                                Text(
                                  '还没有日记，写一篇吧',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final diary = diaries[index];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            onTap: () =>
                                context.push('/ai-result/${diary.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    MoodBadge(mood: diary.moodTag),
                                    const Spacer(),
                                    Text(
                                      DateFormat('MM/dd HH:mm')
                                          .format(diary.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    if (diary.type == 'drift') ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.sailing,
                                          size: 14,
                                          color:
                                              Colors.white.withOpacity(0.4)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  diary.content.length > 80
                                      ? '${diary.content.substring(0, 80)}...'
                                      : diary.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                                if (diary.topicTags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: diary.topicTags
                                        .map((t) => Text(
                                              '#$t',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        childCount: diaries.length,
                      ),
                    ),
                  );
                },
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
