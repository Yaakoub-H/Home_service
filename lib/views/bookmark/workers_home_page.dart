import 'package:flutter/material.dart';
import 'package:home_services_app/views/auth/login_page.dart'; // Import the login page
import 'package:home_services_app/views/bookmark/booking_details_page.dart';
import 'package:home_services_app/views/bookmark/booking_page.dart';
import 'package:home_services_app/views/profile/notification_page.dart';
import 'package:home_services_app/views/profile/worker_profile_page.dart';
import 'package:home_services_app/views/services/worker_chat_user.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  List<Map<String, dynamic>> ongoing = [];
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;
  Map<String, dynamic>? workerProfile;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _fetchWorkerProfile();
  }

  Future<void> _fetchBookings() async {
    final workerId = Supabase.instance.client.auth.currentUser?.id;
    print("Worker ID: $workerId");
    if (workerId == null) return;

    final data = await Supabase.instance.client
        .from('bookings')
        .select('*, users(full_name, image_url)')
        .eq('worker_id', workerId)
        .order('scheduled_at');

    print("Bookings Data: $data");

    final all = List<Map<String, dynamic>>.from(data);
    setState(() {
      ongoing = all.where((b) => b['status'] == 'pending').toList();
      history = all.where((b) => b['status'] == 'done').toList();
      isLoading = false;
    });
  }

  Future<void> _fetchWorkerProfile() async {
    final workerId = Supabase.instance.client.auth.currentUser?.id;
    if (workerId == null) return;

    final data =
        await Supabase.instance.client
            .from('workers')
            .select()
            .eq('id', workerId)
            .maybeSingle();

    setState(() {
      workerProfile = data;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false, // Remove all previous routes
    );
  }

  void _openFullProfile() {
    if (workerProfile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerProfilePage(profile: workerProfile!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 11.h,
          backgroundColor: const Color(0xFF63A8F1),
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Jobs',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: [Tab(text: 'Ongoing'), Tab(text: 'History')],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkerChatUsersPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: _openFullProfile,
            ),

            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    _buildBookingList(ongoing, showActions: true),
                    _buildBookingList(history),
                  ],
                ),
      ),
    );
  }

  Widget _buildBookingList(
    List<Map<String, dynamic>> list, {
    bool showActions = false,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Text("No jobs yet.", style: TextStyle(fontSize: 17.sp)),
      );
    }

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final booking = list[index];
          final user = booking['users'];
          final img = user?['image_url'] ?? '';
          final name = user?['full_name'] ?? 'User';
          final service = booking['service'];
          final time = DateTime.parse(booking['scheduled_at']);
          final timeStr =
              '${time.month}/${time.day}/${time.year} at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

          return BookingCard(
            image: img,
            name: name,
            dateTime: timeStr,
            role: service,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailsPage(booking: booking),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
