import 'package:flutter/material.dart';
import 'package:home_services_app/core/common/widgets/vertical_service_tile.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/views/services/service_workers_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ServiceWorkersView(
                                serviceTitle: service['title'],
                              ),
                        ),
                      );
                    },
                    child: VerticalServiceTile(
                      title: service['title'],
                      imageUrl: service['image_url'],
                    ),
                  );
                },
              ),
    );
  }
}
