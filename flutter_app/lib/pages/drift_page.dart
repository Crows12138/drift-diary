import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_badge.dart';
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
  DriftBottle? _pickedBottle;
  bool _isPicking = false;
  final _responseController = TextEditingController();
  bool _isResponding = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _pickBottle() async {
    setState(() => _isPicking = true);
    try {
      final json = await ApiService().pickBottle();
      setState(() {
        _pickedBottle = DriftBottle.fromJson(json);
        _isPicking = false;
      });
    } catch (e) {
      setState(() => _isPicking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('404') ? '暂时没有漂流瓶可捡' : '捡瓶失败: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _respond() async {
    final content = _responseController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isResponding = true);
    try {
      await ApiService().respondBottle(_pickedBottle!.id, content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('回应成功，漂流瓶已继续漂流 🌊')),
        );
        setState(() {
          _pickedBottle = null;
          _responseController.clear();
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
    setState(() => _isResponding = false);
  }

  @override
  Widget build(BuildContext context) {
    final myBottles = ref.watch(myBottlesProvider);

    return AmbientBackground(
      orbs: const [
        AmbientOrb(color: Color(0xFF4D96FF), x: 0.3, y: 0.15, radius: 0.4),
        AmbientOrb(color: Color(0xFF7C83FD), x: 0.75, y: 0.35, radius: 0.35),
        AmbientOrb(color: Color(0xFFE2B0FF), x: 0.4, y: 0.7, radius: 0.3),
      ],
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(myBottlesProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '漂流瓶',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '捡一个漂流瓶，给陌生人一份温暖',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pick bottle button or picked bottle
              SliverToBoxAdapter(
                child: _pickedBottle == null
                    ? _buildPickButton()
                    : _buildPickedBottle(),
              ),

              // My bottles section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    '我的漂流瓶',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),

              myBottles.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
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
                data: (bottles) {
                  if (bottles.isEmpty) {
                    return SliverToBoxAdapter(
                      child: GlassCard(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        opacity: 0.06,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              '还没有投出漂流瓶',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
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
                        (context, index) => _buildMyBottle(bottles[index]),
                        childCount: bottles.length,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickButton() {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Icon(
            Icons.sailing,
            size: 56,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isPicking ? null : _pickBottle,
              child: _isPicking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('捡一个漂流瓶'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPickedBottle() {
    final bottle = _pickedBottle!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Bottle content
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MoodBadge(mood: bottle.moodTag),
                    const Spacer(),
                    Text(
                      '第 ${bottle.currentStation} 站',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  bottle.diaryContent,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
                if (bottle.responses.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 8),
                  Text(
                    '旅途回应',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...bottle.responses.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF7C83FD)
                                    .withOpacity(0.2),
                              ),
                              child: Center(
                                child: Text(
                                  '${r.stationNumber}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF7C83FD)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                r.content,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Response input
          GlassCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                TextField(
                  controller: _responseController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '写下你想对 ta 说的话...',
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.3)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _pickedBottle = null),
                        child: Text(
                          '放回去',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.4)),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _isResponding ? null : _respond,
                        child: _isResponding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('回应'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBottle(MyDriftBottle bottle) {
    final color = AppTheme.moodColor(bottle.moodTag);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => context.push('/drift-detail/${bottle.id}'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sailing, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bottle.diaryContentPreview.isEmpty
                      ? '...'
                      : bottle.diaryContentPreview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '第 ${bottle.currentStation} 站 · ${bottle.status == 'drifting' ? '漂流中' : '已被捡起'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          if (bottle.hasNewResponse)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right,
              size: 18, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}
