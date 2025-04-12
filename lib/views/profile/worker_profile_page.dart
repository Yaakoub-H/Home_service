import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkerProfilePage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const WorkerProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF63A8F1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  profile['image_url'] != null
                      ? NetworkImage(profile['image_url'])
                      : null,
              child:
                  profile['image_url'] == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
            ),
            SizedBox(height: 2.h),
            Text(
              profile['name'] ?? 'N/A',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              profile['email'] ?? 'No Email',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 3.h),

            // Card for profile info
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoTile(Icons.info_outline, "Bio", profile['bio']),
                  _infoTile(
                    Icons.location_on_outlined,
                    "Location",
                    profile['location'],
                  ),
                  _infoTile(
                    Icons.attach_money_outlined,
                    "Hourly Rate",
                    '${profile['hourly_rate']} \$',
                  ),
                  _infoTile(
                    Icons.cleaning_services_outlined,
                    "Service",
                    profile['service'],
                  ),
                  _infoTile(
                    Icons.star_border_outlined,
                    "Rating",
                    '${profile['rating']}',
                  ),
                  _infoTile(
                    Icons.work_outline,
                    "Total Jobs",
                    '${profile['total_jobs']}',
                  ),
                  _infoTile(
                    Icons.reviews_outlined,
                    "Total Reviews",
                    '${profile['total_reviews']}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.3.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20.sp),
          SizedBox(width: 4.w),
          Text(
            "$title:",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'N/A',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }
}
