class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final String status;
  final int? appointmentId;
  final int? orderId;
  final String createdAt;
  final String? readAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    this.appointmentId,
    this.orderId,
    required this.createdAt,
    this.readAt,
  });

  bool get isUnread => status == 'unread';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'unread',
      appointmentId: json['appointment_id'],
      orderId: json['order_id'],
      createdAt: json['created_at'] ?? '',
      readAt: json['read_at'],
    );
  }
}
