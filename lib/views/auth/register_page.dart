import 'package:flutter/material.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/views/auth/login_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign up the user
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {'name': _nameController.text},
      );

      if (response.user != null) {
        // Insert user into the 'users' table
        await Supabase.instance.client.from('users').insert({
          'id': response.user!.id, // Use the user's unique ID
          'full_name': _nameController.text,
          'email': _emailController.text,
          'phone': '', // Leave phone empty
          'image_url': '', // Leave image_url empty
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to the login page or main scaffold
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.app_registration,
                  size: 35.w,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 3.h),
              Center(
                child: Text(
                  'Register',
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
                  'Please create your account to continue\nassociated with us.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 4.h),

              _buildInputField(
                controller: _nameController,
                icon: Icons.person,
                hint: 'Enter your name',
              ),
              _buildInputField(
                controller: _emailController,
                icon: Icons.email,
                hint: 'Enter your email id',
              ),
              _buildInputField(
                controller: _passwordController,
                icon: Icons.lock,
                hint: 'Create password',
                isObscure: true,
              ),
              _buildInputField(
                controller: _confirmPasswordController,
                icon: Icons.lock,
                hint: 'Confirm password',
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
                    onPressed: _isLoading ? null : _register,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Already have an account
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 16.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
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
