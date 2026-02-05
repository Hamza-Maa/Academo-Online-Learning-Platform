class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String? previewVideoUrl;
  final String instructor;
  final String instructorAvatar;
  final CourseLevel level;
  final List<String> categories;
  final int totalDurationMinutes;
  final double price;
  final bool isFree;
  final double? promotionalPrice;
  final List<String> learningObjectives;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.previewVideoUrl,
    required this.instructor,
    required this.instructorAvatar,
    required this.level,
    required this.categories,
    required this.totalDurationMinutes,
    required this.price,
    this.isFree = false,
    this.promotionalPrice,
    this.learningObjectives = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'previewVideoUrl': previewVideoUrl,
        'instructor': instructor,
        'instructorAvatar': instructorAvatar,
        'level': level.name,
        'categories': categories,
        'totalDurationMinutes': totalDurationMinutes,
        'price': price,
        'isFree': isFree,
        'promotionalPrice': promotionalPrice,
        'learningObjectives': learningObjectives,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        previewVideoUrl: json['previewVideoUrl'] as String?,
        instructor: json['instructor'] as String,
        instructorAvatar: json['instructorAvatar'] as String,
        level: CourseLevel.values.firstWhere(
          (e) => e.name == json['level'],
          orElse: () => CourseLevel.beginner,
        ),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        totalDurationMinutes: json['totalDurationMinutes'] as int,
        price: (json['price'] as num).toDouble(),
        isFree: json['isFree'] as bool? ?? false,
        promotionalPrice: (json['promotionalPrice'] as num?)?.toDouble(),
        learningObjectives: (json['learningObjectives'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? previewVideoUrl,
    String? instructor,
    String? instructorAvatar,
    CourseLevel? level,
    List<String>? categories,
    int? totalDurationMinutes,
    double? price,
    bool? isFree,
    double? promotionalPrice,
    List<String>? learningObjectives,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Course(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
        instructor: instructor ?? this.instructor,
        instructorAvatar: instructorAvatar ?? this.instructorAvatar,
        level: level ?? this.level,
        categories: categories ?? this.categories,
        totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
        price: price ?? this.price,
        isFree: isFree ?? this.isFree,
        promotionalPrice: promotionalPrice ?? this.promotionalPrice,
        learningObjectives: learningObjectives ?? this.learningObjectives,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  String get formattedPrice => isFree
      ? 'Free'
      : promotionalPrice != null
          ? '\$${promotionalPrice!.toStringAsFixed(2)}'
          : '\$${price.toStringAsFixed(2)}';

  String get formattedDuration {
    final hours = totalDurationMinutes ~/ 60;
    final minutes = totalDurationMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}

enum CourseLevel {
  beginner,
  intermediate,
  advanced,
}
