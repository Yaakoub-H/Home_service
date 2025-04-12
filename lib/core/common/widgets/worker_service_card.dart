import 'package:flutter/material.dart';
import 'package:home_services_app/views/services/WorkerServiceDetailsView.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkerServiceCard extends StatelessWidget {
  final String workerId;

  final String name;
  final String role;
  final String imagePath;
  final String rate;
  final double rating;
  final String reviews;
  final String location;
  final String description;

  const WorkerServiceCard({
    super.key,
    required this.workerId,

    required this.name,
    required this.role,
    required this.imagePath,
    required this.rate,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => WorkerServiceDetailsView(
                  workerId: workerId,
                  name: name,
                  role: role,
                  imagePath: imagePath,
                  location: location,
                  rating: rating,
                  reviews: reviews,
                  rate: rate,
                  description: description,
                ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagePath,
                width: 22.w,
                height: 11.h,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.broken_image,
                      size: 22.sp,
                      color: Colors.grey,
                    ),
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
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '($reviews)',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    role,
                    style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFF47B0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$rate/hr',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
