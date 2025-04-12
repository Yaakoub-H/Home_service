import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/core/constants/colors.dart';
import 'package:home_services_app/main_scaffold.dart';
import 'package:home_services_app/views/bookmark/workers_home_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/welcome/welcome_page_one.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize Firebase

  // Initialize Supabase
  await Supabase.initialize(
    url:
        'https://poveznaxffsmriwxzana.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvdmV6bmF4ZmZzbXJpd3h6YW5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQzNzc0MTUsImV4cCI6MjA1OTk1MzQxNX0.1aB4xqcOv1wTpgeb7At_VhwLhLb1t7kDV0nm5gY8enw', // Replace with your Supabase anon key
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialPage() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final userId = session.user.id;
      print('Current userId: $userId');

      if (userId != null) {
        // Check if the user exists in the 'users' table
        final userResponse =
            await Supabase.instance.client
                .from('users')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
        print('User response: $userResponse');

        if (userResponse != null) {
          return const MainScaffold();
        }

        // Check if the user exists in the 'workers' table
        final workerResponse =
            await Supabase.instance.client
                .from('workers')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
        print('Worker response: $workerResponse');

        if (workerResponse != null) {
          return const WorkerHomePage();
        }
      }
    }

    print('No matching user or worker found. Redirecting to WelcomePageOne.');
    return const WelcomePageOne();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.white,
            primaryColor: AppColors.primaryBlue,
            fontFamily: 'Roboto',
          ),
          home: FutureBuilder<Widget>(
            future: _getInitialPage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return snapshot.data!;
              } else {
                return const WelcomePageOne(); // Fallback in case of error
              }
            },
          ),
        );
      },
    );
  }
}
