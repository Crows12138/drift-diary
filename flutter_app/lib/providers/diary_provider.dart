import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final diaryListProvider =
    AsyncNotifierProvider<DiaryListNotifier, List<Diary>>(DiaryListNotifier.new);

class DiaryListNotifier extends AsyncNotifier<List<Diary>> {
  final _api = ApiService();
  int _total = 0;
  int get total => _total;

  @override
  Future<List<Diary>> build() async {
    // Wait for auth to complete before fetching
    final auth = ref.watch(authProvider);
    if (auth != AuthStatus.authenticated) {
      return [];
    }
    return _fetchPage(1);
  }

  Future<List<Diary>> _fetchPage(int page) async {
    final json = await _api.getDiaries(page: page);
    final resp = DiaryListResponse.fromJson(json);
    _total = resp.total;
    return resp.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }

  Future<Diary> createDiary({
    required String content,
    required String moodTag,
    List<String>? topicTags,
    String type = 'private',
  }) async {
    final json = await _api.createDiary(
      content: content,
      moodTag: moodTag,
      topicTags: topicTags,
      type: type,
    );
    final diary = Diary.fromJson(json);
    state = AsyncData([diary, ...state.valueOrNull ?? []]);
    return diary;
  }

  Future<void> deleteDiary(int id) async {
    await _api.deleteDiary(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((d) => d.id != id).toList(),
    );
  }
}

final aiAnalyzeProvider =
    FutureProvider.family<AiAnalysis, String>((ref, content) async {
  final api = ApiService();
  final json = await api.analyzeEmotion(content);
  return AiAnalysis.fromJson(json);
});
