import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/chat_api_service.dart';
import '../../data/models/chat_model.dart';
import 'chat_room_page.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final _service = ChatApiService();
  List<ChatRoom> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final rooms = await _service.getChatRooms();
    setState(() {
      _rooms = rooms;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _rooms.isEmpty ? _buildEmpty() : _buildList(),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          'No chats yet',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          'Start a conversation from a shop\'s profile',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _rooms.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (_, i) => _buildTile(_rooms[i]),
    );
  }

  Widget _buildTile(ChatRoom room) {
    final last = room.lastMessage;
    final subtitle = last != null
        ? last.content.isNotEmpty
            ? last.content
            : '(attachment)'
        : room.roomTypeLabel;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.red.shade50,
        child: Icon(
          _roomIcon(room.roomType),
          color: Colors.red.shade600,
          size: 26,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!room.isOpen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Closed',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          if (last != null && last.createdAt.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _formatTime(last.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(room: room),
          ),
        );
        _load();
      },
    );
  }

  IconData _roomIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today_outlined;
      case 'order':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.chat_outlined;
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
