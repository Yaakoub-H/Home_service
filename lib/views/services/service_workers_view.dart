import 'package:flutter/material.dart';
import 'package:home_services_app/core/common/widgets/worker_service_card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceWorkersView extends StatefulWidget {
  final String serviceTitle;

  const ServiceWorkersView({super.key, required this.serviceTitle});

  @override
  State<ServiceWorkersView> createState() => _ServiceWorkersViewState();
}

class _ServiceWorkersViewState extends State<ServiceWorkersView> {
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    try {
      final data = await Supabase.instance.client
          .from('workers')
          .select(
            'name, bio, service, location, image_url, rating, total_reviews, hourly_rate',
          )
          .eq('service', widget.serviceTitle);

      setState(() {
        _workers = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching workers: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 11.h,
        backgroundColor: const Color(0xFF47B0F0),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                widget.serviceTitle,
                style: TextStyle(
                  fontSize: 19.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _workers.isEmpty
              ? Center(
                child: Text(
                  'No workers found.',
                  style: TextStyle(fontSize: 17.sp, color: Colors.grey),
                ),
              )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: ListView.builder(
                  itemCount: _workers.length,
                  itemBuilder: (context, index) {
                    final worker = _workers[index];
                    return WorkerServiceCard(
                      workerId: worker['id'].toString() ?? '',
                      name: worker['name'] ?? 'N/A',
                      role: worker['service'] ?? 'Unknown',
                      imagePath: worker['image_url'] ?? '',
                      rate: '${worker['hourly_rate']?.toString() ?? '0'}',
                      rating:
                          double.tryParse(
                            worker['rating']?.toString() ?? '0',
                          ) ??
                          0,
                      reviews: '${worker['total_reviews'] ?? 0}',
                      location: worker['location'] ?? 'N/A',
                      description: worker['bio'] ?? 'No description',
                    );
                  },
                ),
              ),
    );
  }
}
