import 'package:flutter/material.dart';
import 'package:home_services_app/firebase_notifications.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookWorkerUserPage extends StatefulWidget {
  final String workerId;
  final String serviceTitle;

  const BookWorkerUserPage({
    super.key,
    required this.workerId,
    required this.serviceTitle,
  });

  @override
  State<BookWorkerUserPage> createState() => _BookWorkerUserPageState();
}

class _BookWorkerUserPageState extends State<BookWorkerUserPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  int _rooms = 0;
  double _apartmentSize = 100;
  int _selectedChipIndex = 0;
  final List<String> _chipLabels = [
    'Full Home',
    'Kitchen',
    'Bathroom',
    'Bedroom',
  ];
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    final DateTime scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final existing = await Supabase.instance.client
        .from('bookings')
        .select()
        .eq('worker_id', widget.workerId)
        .eq('scheduled_at', scheduledAt.toIso8601String());

    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This time is already booked')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Supabase.instance.client.from('bookings').insert({
      'user_id': currentUserId,
      'worker_id': widget.workerId,
      'service': widget.serviceTitle,
      'status': 'pending',
      'scheduled_at': scheduledAt.toIso8601String(),
      'cleaning_type': _chipLabels[_selectedChipIndex],
      'apartment_size': _apartmentSize.round(),
      'number_of_rooms': _rooms,
      'phone_number': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
    });
    await _sendNotificationToWorker(scheduledAt);

    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Which do you need to clean?'),
        backgroundColor: const Color(0xFF47B0F0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChoiceChips(),
            SizedBox(height: 3.h),
            _buildSlider(),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildSelectorTile(
                    title: 'Select date',
                    subtitle:
                        _selectedDate == null
                            ? 'Select your date'
                            : '${_selectedDate!.toLocal()}'.split(' ')[0],
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildSelectorTile(
                    title: 'Select time',
                    subtitle:
                        _selectedTime == null
                            ? 'Select your time'
                            : _selectedTime!.format(context),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) setState(() => _selectedTime = time);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildNumberInputField('Number of room', _rooms, (inc) {
              setState(() {
                if (inc == -1 && _rooms > 0) {
                  _rooms--;
                } else if (inc == 1) {
                  _rooms++;
                }
              });
            }),
            SizedBox(height: 2.h),
            _buildTextField('Phone number', _phoneController),
            SizedBox(height: 2.h),
            _buildTextField('Location', _locationController),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF47B0F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Confirm booking',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendNotificationToWorker(DateTime scheduledAt) async {
    try {
      // Fetch the worker's device token
      final workerResponse =
          await Supabase.instance.client
              .from('device_tokens')
              .select('token')
              .eq('user_id', widget.workerId)
              .maybeSingle();

      if (workerResponse == null || workerResponse['token'] == null) {
        print("No FCM token found for the worker.");
        return;
      }

      final deviceToken = workerResponse['token'];

      // Fetch the current user's name
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final userResponse =
          await Supabase.instance.client
              .from('users')
              .select('full_name')
              .eq('id', currentUserId)
              .maybeSingle();

      final userName = userResponse?['full_name'] ?? 'A user';

      // Format the date and time
      final formattedDate = '${scheduledAt.toLocal()}'.split(' ')[0];
      final formattedTime =
          '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

      // Send the notification
      await MyFireBaseCloudMessaging.sendNotificationToUser(
        deviceToken,
        widget.workerId,
        context,
        "New Booking Received",
        "$userName has booked you for $formattedDate at $formattedTime.",
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      print("❌ Error sending notification to worker: $e");
    }
  }

  Widget _buildChoiceChips() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 2.w,
      children: List.generate(_chipLabels.length, (index) {
        return ChoiceChip(
          label: Text(_chipLabels[index]),
          selected: _selectedChipIndex == index,
          selectedColor: const Color(0xFF47B0F0),
          backgroundColor: const Color(0xFFE0F0FC),
          labelStyle: TextStyle(
            color: _selectedChipIndex == index ? Colors.white : Colors.black,
          ),
          onSelected: (_) {
            setState(() => _selectedChipIndex = index);
          },
        );
      }),
    );
  }

  Widget _buildSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Apartment size', style: TextStyle(fontSize: 16.sp)),
        Slider(
          value: _apartmentSize,
          onChanged: (val) => setState(() => _apartmentSize = val),
          min: 100,
          max: 8000,
          divisions: 80,
          label: _apartmentSize.round().toString(),
          activeColor: const Color(0xFF47B0F0),
        ),
      ],
    );
  }

  Widget _buildSelectorTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(subtitle),
    onTap: onTap,
  );

  Widget _buildNumberInputField(
    String label,
    int value,
    Function(int) onChange,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 16.sp))),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => onChange(-1),
            ),
            Text(value.toString(), style: TextStyle(fontSize: 17.sp)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChange(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
