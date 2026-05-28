import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/chat_model.dart';

class ChatApiService {
  final ApiClient _apiClient;

  ChatApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  Future<List<ChatRoom>> getChatRooms() async {
    final response = await _apiClient.get(ApiConstants.chatRooms);
    if (response.isSuccess) {
      final data = response.data;
      // API returns paginated envelope { items: [...] }
      final list = data is List
          ? data
          : (data['items'] ?? data['rooms'] ?? data['data'] ?? []);
      return (list as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatRoom.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<ChatRoom?> createChatRoom({
    required int shopId,
    String roomType = 'general',
    int? appointmentId,
    int? productOrderId,
  }) async {
    final body = <String, dynamic>{
      'shop_id': shopId,
      'room_type': roomType,
    };
    if (appointmentId != null) body['appointment_id'] = appointmentId;
    if (productOrderId != null) body['product_order_id'] = productOrderId;

    final response = await _apiClient.post(ApiConstants.chatRooms, body: body);
    if (response.isSuccess) {
      final data = response.data;
      if (data is Map<String, dynamic>) return ChatRoom.fromJson(data);
    }
    return null;
  }

  /// Fetches the room detail and its messages in parallel.
  /// Messages come from GET /chat/rooms/{id}/messages (separate endpoint).
  Future<ChatRoom?> getChatRoom(int roomId, {int limit = 50}) async {
    final responses = await Future.wait([
      _apiClient.get(ApiConstants.chatRoom(roomId)),
      _apiClient.get(
        ApiConstants.chatMessages(roomId),
        queryParams: {'limit': limit},
      ),
    ]);

    final roomRes = responses[0];
    final msgsRes = responses[1];

    // Need at least one to succeed
    if (!roomRes.isSuccess && !msgsRes.isSuccess) return null;

    // Parse room metadata
    ChatRoom? room;
    if (roomRes.isSuccess) {
      final data = roomRes.data;
      if (data is Map<String, dynamic>) room = ChatRoom.fromJson(data);
    }

    // Parse messages from the messages endpoint
    List<ChatMessage> messages = [];
    if (msgsRes.isSuccess) {
      final data = msgsRes.data;
      final rawList = data is List
          ? data
          : data is Map
              ? (data['items'] ?? data['messages'] ?? data['data'] ?? [])
              : [];
      messages = (rawList as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatMessage.fromJson(e))
          .toList();
    }

    // If messages endpoint returned nothing, fall back to whatever the room
    // detail included (some backends embed messages in the detail response).
    if (messages.isEmpty && room != null && room.messages.isNotEmpty) {
      return room;
    }

    if (room == null) {
      // Build a minimal room from messages only
      if (messages.isEmpty) return null;
      return ChatRoom(
        id: roomId,
        roomType: 'general',
        status: 'open',
        createdAt: '',
        messages: messages,
        lastMessage: messages.last,
      );
    }

    return ChatRoom(
      id: room.id,
      roomType: room.roomType,
      shopId: room.shopId,
      shopName: room.shopName,
      appointmentId: room.appointmentId,
      productOrderId: room.productOrderId,
      status: room.status,
      createdAt: room.createdAt,
      messages: messages,
      lastMessage: messages.isNotEmpty ? messages.last : room.lastMessage,
    );
  }

  Future<bool> sendMessage(
    int roomId, {
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'message_type': messageType,
    };
    if (attachmentUrl != null) body['attachment_url'] = attachmentUrl;

    final response = await _apiClient.post(
      ApiConstants.chatMessages(roomId),
      body: body,
    );
    return response.isSuccess;
  }

  Future<bool> markMessageRead(int roomId, int messageId) async {
    final response =
        await _apiClient.put(ApiConstants.markMessageRead(roomId, messageId));
    return response.isSuccess;
  }

  Future<int> getUnreadCount(int roomId) async {
    final response = await _apiClient.get(ApiConstants.chatUnreadCount(roomId));
    if (response.isSuccess) {
      final data = response.data;
      if (data is int) return data;
      if (data is Map) {
        return (data['unread_count'] ?? data['count'] ?? 0) as int;
      }
    }
    return 0;
  }

  Future<bool> closeChatRoom(int roomId) async {
    final response = await _apiClient.put(ApiConstants.closeChatRoom(roomId));
    return response.isSuccess;
  }
}
