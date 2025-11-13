import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:blood_bank_app/screens/splash/splash_screen.dart'; // FIX: Import the new splash file
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

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
        fontFamily: 'Montserrat',
      ),
      // Set the SplashScreen as the initial home page
      home: const SplashScreen(), 
    );
  }
}