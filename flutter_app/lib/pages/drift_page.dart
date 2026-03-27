import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ocean_background.dart';
import '../widgets/mood_badge.dart';
import '../widgets/floating_bottle.dart';
import '../providers/drift_provider.dart';
import '../models/drift_bottle.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DriftPage extends ConsumerStatefulWidget {
  const DriftPage({super.key});

  @override
  ConsumerState<DriftPage> createState() => _DriftPageState();
}

class _DriftPageState extends ConsumerState<DriftPage> {
  late List<BottleSlot> _slots;
  DriftBottle? _pickedBottle;
  bool _isPicking = false;
  int _pickingIndex = -1;
  final _responseController = TextEditingController();
  bool _isResponding = false;

  @override
  void initState() {
    super.initState();
    _slots = BottleSlot.generate(4);
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _pickBottle(int index) async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _pickingIndex = index;
      _slots[index].isBeingPicked = true;
    });

    try {
      final json = await ApiService().pickBottle();
      final bottle = DriftBottle.fromJson(json);
      if (mounted) {
        setState(() {
          _pickedBottle = bottle;
          _isPicking = false;
        });
        _showPickedSheet(bottle);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPicking = false;
          _slots[index].isBeingPicked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('404')
                  ? '海面很平静...暂时没有漂流瓶'
                  : '捡瓶失败',
            ),
          ),
        );
      }
    }
  }

  Future<void> _respond(String content) async {
    if (content.trim().isEmpty || _pickedBottle == null) return;
    setState(() => _isResponding = true);
    try {
      await ApiService().respondBottle(_pickedBottle!.id, content.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('回应成功，漂流瓶已继续漂流')),
        );
        setState(() {
          _pickedBottle = null;
          _responseController.clear();
          // Regenerate picked slot
          if (_pickingIndex >= 0 && _pickingIndex < _slots.length) {
            _slots[_pickingIndex] = BottleSlot.generate(1).first;
          }
          _pickingIndex = -1;
        });
        ref.invalidate(myBottlesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('回应失败: $e')),
        );
      }
    }
    if (mounted) setState(() => _isResponding = false);
  }

  void _showPickedSheet(DriftBottle bottle) {
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    final textColor = AppTheme.textColor(isDayMode);
    final subtextColor = AppTheme.subtextColor(isDayMode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDayMode
                            ? [
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.15),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.04),
                              ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white
                              .withValues(alpha: isDayMode ? 0.4 : 0.18),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Header
                          Row(
                            children: [
                              MoodBadge(mood: bottle.moodTag),
                              const Spacer(),
                              Text(
                                '第 ${bottle.currentStation} 站',
                                style: TextStyle(
                                    fontSize: 12, color: subtextColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Content
                          Text(
                            bottle.diaryContent,
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              height: 1.6,
                            ),
                          ),

                          // Previous responses
                          if (bottle.responses.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Divider(
                                color: textColor.withValues(alpha: 0.1)),
                            const SizedBox(height: 8),
                            Text('旅途回应',
                                style: TextStyle(
                                    fontSize: 13, color: subtextColor)),
                            const SizedBox(height: 8),
                            ...bottle.responses.map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.moodColor(
                                                  bottle.moodTag)
                                              .withValues(alpha: 0.2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${r.stationNumber}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.moodColor(
                                                  bottle.moodTag),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          r.content,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textColor
                                                .withValues(alpha: 0.7),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],

                          const SizedBox(height: 16),

                          // Response input
                          Container(
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _responseController,
                              maxLines: 3,
                              style:
                                  TextStyle(fontSize: 14, color: textColor),
                              decoration: InputDecoration(
                                hintText: '写下你想对 ta 说的话...',
                                border: InputBorder.none,
                                hintStyle:
                                    TextStyle(color: subtextColor),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Actions
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  setState(() {
                                    _pickedBottle = null;
                                    if (_pickingIndex >= 0 &&
                                        _pickingIndex < _slots.length) {
                                      _slots[_pickingIndex].isBeingPicked =
                                          false;
                                    }
                                    _pickingIndex = -1;
                                  });
                                },
                                child: Text('放回去',
                                    style:
                                        TextStyle(color: subtextColor)),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _isResponding
                                    ? null
                                    : () {
                                        final text =
                                            _responseController.text;
                                        _respond(text);
                                      },
                                child: _isResponding
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('回应'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // If sheet dismissed without responding, restore bottle
      if (_pickedBottle != null) {
        setState(() {
          _pickedBottle = null;
          if (_pickingIndex >= 0 && _pickingIndex < _slots.length) {
            _slots[_pickingIndex].isBeingPicked = false;
          }
          _pickingIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myBottles = ref.watch(myBottlesProvider);
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    final textColor = AppTheme.textColor(isDayMode);
    final subtextColor = AppTheme.subtextColor(isDayMode);

    return OceanBackground(
      child: Stack(
        children: [
          // Floating bottles
          ..._slots.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            return FloatingBottle(
              slot: slot,
              isDayMode: isDayMode,
              onTap: () => _pickBottle(i),
            );
          }),

          // Top-left title
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '漂流瓶',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '轻触海面上的瓶子',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtextColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Bottom drawer
          DraggableScrollableSheet(
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.55,
            snap: true,
            snapSizes: const [0.08, 0.35, 0.55],
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDayMode
                            ? [
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.15),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.04),
                              ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white
                              .withValues(alpha: isDayMode ? 0.4 : 0.18),
                        ),
                      ),
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // Handle + title
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 12, 20, 8),
                                child: Row(
                                  children: [
                                    Text(
                                      '我的漂流瓶',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // My bottles list
                        myBottles.when(
                          loading: () => const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          error: (_, __) => SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('加载失败',
                                  style: TextStyle(color: subtextColor)),
                            ),
                          ),
                          data: (bottles) {
                            if (bottles.isEmpty) {
                              return SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      '还没有投出漂流瓶',
                                      style:
                                          TextStyle(color: subtextColor),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final b = bottles[index];
                                  final moodColor =
                                      AppTheme.moodColor(b.moodTag);
                                  return ListTile(
                                    onTap: () => context
                                        .push('/drift-detail/${b.id}'),
                                    leading: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: moodColor,
                                      ),
                                    ),
                                    title: Text(
                                      b.diaryContentPreview.isEmpty
                                          ? '...'
                                          : b.diaryContentPreview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '第 ${b.currentStation} 站 · ${b.status == 'drifting' ? '漂流中' : '已停靠'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtextColor,
                                      ),
                                    ),
                                    trailing: b.hasNewResponse
                                        ? Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF6B6B),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : null,
                                  );
                                },
                                childCount: bottles.length,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
