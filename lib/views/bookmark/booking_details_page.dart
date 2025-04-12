import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsPage({super.key, required this.booking});

  Future<Map<String, dynamic>?> fetchWorkerInfo() async {
    final workerId = booking['worker_id'];

    if (workerId == null) return null;

    final response =
        await Supabase.instance.client
            .from('workers')
            .select('name, image_url')
            .eq('id', workerId)
            .maybeSingle();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final scheduledAt = DateTime.parse(booking['scheduled_at']);
    final formattedDate =
        '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year} at ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF47B0F0),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchWorkerInfo(),
        builder: (context, snapshot) {
          final worker = snapshot.data;
          final img = worker?['image_url'] ?? '';
          final name = worker?['name'] ?? 'Worker';

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            img.isNotEmpty ? NetworkImage(img) : null,
                        child:
                            img.isEmpty
                                ? const Icon(Icons.person, size: 40)
                                : null,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        booking['service'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 1.h),
                      _detailRow('Date & Time:', formattedDate),
                      _detailRow('Status:', booking['status']),
                      _detailRow('Phone:', booking['phone_number']),
                      _detailRow('Location:', booking['location']),
                      _detailRow('Cleaning Type:', booking['cleaning_type']),
                      _detailRow(
                        'Rooms:',
                        booking['number_of_rooms'].toString(),
                      ),
                      _detailRow(
                        'Apartment Size:',
                        '${booking['apartment_size']} m²',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47B0F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(fontSize: 17.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
