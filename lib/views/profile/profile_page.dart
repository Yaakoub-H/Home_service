import 'package:flutter/material.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/views/auth/login_page.dart';
import 'package:home_services_app/views/profile/edit_profile_page.dart';
import 'package:home_services_app/views/services/add_new_workers.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _fullName = 'Loading...';
  String _email = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response =
            await Supabase.instance.client
                .from('users')
                .select('full_name, email')
                .eq('id', user.id)
                .single();

        setState(() {
          _fullName = response['full_name'] ?? 'No Name';
          _email = response['email'] ?? 'No Email';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Top Header
          Container(
            width: 100.w,
            padding: EdgeInsets.only(
              top: 6.h,
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ),

          // Profile info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 30.sp, color: Colors.grey),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _email,
                        style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Wallet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF4FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Wallet amount: 200\$',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Options List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: [
                _buildOptionTile(Icons.receipt_long, 'My booking'),
                _buildOptionTile(Icons.card_giftcard, 'Refer and earn'),
                _buildOptionTile(Icons.language, 'Language'),
                _buildOptionTile(Icons.settings, 'App settings'),
                _buildOptionTile(Icons.description, 'Terms & conditions'),
                _buildOptionTile(Icons.add, 'Add New Worker'),
                _buildOptionTile(Icons.privacy_tip, 'Privacy Policy'),
                _buildOptionTile(Icons.contact_mail, 'Contact us'),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Log out',
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                  onTap: () async {
                    try {
                      // End Supabase session
                      await Supabase.instance.client.auth.signOut();

                      // Navigate to the login page
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginView(),
                        ), // Replace with your login page
                        (route) => false, // Remove all previous routes
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error logging out: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: TextStyle(fontSize: 16.sp)),
      trailing: Icon(Icons.chevron_right, color: Colors.black45),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddNewWorkers()),
        );
      },
    );
  }
}
