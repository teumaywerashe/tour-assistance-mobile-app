class FeedbackModel {
  final dynamic id;
  final String? email;
  final String? subject;
  final String comment;
  final String createdAt;
  final String status;

  const FeedbackModel({
    this.id,
    this.email,
    this.subject,
    required this.comment,
    required this.createdAt,
    required this.status,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      subject: json['subject'],
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'subject': subject,
        'comment': comment,
        'createdAt': createdAt,
        'status': status,
      };
}
