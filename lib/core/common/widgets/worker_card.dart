import 'package:flutter/material.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkerCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final double rating;
  final int totalJobs;
  final String charge;

  const WorkerCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.rating,
    required this.totalJobs,
    required this.charge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h), // Reduced margin
      padding: EdgeInsets.all(2.w), // Reduced padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
        border: Border.all(color: Colors.grey.shade300),
        color: AppColors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 30% width for image (reduced from 35%)
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Slightly smaller radius
            child: Image.network(
              imagePath,
              width: MediaQuery.of(context).size.width * 0.3,
              height: 12.h, // Reduced height
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 18.sp, color: Colors.grey),
            ),
          ),
          SizedBox(width: 2.w), // Reduced spacing
          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp, // Slightly smaller font size
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),

                // Role
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 14.sp, // Slightly smaller font size
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),

                SizedBox(height: 0.5.h), // Reduced spacing
                // Rating
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 1.w),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),

                SizedBox(height: 0.5.h), // Reduced spacing
                // Labels: total job + charge
                Text(
                  'Total job: $totalJobs',
                  style: TextStyle(
                    fontSize: 14.sp, // Slightly smaller font size
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  'Charge: $charge\$',
                  style: TextStyle(
                    fontSize: 14.sp, // Slightly smaller font size
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),

          // Bookmark icon
          Icon(Icons.bookmark_border, size: 18.sp), // Slightly smaller icon
        ],
      ),
    );
  }
}
