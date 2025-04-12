import 'package:flutter/material.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/views/auth/register_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WelcomePageTwo extends StatelessWidget {
  const WelcomePageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, AppColors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img_wlcm1.png',
                height: 30.h,
                fit: BoxFit.contain,
              ),

              // Title
              Text(
                'Creating happiness\nto your home',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: 4.h),

              // Info rows (stacked vertically, centered)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: AppColors.green, size: 20.sp),
                  SizedBox(width: 2.w),
                  Text(
                    '1500+ Expert Workers',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bubble_chart,
                    color: AppColors.darkBlue,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '30+ Service Categories',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: AppColors.yellow, size: 20.sp),
                  SizedBox(width: 2.w),
                  Text(
                    '2247+ Customer Reviews',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(80.w, 6.h),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterView()),
                  );
                },

                child: Text(
                  'Get started',
                  style: TextStyle(fontSize: 18.sp, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
