import 'package:flutter/material.dart';
import 'package:home_services_app/firebase_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String participantName;
  final String participantId;
  final String participantImageUrl;
  final bool isParticipantWorker;

  const ChatScreen({
    super.key,
    required this.participantName,
    required this.participantId,
    required this.participantImageUrl,
    required this.isParticipantWorker,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late RealtimeChannel _channel;
  final ScrollController _scrollController = ScrollController();

  String? _currentUserId;
  String? _currentUserImageUrl;
  String? _currentUserName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserInfo();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentUserId == null) return;

    final newMessage = {
      'sender_id': _currentUserId,
      'recipient_id': widget.participantId,
      'content': message,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('messages').insert(newMessage);
    _messageController.clear();

    // 🔔 Send push notification
    await _sendPushNotification(message);
  }

  Future<void> _sendPushNotification(String messageContent) async {
    try {
      final deviceTokenResponse =
          await _supabase
              .from('device_tokens')
              .select('token')
              .eq('user_id', widget.participantId)
              .maybeSingle();

      if (deviceTokenResponse == null || deviceTokenResponse['token'] == null) {
        print("No FCM token found for recipient.");
        return;
      }

      final deviceToken = deviceTokenResponse['token'];

      await MyFireBaseCloudMessaging.sendNotificationToUser(
        deviceToken,
        widget.participantId,
        context,
        "$_currentUserName sent you a message",
        messageContent,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      print("❌ Error sending push notification: $e");
    }
  }

  Future<void> _fetchCurrentUserInfo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final email = user.email;

    final userResponse =
        await _supabase
            .from('users')
            .select('id, full_name, image_url')
            .eq('email', email!)
            .maybeSingle();

    if (userResponse == null) {
      final workerResponse =
          await _supabase
              .from('workers')
              .select('id, name, image_url')
              .eq('email', email)
              .maybeSingle();

      if (workerResponse != null) {
        setState(() {
          _currentUserId = workerResponse['id'].toString();
          _currentUserName = workerResponse['name'];
          _currentUserImageUrl = workerResponse['image_url'];
        });
      }
    } else {
      setState(() {
        _currentUserId = userResponse['id'].toString();
        _currentUserName = userResponse['full_name'];
        _currentUserImageUrl = userResponse['image_url'];
      });
    }

    _subscribeToMessages();
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or(
            'and(sender_id.eq.$_currentUserId,recipient_id.eq.${widget.participantId}),and(sender_id.eq.${widget.participantId},recipient_id.eq.$_currentUserId)',
          )
          .order('created_at', ascending: true);

      setState(() {
        _messages.clear();
        _messages.addAll(List<Map<String, dynamic>>.from(response));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error fetching messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _subscribeToMessages() {
    _channel =
        _supabase
            .channel('messages_channel')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              callback: (payload) {
                final newMessage = payload.newRecord;
                if (newMessage == null) return;

                if ((newMessage['sender_id'].toString() ==
                            widget.participantId &&
                        newMessage['recipient_id'].toString() ==
                            _currentUserId) ||
                    (newMessage['sender_id'].toString() == _currentUserId &&
                        newMessage['recipient_id'].toString() ==
                            widget.participantId)) {
                  if (!_messages.any((m) => m['id'] == newMessage['id'])) {
                    setState(() {
                      _messages.add(newMessage);
                    });
                    _scrollToBottom();
                  }
                }
              },
            )
            .subscribe();
  }

  // Future<void> _sendMessage() async {
  //   final message = _messageController.text.trim();
  //   if (message.isEmpty || _currentUserId == null) return;

  //   final newMessage = {
  //     'sender_id': _currentUserId,
  //     'recipient_id': widget.participantId,
  //     'content': message,
  //     'created_at': DateTime.now().toIso8601String(),
  //   };

  //   await _supabase.from('messages').insert(newMessage);
  //   _messageController.clear();
  // }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    try {
      _channel.unsubscribe();
    } catch (_) {}
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColorMe = const Color(0xFFE4F9CC);
    final bubbleColorOther = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF47B0F0),
        title: Text(widget.participantName),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.call, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? const Center(child: Text("No messages yet."))
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMe =
                            msg['sender_id'].toString() == _currentUserId;
                        final avatarUrl =
                            isMe
                                ? _currentUserImageUrl
                                : widget.participantImageUrl;
                        final timestamp = DateTime.parse(msg['created_at']);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) _chatAvatar(avatarUrl),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe ? bubbleColorMe : bubbleColorOther,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: Radius.circular(
                                        isMe ? 18 : 0,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMe ? 0 : 18,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg['content'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (isMe) _chatAvatar(avatarUrl),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _chatAvatar(String? url) {
    return CircleAvatar(
      radius: 18,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child:
          url == null || url.isEmpty
              ? const Icon(Icons.person, size: 18)
              : null,
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your text here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF47B0F0)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
