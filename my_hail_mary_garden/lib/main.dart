import 'package:flutter/material.dart';
import 'services/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyGardenApp());
}

class MyGardenApp extends StatelessWidget {
  const MyGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Garden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
