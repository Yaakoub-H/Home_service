import 'package:flutter/material.dart';
import 'package:home_services_app/core/common/widgets/service_tile.dart';
import 'package:home_services_app/core/common/widgets/worker_card.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/views/services/WorkerServiceDetailsView.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _topWorkers = [];
  bool _isLoading = true;
  bool _loadingWorkers = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchTopWorkers();
  }

  Future<void> _fetchServices() async {
    try {
      final data = await Supabase.instance.client
          .from('services')
          .select('title, image_url');

      setState(() {
        _services = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching services: $e')));
    }
  }

  Future<void> _fetchTopWorkers() async {
    try {
      final data = await Supabase.instance.client
          .from('workers')
          .select(
            'id,name, bio, service, location, image_url, rating, total_jobs, total_reviews, hourly_rate',
          )
          .order('rating', ascending: false)
          .limit(4);

      setState(() {
        _topWorkers = List<Map<String, dynamic>>.from(data);
        _loadingWorkers = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching top providers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(15.h),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5.5.h,
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search for services',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(Icons.notifications, color: Colors.white, size: 24.sp),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 1.h),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2.h,
                    crossAxisSpacing: 3.w,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return ServiceTile(
                      title: service['title'],
                      imageUrl: service['image_url'],
                    );
                  },
                ),

            SizedBox(height: 2.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Service Providers',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            if (_loadingWorkers)
              const Center(child: CircularProgressIndicator())
            else if (_topWorkers.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Center(
                  child: Text(
                    'No top providers found.',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children:
                    _topWorkers.map((worker) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => WorkerServiceDetailsView(
                                      workerId: worker['id'].toString() ?? '',
                                      name: worker['name'] ?? 'Unnamed',
                                      role: worker['service'] ?? 'No service',
                                      imagePath: worker['image_url'] ?? '',
                                      location: worker['location'] ?? 'N/A',
                                      rating:
                                          double.tryParse(
                                            worker['rating']?.toString() ?? '0',
                                          ) ??
                                          0,
                                      reviews:
                                          '${worker['total_reviews'] ?? 0}',
                                      rate:
                                          worker['hourly_rate']?.toString() ??
                                          '0',
                                      description:
                                          worker['bio'] ?? 'No description',
                                    ),
                              ),
                            );
                          },
                          child: WorkerCard(
                            name: worker['name'] ?? 'Unnamed',
                            role: worker['service'] ?? '',
                            imagePath: worker['image_url'] ?? '',
                            rating:
                                double.tryParse(
                                  worker['rating']?.toString() ?? '0',
                                ) ??
                                0,
                            totalJobs: worker['total_jobs'] ?? 0,
                            charge: worker['hourly_rate']?.toString() ?? '0',
                          ),
                        ),
                      );
                    }).toList(),
              ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
