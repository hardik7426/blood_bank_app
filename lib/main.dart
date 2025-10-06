import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/splash/splash_screen_manager.dart';
// import 'package:blood_bank_app/screens/splash/splash_screen_manager.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Bank App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SplashScreenManager(), // Start here
    );
  }
}
