import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/teacher_dashboard.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await ApiService.loadLoginData();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    Widget homeScreen = const LoginScreen();
    
    if (isLoggedIn) {
      if (ApiService.loggedInUserType == 'teacher') {
        homeScreen = const TeacherDashboardScreen();
      } else {
        homeScreen = const DashboardScreen();
      }
    }

    return MaterialApp(
      title: 'Result Viewer System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeScreen,
    );
  }
}