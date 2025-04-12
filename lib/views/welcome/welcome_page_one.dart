import 'package:flutter/material.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/views/welcome/welcome_page_two.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WelcomePageOne extends StatelessWidget {
  const WelcomePageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 2),
                  Image.asset(
                    'assets/img_wlcm1.png',
                    fit: BoxFit.contain,
                    width: 70.w,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'WELCOME TO',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'BAYTAK YASTAHEL',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WelcomePageTwo(),
                          ),
                        );
                      },
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
