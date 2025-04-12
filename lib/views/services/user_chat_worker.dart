import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class UserChatWorkersPage extends StatefulWidget {
  const UserChatWorkersPage({super.key});

  @override
  State<UserChatWorkersPage> createState() => _UserChatWorkersPageState();
}

class _UserChatWorkersPageState extends State<UserChatWorkersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatWorkers();
  }

  Future<void> _loadChatWorkers() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    // Fetch workers from bookings
    final fromBookings = await _supabase
        .from('bookings')
        .select('worker_id, workers(id, name, image_url)')
        .eq('user_id', currentUserId);

    // Fetch worker ids from messages
    final fromMessages = await _supabase
        .from('messages')
        .select('sender_id, recipient_id')
        .or('sender_id.eq.$currentUserId,recipient_id.eq.$currentUserId');

    final Set<String> workerIds = {};

    for (final booking in fromBookings) {
      final worker = booking['workers'];
      if (worker != null && !workerIds.contains(worker['id'])) {
        workerIds.add(worker['id']);
        _workers.add(worker);
      }
    }

    for (final msg in fromMessages) {
      final otherId =
          msg['sender_id'] == currentUserId
              ? msg['recipient_id']
              : msg['sender_id'];

      if (!workerIds.contains(otherId)) {
        final worker =
            await _supabase
                .from('workers')
                .select('id, name, image_url')
                .eq('id', otherId)
                .maybeSingle();

        if (worker != null) {
          workerIds.add(worker['id']);
          _workers.add(worker);
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
        title: const Text('My Chats'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _workers.isEmpty
              ? const Center(child: Text('No workers to chat with.'))
              : ListView.builder(
                itemCount: _workers.length,
                itemBuilder: (context, index) {
                  final worker = _workers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          worker['image_url'] != null
                              ? NetworkImage(worker['image_url'])
                              : null,
                      child:
                          worker['image_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    title: Text(worker['name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                participantName: worker['name'],
                                participantId: worker['id'],
                                participantImageUrl: worker['image_url'] ?? '',
                                isParticipantWorker: true,
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
