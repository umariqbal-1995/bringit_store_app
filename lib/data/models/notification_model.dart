class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String? type;
  final String? orderId;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.type,
    this.orderId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? json['message'] ?? '',
        // API uses 'read' not 'isRead'
        isRead: json['read'] ?? json['isRead'] ?? false,
        type: json['type'],
        orderId: json['orderId'] ?? json['data']?['orderId'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}
