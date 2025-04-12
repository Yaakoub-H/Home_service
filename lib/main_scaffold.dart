import 'package:flutter/material.dart';
import 'package:home_services_app/views/bookmark/booking_page.dart';
import 'package:home_services_app/views/home/home_page.dart';
import 'package:home_services_app/views/profile/profile_page.dart';
import 'package:home_services_app/views/services/servies_page.dart';
import 'package:home_services_app/views/services/user_chat_worker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    ServicesView(),
    UserChatWorkersPage(),
    BookingPage(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black.withOpacity(0.4),
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13.sp,
            ),
            items: [
              _buildNavItem(Icons.home, 'Home', _selectedIndex == 0),
              _buildNavItem(
                Icons.receipt_long,
                'Services',
                _selectedIndex == 1,
              ),
              _buildNavItem(
                Icons.chat_bubble_outline,
                'Chats',
                _selectedIndex == 2,
              ),

              _buildNavItem(
                Icons.bookmark_border,
                'Bookmarks',
                _selectedIndex == 3,
              ),
              _buildNavItem(Icons.person, 'Profile', _selectedIndex == 4),
            ],
          ),
        ),
      ),
    );
  }
}
