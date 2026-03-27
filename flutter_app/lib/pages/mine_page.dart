import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_badge.dart';
import '../providers/auth_provider.dart';
import '../providers/diary_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diariesAsync = ref.watch(diaryListProvider);
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    final textColor = AppTheme.textColor(isDayMode);
    final subtextColor = AppTheme.subtextColor(isDayMode);
    final themeMode = ref.watch(themeModeProvider);

    return OceanBackground(
      child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        '我的',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      // Theme toggle
                      IconButton(
                        icon: Icon(
                          _themeIcon(themeMode),
                          color: subtextColor,
                        ),
                        tooltip: _themeTooltip(themeMode),
                        onPressed: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: subtextColor),
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
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('日记', '$total', textColor, subtextColor),
                          Container(
                            width: 1,
                            height: 32,
                            color: textColor.withOpacity(0.08),
                          ),
                          _statItem('漂流', '$driftCount', textColor, subtextColor),
                          Container(
                            width: 1,
                            height: 32,
                            color: textColor.withOpacity(0.08),
                          ),
                          _statItem(
                            '常见心情',
                            topMood != null
                                ? AppTheme.moodLabel(topMood)
                                : '-',
                            textColor,
                            subtextColor,
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
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                  child: Text(
                    '全部日记',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.8),
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
                    padding: const EdgeInsets.all(16),
                    child: Text('加载失败',
                        style: TextStyle(color: subtextColor)),
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
                            padding: const EdgeInsets.all(30),
                            child: Text('还没有日记',
                                style: TextStyle(color: subtextColor)),
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
                              final surfaceColor =
                                  Theme.of(context).colorScheme.surface;
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: surfaceColor,
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
                                          fontSize: 12, color: subtextColor,
                                        ),
                                      ),
                                      if (diary.type == 'drift') ...[
                                        const SizedBox(width: 6),
                                        Icon(Icons.sailing,
                                            size: 14, color: subtextColor),
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
                                      color: textColor.withOpacity(0.8),
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

  IconData _themeIcon(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => Icons.brightness_auto,
      AppThemeMode.day => Icons.light_mode,
      AppThemeMode.night => Icons.dark_mode,
    };
  }

  String _themeTooltip(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => '跟随系统',
      AppThemeMode.day => '日间模式',
      AppThemeMode.night => '夜间模式',
    };
  }

  Widget _statItem(
      String label, String value, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: subtextColor),
        ),
      ],
    );
  }

  void _showLogout(BuildContext context, WidgetRef ref) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
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
              ref.read(authProvider.notifier).login();
            },
            child: const Text('退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
