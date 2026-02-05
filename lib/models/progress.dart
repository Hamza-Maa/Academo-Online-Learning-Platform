class Progress {
  final String id;
  final String userId;
  final String courseId;
  final Map<String, LessonProgress> lessonProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Progress({
    required this.id,
    required this.userId,
    required this.courseId,
    this.lessonProgress = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'courseId': courseId,
        'lessonProgress': lessonProgress.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        id: json['id'] as String,
        userId: json['userId'] as String,
        courseId: json['courseId'] as String,
        lessonProgress: (json['lessonProgress'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                key,
                LessonProgress.fromJson(value as Map<String, dynamic>),
              ),
            ) ??
            {},
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Progress copyWith({
    String? id,
    String? userId,
    String? courseId,
    Map<String, LessonProgress>? lessonProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Progress(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        courseId: courseId ?? this.courseId,
        lessonProgress: lessonProgress ?? this.lessonProgress,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  double calculatePercentage(int totalLessons) {
    if (totalLessons == 0) return 0;
    final completedCount =
        lessonProgress.values.where((lp) => lp.isCompleted).length;
    return (completedCount / totalLessons) * 100;
  }
}

class LessonProgress {
  final String lessonId;
  final bool isCompleted;
  final int watchedSeconds;
  final DateTime lastWatchedAt;

  LessonProgress({
    required this.lessonId,
    this.isCompleted = false,
    this.watchedSeconds = 0,
    required this.lastWatchedAt,
  });

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'isCompleted': isCompleted,
        'watchedSeconds': watchedSeconds,
        'lastWatchedAt': lastWatchedAt.toIso8601String(),
      };

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
        lessonId: json['lessonId'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        watchedSeconds: json['watchedSeconds'] as int? ?? 0,
        lastWatchedAt: DateTime.parse(json['lastWatchedAt'] as String),
      );

  LessonProgress copyWith({
    String? lessonId,
    bool? isCompleted,
    int? watchedSeconds,
    DateTime? lastWatchedAt,
  }) =>
      LessonProgress(
        lessonId: lessonId ?? this.lessonId,
        isCompleted: isCompleted ?? this.isCompleted,
        watchedSeconds: watchedSeconds ?? this.watchedSeconds,
        lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      );
}
