import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pro_dashboard_screen.dart';

void main() {
  runApp(const ShopMKTApp());
}

class ShopMKTApp extends StatelessWidget {
  const ShopMKTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopMKT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/pro_dashboard': (context) => const ProDashboardScreen(),
      },
    );
  }
}
