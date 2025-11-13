import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_bank_app/screens/auth/login_page.dart';
import 'package:blood_bank_app/screens/auth/checkup_page.dart';
import 'package:blood_bank_app/screens/admin/admin_dashboard_page.dart';
import 'package:blood_bank_app/screens/user/user_dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Determines the next page based on login status and checkup status
  Future<Widget> _checkAuthAndStatus() async {
    // Wait briefly to show the splash screen image/logo (optional)
    await Future.delayed(const Duration(seconds: 2));

    final user = _auth.currentUser;

    if (user == null) {
      // 1. User is NOT logged in: Go to Login Page
      return const LoginPage();
    }

    try {
      // 2. User IS logged in: Check profile status
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // User logged in but profile data is missing (should prompt registration or logout)
        await _auth.signOut();
        return const LoginPage();
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      final bool requiresCheckup = userData['checkup_required'] ?? true;
      final bool isAdmin = userData['isAdmin'] ?? false;

      // Prepare data to pass to the dashboard
      final String fullName = userData['name'] ?? 'User';
      final int age = userData['age'] as int? ?? 0;
      final String bloodGroup = userData['blood_group'] ?? 'N/A';

      if (isAdmin) {
        // 3. User is Admin: Go to Admin Dashboard
        return const AdminDashboardPage();
      } else if (requiresCheckup) {
        // 4. User is Regular but needs checkup: Go to Checkup Page
        return const CheckupPage();
      } else {
        // 5. User is Regular and checkup is complete: Go to User Dashboard
        return UserDashboardPage(
          fullName: fullName,
          age: age,
          bloodGroup: bloodGroup,
        );
      }
    } catch (e) {
      // Log and default to login on error
      print("Error fetching user status: $e");
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkAuthAndStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking status, display the splash screen UI
          return const Scaffold(
            backgroundColor: Color(0xFFF94747),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 100),
                  SizedBox(height: 20),
                  Text(
                    "Blood Bank App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          );
        }
        // Once the future is complete, navigate to the determined screen
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        // Default error fallback
        return const LoginPage(); 
      },
    );
  }
}