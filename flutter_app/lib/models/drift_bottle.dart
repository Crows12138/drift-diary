class DriftBottle {
  final int id;
  final String diaryContent;
  final String moodTag;
  final int currentStation;
  final String status;
  final List<DriftResponse> responses;
  final DateTime createdAt;

  DriftBottle({
    required this.id,
    required this.diaryContent,
    required this.moodTag,
    required this.currentStation,
    required this.status,
    required this.responses,
    required this.createdAt,
  });

  factory DriftBottle.fromJson(Map<String, dynamic> json) {
    return DriftBottle(
      id: json['id'] as int,
      diaryContent: json['diary_content'] as String? ??
          json['diary_content_preview'] as String? ??
          '',
      moodTag: json['mood_tag'] as String? ?? 'calm',
      currentStation: json['current_station'] as int? ?? 0,
      status: json['status'] as String? ?? 'drifting',
      responses: (json['responses'] as List<dynamic>?)
              ?.map((e) => DriftResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class DriftResponse {
  final String content;
  final int stationNumber;
  final DateTime createdAt;

  DriftResponse({
    required this.content,
    required this.stationNumber,
    required this.createdAt,
  });

  factory DriftResponse.fromJson(Map<String, dynamic> json) {
    return DriftResponse(
      content: json['content'] as String,
      stationNumber: json['station_number'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class MyDriftBottle {
  final int id;
  final String diaryContentPreview;
  final String moodTag;
  final int currentStation;
  final String status;
  final bool hasNewResponse;
  final DateTime createdAt;

  MyDriftBottle({
    required this.id,
    required this.diaryContentPreview,
    required this.moodTag,
    required this.currentStation,
    required this.status,
    required this.hasNewResponse,
    required this.createdAt,
  });

  factory MyDriftBottle.fromJson(Map<String, dynamic> json) {
    return MyDriftBottle(
      id: json['id'] as int,
      diaryContentPreview: json['diary_content_preview'] as String? ?? '',
      moodTag: json['mood_tag'] as String? ?? 'calm',
      currentStation: json['current_station'] as int? ?? 0,
      status: json['status'] as String? ?? 'drifting',
      hasNewResponse: json['has_new_response'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
