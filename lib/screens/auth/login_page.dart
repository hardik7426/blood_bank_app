import 'package:blood_bank_app/screens/auth/forgot_password_email_page.dart';
import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/auth/registration_page.dart';
import 'package:blood_bank_app/screens/auth/checkup_page.dart';
import 'package:blood_bank_app/screens/admin/admin_dashboard_page.dart';
import 'package:blood_bank_app/screens/user/user_dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  static const String _staticAdminEmail = "admin@gmail.com";
  static const String _staticAdminPassword = "admin123";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. STATIC ADMIN CHECK (Bypass)
    if (email == _staticAdminEmail && password == _staticAdminPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin Login Successful!'), backgroundColor: Colors.blue));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) throw FirebaseAuthException(code: 'user-data-missing', message: 'User profile not found. Please register again.');
      
      final userData = userDoc.data() as Map<String, dynamic>;

      // FIX: Checkup required logic (defaults to TRUE if the field doesn't exist)
      final bool requiresCheckup = (userData['checkup_required'] is bool) ? userData['checkup_required'] as bool : true; 
      
      final String fullName = userData['name'] ?? 'User';
      final int age = (userData['age'] is int) ? userData['age'] as int : (int.tryParse('${userData['age']}') ?? 0);
      final String bloodGroup = userData['blood_group'] ?? 'N/A';

      // 2. NAVIGATION BASED ON ROLE/STATUS
      if (userData['isAdmin'] == true) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
      } else if (requiresCheckup) {
        // Go to Checkup Page only if flag is TRUE
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CheckupPage()));
      } else {
        // Go directly to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserDashboardPage(
              fullName: fullName,
              age: age,
              bloodGroup: bloodGroup,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = (e.code == 'user-not-found' || e.code == 'wrong-password') ? 'Invalid email or password.' : 'Login failed: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // --- Input Decoration Helper ---
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), 
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFF94747),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80), bottomRight: Radius.circular(80)),
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, size: 60, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                    SizedBox(width: 10),
                    Text("👋", style: TextStyle(fontSize: 28)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your email';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Password").copyWith(suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                  },
                  child: const Text("Forgot password?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage()));
                },
                child: const Text("Register", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

