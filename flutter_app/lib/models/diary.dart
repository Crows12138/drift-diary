class Diary {
  final int id;
  final String content;
  final String moodTag;
  final List<String> topicTags;
  final String type; // "private" or "drift"
  final AiAnalysis? aiAnalysis;
  final DateTime createdAt;

  Diary({
    required this.id,
    required this.content,
    required this.moodTag,
    required this.topicTags,
    required this.type,
    this.aiAnalysis,
    required this.createdAt,
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] as int,
      content: json['content'] as String,
      moodTag: json['mood_tag'] as String? ?? 'calm',
      topicTags: (json['topic_tags'] as List<dynamic>?)?.cast<String>() ?? [],
      type: json['type'] as String? ?? 'private',
      aiAnalysis: json['ai_analysis'] != null
          ? AiAnalysis.fromJson(json['ai_analysis'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AiAnalysis {
  final String mood;
  final int intensity;
  final String summary;
  final List<String> keywords;

  AiAnalysis({
    required this.mood,
    required this.intensity,
    required this.summary,
    required this.keywords,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      mood: json['mood'] as String? ?? 'calm',
      intensity: json['intensity'] as int? ?? 5,
      summary: json['summary'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class DiaryListResponse {
  final List<Diary> items;
  final int total;

  DiaryListResponse({required this.items, required this.total});

  factory DiaryListResponse.fromJson(Map<String, dynamic> json) {
    return DiaryListResponse(
      items: (json['items'] as List).map((e) => Diary.fromJson(e)).toList(),
      total: json['total'] as int,
    );
  }
}
