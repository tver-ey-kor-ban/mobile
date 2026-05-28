class ChatMessage {
  final int id;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final int? senderId;
  final String? senderName;
  final String createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.senderId,
    this.senderName,
    required this.createdAt,
    required this.isRead,
  });

  bool isMine(int? currentUserId) =>
      senderId != null && senderId == currentUserId;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderId = json['sender_id'] ??
        json['user_id'] ??
        json['created_by'] ??
        (sender is Map ? sender['id'] : null);
    final senderName = json['sender_name'] ??
        json['username'] ??
        (sender is Map
            ? (sender['full_name'] ?? sender['name'] ?? sender['username'])
            : null);
    return ChatMessage(
      id: json['id'] ?? 0,
      content: json['content'] ?? json['text'] ?? '',
      messageType: json['message_type'] ?? json['type'] ?? 'text',
      attachmentUrl: json['attachment_url'],
      senderId: senderId is int
          ? senderId
          : (senderId != null ? int.tryParse(senderId.toString()) : null),
      senderName: senderName?.toString(),
      createdAt: json['created_at'] ?? json['timestamp'] ?? '',
      isRead: json['is_read'] ?? json['read'] ?? false,
    );
  }
}

class ChatRoom {
  final int id;
  final String roomType;
  final int? shopId;
  final String? shopName;
  final int? appointmentId;
  final int? productOrderId;
  final String status;
  final String createdAt;
  final List<ChatMessage> messages;
  final ChatMessage? lastMessage;

  ChatRoom({
    required this.id,
    required this.roomType,
    this.shopId,
    this.shopName,
    this.appointmentId,
    this.productOrderId,
    required this.status,
    required this.createdAt,
    this.messages = const [],
    this.lastMessage,
  });

  String get displayName {
    if (shopName != null && shopName!.isNotEmpty) return shopName!;
    if (shopId != null) return 'Shop #$shopId';
    return 'Chat Room #$id';
  }

  String get roomTypeLabel {
    switch (roomType) {
      case 'appointment':
        return 'Appointment Chat';
      case 'order':
        return 'Order Chat';
      default:
        return 'General Chat';
    }
  }

  bool get isOpen => status == 'open';

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    // Handle response wrapped in a 'data' or 'room' key
    final root = (json['data'] is Map<String, dynamic>
        ? json['data']
        : json['room'] is Map<String, dynamic>
            ? json['room']
            : json) as Map<String, dynamic>;

    // Try multiple possible field names for messages
    final rawMessages = root['messages'] ??
        root['chat_messages'] ??
        root['items'] ??
        json['messages'] ??
        json['chat_messages'] ??
        [];

    final msgList = rawMessages is List
        ? rawMessages
            .whereType<Map<String, dynamic>>()
            .map((e) => ChatMessage.fromJson(e))
            .toList()
        : <ChatMessage>[];

    ChatMessage? last;
    final lastJson = root['last_message'] ?? json['last_message'];
    if (lastJson is Map<String, dynamic>) {
      last = ChatMessage.fromJson(lastJson);
    } else if (msgList.isNotEmpty) {
      last = msgList.last;
    }

    final shop = root['shop'] ?? json['shop'];
    final shopName = root['shop_name'] ??
        json['shop_name'] ??
        (shop is Map ? shop['name'] : null);

    return ChatRoom(
      id: root['id'] ?? json['id'] ?? 0,
      roomType: root['room_type'] ?? json['room_type'] ?? 'general',
      shopId: root['shop_id'] ??
          json['shop_id'] ??
          (shop is Map ? shop['id'] : null),
      shopName: shopName?.toString(),
      appointmentId: root['appointment_id'] ?? json['appointment_id'],
      productOrderId: root['product_order_id'] ?? json['product_order_id'],
      status: root['status'] ?? json['status'] ?? 'open',
      createdAt: root['created_at'] ?? json['created_at'] ?? '',
      messages: msgList,
      lastMessage: last,
    );
  }
}
