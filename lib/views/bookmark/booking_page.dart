import 'package:flutter/material.dart';
import 'package:home_services_app/views/bookmark/booking_details_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> ongoing = [];
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final data = await Supabase.instance.client
        .from('bookings')
        .select('*, workers(name, image_url)')
        .eq('user_id', userId)
        .order('scheduled_at');

    final all = List<Map<String, dynamic>>.from(data);
    setState(() {
      ongoing = all.where((b) => b['status'] == 'pending').toList();
      history = all.where((b) => b['status'] == 'done').toList();
      isLoading = false;
    });
  }

  Future<void> _updateBookingStatus(String id, String status) async {
    await Supabase.instance.client
        .from('bookings')
        .update({'status': status})
        .eq('id', id);
    _fetchBookings();
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
                  'My booking',
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
        child: Text("No bookings yet.", style: TextStyle(fontSize: 17.sp)),
      );
    }

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final booking = list[index];
          final worker = booking['workers'];
          final img = worker?['image_url'] ?? '';
          final name = worker?['name'] ?? 'Worker';
          final service = booking['service'];
          final time = DateTime.parse(booking['scheduled_at']);
          final timeStr =
              '${time.month}/${time.day}/${time.year} at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          return BookingCard(
            image: img,
            name: name,
            dateTime: timeStr,
            role: service,
            onCancel:
                showActions
                    ? () => _updateBookingStatus(booking['id'], 'cancelled')
                    : null,
            onDone:
                showActions
                    ? () => _updateBookingStatus(booking['id'], 'done')
                    : null,
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

class BookingCard extends StatelessWidget {
  final String image;
  final String name;
  final String dateTime;
  final String role;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.image,
    required this.name,
    required this.dateTime,
    required this.role,
    this.onCancel,
    this.onDone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                width: 20.w,
                height: 10.h,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    dateTime,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(role, style: TextStyle(fontSize: 15.sp)),
                ],
              ),
            ),
            if (onCancel != null && onDone != null)
              Column(
                children: [
                  _actionButton('Cancel', Colors.red, onCancel!),
                  SizedBox(height: 1.h),
                  _actionButton('Done', Colors.green, onDone!),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
