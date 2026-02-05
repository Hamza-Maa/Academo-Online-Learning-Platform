class User {
  final String id;
  final String email;
  final String? phone;
  final String name;
  final String? photoUrl;
  final String language;
  final bool termsAccepted;
  final bool privacyAccepted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> favoriteCourses;
  final List<String> purchasedCourses;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.name,
    this.photoUrl,
    this.language = 'en',
    this.termsAccepted = false,
    this.privacyAccepted = false,
    required this.createdAt,
    required this.updatedAt,
    this.favoriteCourses = const [],
    this.purchasedCourses = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'name': name,
        'photoUrl': photoUrl,
        'language': language,
        'termsAccepted': termsAccepted,
        'privacyAccepted': privacyAccepted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'favoriteCourses': favoriteCourses,
        'purchasedCourses': purchasedCourses,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String?,
        language: json['language'] as String? ?? 'en',
        termsAccepted: json['termsAccepted'] as bool? ?? false,
        privacyAccepted: json['privacyAccepted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        favoriteCourses: (json['favoriteCourses'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        purchasedCourses: (json['purchasedCourses'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? photoUrl,
    String? language,
    bool? termsAccepted,
    bool? privacyAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? favoriteCourses,
    List<String>? purchasedCourses,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        language: language ?? this.language,
        termsAccepted: termsAccepted ?? this.termsAccepted,
        privacyAccepted: privacyAccepted ?? this.privacyAccepted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        favoriteCourses: favoriteCourses ?? this.favoriteCourses,
        purchasedCourses: purchasedCourses ?? this.purchasedCourses,
      );
}
