import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/main_scaffold.dart';
import 'package:home_services_app/views/auth/register_page.dart';
import 'package:home_services_app/views/bookmark/workers_home_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.session != null) {
        // Check if the email exists in the 'workers' table
        final userId = response.session!.user.id;

        // Save the device token
        await saveDeviceToken(userId);
        final workerResponse =
            await Supabase.instance.client
                .from('workers')
                .select('email')
                .eq('email', _emailController.text)
                .maybeSingle();

        if (workerResponse != null) {
          // Redirect to WorkerHomePage if email is in 'workers' table
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful as Worker!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkerHomePage()),
          );
        } else {
          // Redirect to MainScaffold if email is not in 'workers' table
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScaffold()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
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

  Future<void> saveDeviceToken(String userId) async {
    try {
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      final String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        await Supabase.instance.client.from('device_tokens').upsert({
          'user_id': userId,
          'token': token,
          'created_at': DateTime.now().toIso8601String(),
        });

        print('Device token saved: $token');
      }
    } catch (e) {
      print('Error saving device token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.login, size: 35.w, color: Colors.blue)),
              SizedBox(height: 3.h),
              Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Center(
                child: Text(
                  'Please login to continue your session',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 4.h),

              _buildInputField(
                controller: _emailController,
                icon: Icons.email,
                hint: 'Enter your email id',
              ),
              _buildInputField(
                controller: _passwordController,
                icon: Icons.lock,
                hint: 'Enter your password',
                isObscure: true,
              ),

              SizedBox(height: 3.h),
              Center(
                child: SizedBox(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterView()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 16.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isObscure = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.purple),
          ),
        ),
      ),
    );
  }
}
