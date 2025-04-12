import 'package:flutter/material.dart';
import 'package:home_services_app/views/services/book_worker_user.dart';
import 'package:home_services_app/views/services/chat_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerServiceDetailsView extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final String location;
  final double rating;
  final String reviews;
  final String rate;
  final String description;
  final String workerId; // UUID of the worker

  const WorkerServiceDetailsView({
    super.key,
    required this.workerId,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.rate,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF47B0F0),
        elevation: 0,
        title: Text(
          role,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Icon(Icons.bookmark_border, color: Colors.white),
                SizedBox(width: 12),
                Icon(Icons.share, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
              width: 100.w,
              height: 30.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 2.h),

          // Name & Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          location,
                          style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                        ),
                      ],
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
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '($reviews)',
                          style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '$rate\$/hr',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Chat and Call
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final response =
                          await Supabase.instance.client
                              .from('workers')
                              .select('image_url')
                              .eq('id', workerId)
                              .maybeSingle();

                      final imageUrl =
                          response != null && response['image_url'] != null
                              ? response['image_url']
                              : '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                participantName: name,
                                participantId: workerId,
                                participantImageUrl: imageUrl,
                                isParticipantWorker: true,
                              ),
                        ),
                      );
                    },

                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEAF2FB),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 1.5.h),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEAF2FB),
                    child: Icon(Icons.call, color: Colors.blue, size: 20.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Description
          Text(
            'Description',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 4.h),

          // Book Now
          SizedBox(
            width: double.infinity,
            height: 6.5.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BookWorkerUserPage(
                          workerId:
                              workerId
                                  .toString(), // assuming this is the worker's UUID
                          serviceTitle:
                              role, // assuming role is the service name
                        ),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF47B0F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Book now',
                style: TextStyle(fontSize: 17.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
