import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNewWorkers extends StatefulWidget {
  const AddNewWorkers({super.key});

  @override
  State<AddNewWorkers> createState() => _AddNewWorkersState();
}

class _AddNewWorkersState extends State<AddNewWorkers> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedService;
  List<String> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final data = await Supabase.instance.client
          .from('services')
          .select('title');

      setState(() {
        _services = List<String>.from(data.map((service) => service['title']));
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching services: $e')));
    }
  }

  Future<void> _addWorker() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _hourlyRateController.text.isEmpty ||
        _imageUrlController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = authResponse.user;
      if (user != null) {
        await Supabase.instance.client.from('workers').insert({
          'id': user.id,
          'email': _emailController.text,
          'name': _nameController.text,
          'bio': _bioController.text,
          'hourly_rate': double.tryParse(_hourlyRateController.text) ?? 0,
          'image_url': _imageUrlController.text,
          'location': _locationController.text,
          'service': _selectedService,
          'rating': 0.0,
          'total_reviews': 0,
          'total_jobs': 0,
          'created_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker added successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create worker account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Worker'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter worker name',
            ),
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter worker email',
            ),
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter worker password',
              isObscure: true,
            ),
            _buildInputField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Enter worker bio',
            ),
            _buildInputField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter worker location',
            ),
            _buildInputField(
              controller: _hourlyRateController,
              label: 'Hourly Rate',
              hint: 'Enter hourly rate',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              controller: _imageUrlController,
              label: 'Image URL',
              hint: 'Enter image URL',
            ),
            _buildDropdownField(
              label: 'Service',
              hint: 'Select a service',
              items: _services,
              value: _selectedService,
              onChanged: (value) {
                setState(() {
                  _selectedService = value;
                });
              },
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addWorker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Add Worker',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: value,
            items:
                items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
