import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/splash/splash_screen_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // The app now starts with the new SplashScreenManager
      home: const SplashScreenManager(),
    );
  }
}