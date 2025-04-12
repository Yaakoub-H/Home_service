import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class WorkerChatUsersPage extends StatefulWidget {
  const WorkerChatUsersPage({super.key});

  @override
  State<WorkerChatUsersPage> createState() => _WorkerChatUsersPageState();
}

class _WorkerChatUsersPageState extends State<WorkerChatUsersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatUsers();
  }

  Future<void> _loadChatUsers() async {
    final currentWorkerId = _supabase.auth.currentUser?.id;
    if (currentWorkerId == null) return;

    final fromBookings = await _supabase
        .from('bookings')
        .select('user_id, users(id, full_name, image_url)')
        .eq('worker_id', currentWorkerId);

    final fromMessages = await _supabase
        .from('messages')
        .select('sender_id, recipient_id')
        .or('sender_id.eq.$currentWorkerId,recipient_id.eq.$currentWorkerId');

    final Set<String> userIds = {}; // for uniqueness

    for (final booking in fromBookings) {
      final user = booking['users'];
      if (user != null && !userIds.contains(user['id'])) {
        userIds.add(user['id']);
        _users.add(user);
      }
    }

    for (final msg in fromMessages) {
      final otherId =
          msg['sender_id'] == currentWorkerId
              ? msg['recipient_id']
              : msg['sender_id'];

      if (!userIds.contains(otherId)) {
        final user =
            await _supabase
                .from('users')
                .select('id, full_name, image_url')
                .eq('id', otherId)
                .maybeSingle();

        if (user != null) {
          userIds.add(user['id']);
          _users.add(user);
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF47B0F0),
        title: const Text('Chats'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? const Center(child: Text('No users to chat with.'))
              : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          user['image_url'] != null
                              ? NetworkImage(user['image_url'])
                              : null,
                      child:
                          user['image_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    title: Text(user['full_name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                participantName: user['full_name'],
                                participantId: user['id'],
                                participantImageUrl: user['image_url'] ?? '',
                                isParticipantWorker: false,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
