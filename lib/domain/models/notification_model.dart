class NotificationModel {
  final String? notificationId;
  final String? userId;
  final String? title;
  final String? message;
  final bool isRead;
  final String? type;
  final String? refId;
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationModel({
    this.notificationId,
    this.userId,
    this.title,
    this.message,
    this.isRead = false,
    this.type,
    this.refId,
    this.readAt,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      type: json['type'],
      refId: json['refId'],
      readAt: json['readAt'] == null
          ? null
          : DateTime.tryParse(json['readAt'].toString()),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    bool? isRead,
    String? type,
    String? refId,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      refId: refId ?? this.refId,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
