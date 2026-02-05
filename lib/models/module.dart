class Module {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'description': description,
        'order': order,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'] as String,
        courseId: json['courseId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        order: json['order'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Module copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Module(
        id: id ?? this.id,
        courseId: courseId ?? this.courseId,
        title: title ?? this.title,
        description: description ?? this.description,
        order: order ?? this.order,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
