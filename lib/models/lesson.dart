class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String? description;
  final String videoUrl;
  final int durationSeconds;
  final int order;
  final List<Resource> resources;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    this.description,
    required this.videoUrl,
    required this.durationSeconds,
    required this.order,
    this.resources = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'description': description,
        'videoUrl': videoUrl,
        'durationSeconds': durationSeconds,
        'order': order,
        'resources': resources.map((r) => r.toJson()).toList(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        moduleId: json['moduleId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        videoUrl: json['videoUrl'] as String,
        durationSeconds: json['durationSeconds'] as int,
        order: json['order'] as int,
        resources: (json['resources'] as List<dynamic>?)
                ?.map((e) => Resource.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? title,
    String? description,
    String? videoUrl,
    int? durationSeconds,
    int? order,
    List<Resource>? resources,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Lesson(
        id: id ?? this.id,
        moduleId: moduleId ?? this.moduleId,
        title: title ?? this.title,
        description: description ?? this.description,
        videoUrl: videoUrl ?? this.videoUrl,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        order: order ?? this.order,
        resources: resources ?? this.resources,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class Resource {
  final String id;
  final String title;
  final String url;
  final ResourceType type;

  Resource({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'type': type.name,
      };

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String,
        type: ResourceType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ResourceType.link,
        ),
      );
}

enum ResourceType {
  pdf,
  link,
  document,
}
