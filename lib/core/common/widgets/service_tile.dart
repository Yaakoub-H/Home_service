import 'package:flutter/material.dart';
import 'package:home_services_app/views/services/service_workers_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServiceTile extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ServiceTile({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceWorkersView(serviceTitle: title),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 10.h,
              width: 10.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 10.h, color: Colors.grey);
              },
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
