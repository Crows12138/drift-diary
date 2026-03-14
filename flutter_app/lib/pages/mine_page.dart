import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_badge.dart';
import '../providers/auth_provider.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diariesAsync = ref.watch(diaryListProvider);

    return OceanBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Text(
                      '我的',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.logout,
                          color: Colors.white.withOpacity(0.5)),
                      onPressed: () => _showLogout(context, ref),
                    ),
                  ],
                ),
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: diariesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (diaries) {
                  final total = diaries.length;
                  final driftCount =
                      diaries.where((d) => d.type == 'drift').length;
                  final moods = <String, int>{};
                  for (final d in diaries) {
                    moods[d.moodTag] = (moods[d.moodTag] ?? 0) + 1;
                  }
                  String? topMood;
                  if (moods.isNotEmpty) {
                    topMood = moods.entries
                        .reduce((a, b) => a.value > b.value ? a : b)
                        .key;
                  }

                  return GlassCard(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('日记', '$total'),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _statItem('漂流', '$driftCount'),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _statItem(
                          '常见心情',
                          topMood != null
                              ? AppTheme.moodLabel(topMood)
                              : '-',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // All diaries title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  '全部日记',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('加载失败',
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ),
              ),
              data: (diaries) {
                if (diaries.isEmpty) {
                  return SliverToBoxAdapter(
                    child: GlassCard(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      opacity: 0.06,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            '还没有日记',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final diary = diaries[index];
                        return Dismissible(
                          key: ValueKey(diary.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.red),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A2E),
                                title: const Text('删除日记'),
                                content: const Text('确定删除这篇日记吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('删除',
                                        style:
                                            TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) {
                            ref
                                .read(diaryListProvider.notifier)
                                .deleteDiary(diary.id);
                          },
                          child: GlassCard(
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
                                      const SizedBox(width: 6),
                                      Icon(Icons.sailing,
                                          size: 14,
                                          color: Colors.white
                                              .withOpacity(0.4)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  diary.content.length > 100
                                      ? '${diary.content.substring(0, 100)}...'
                                      : diary.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: diaries.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
        ),
      ],
    );
  }

  void _showLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('退出登录'),
        content: const Text('确定退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              ref.read(authProvider.notifier).login(); // re-login dev
            },
            child: const Text('退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
