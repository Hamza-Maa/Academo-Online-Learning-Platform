class Purchase {
  final String id;
  final String userId;
  final String courseId;
  final double amount;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Purchase({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.amount,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'courseId': courseId,
        'amount': amount,
        'status': status.name,
        'transactionId': transactionId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'] as String,
        userId: json['userId'] as String,
        courseId: json['courseId'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PaymentStatus.pending,
        ),
        transactionId: json['transactionId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Purchase copyWith({
    String? id,
    String? userId,
    String? courseId,
    double? amount,
    PaymentStatus? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Purchase(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        courseId: courseId ?? this.courseId,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        transactionId: transactionId ?? this.transactionId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

enum PaymentStatus {
  pending,
  success,
  failed,
}
