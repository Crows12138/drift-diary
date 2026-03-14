import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../providers/diary_provider.dart';
import '../services/api_service.dart';
import '../models/diary.dart';

class WritePage extends ConsumerStatefulWidget {
  const WritePage({super.key});

  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  final _controller = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isDrift = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先写点什么')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. AI analyze to get mood
      final api = ApiService();
      final analysis = await api.analyzeEmotion(content);
      final aiResult = AiAnalysis.fromJson(analysis);

      // 2. Create diary with AI-determined mood
      final diary = await ref.read(diaryListProvider.notifier).createDiary(
            content: content,
            moodTag: aiResult.mood,
            topicTags: _tags.isEmpty ? aiResult.keywords : _tags,
            type: _isDrift ? 'drift' : 'private',
          );

      if (mounted) {
        context.pushReplacement('/ai-result/${diary.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OceanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('写日记'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text input
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: _controller,
                  maxLines: 10,
                  minLines: 6,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: '今天想说些什么...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tags input
              GlassCard(
                opacity: 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '添加标签（可选）',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: '输入标签',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          color: Colors.white54,
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _tags
                            .map((t) => Chip(
                                  label: Text('#$t',
                                      style: const TextStyle(fontSize: 12)),
                                  deleteIcon:
                                      const Icon(Icons.close, size: 14),
                                  onDeleted: () =>
                                      setState(() => _tags.remove(t)),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Drift toggle
              GlassCard(
                opacity: 0.08,
                onTap: () => setState(() => _isDrift = !_isDrift),
                child: Row(
                  children: [
                    Icon(
                      Icons.sailing,
                      color: _isDrift
                          ? const Color(0xFF7C83FD)
                          : Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('投入漂流瓶',
                              style: TextStyle(fontSize: 15)),
                          Text(
                            '让这篇日记在陌生人之间传递温暖',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDrift,
                      onChanged: (v) => setState(() => _isDrift = v),
                      activeColor: const Color(0xFF7C83FD),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isDrift ? '提交并投出漂流瓶' : '提交日记'),
                ),
              ),

              const SizedBox(height: 12),

              // Hint
              Text(
                'AI 会自动分析你的情绪，无需手动选择心情',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
