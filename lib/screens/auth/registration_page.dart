import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initial = DateTime(2000);
    final DateTime first = DateTime(1900);
    final DateTime last = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.red),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _dateController.text = formatted;
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _handleRegistration() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGender == null || _selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select gender and blood group.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse date of birth
    DateTime? dob;
    try {
      if (_dateController.text.trim().isNotEmpty) {
        dob = DateFormat('dd/MM/yyyy').parseStrict(_dateController.text.trim());
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid date of birth.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'unknown', message: 'Failed to create user.');
      }

      // Prepare user document
      final Map<String, dynamic> userDoc = {
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'date_of_birth': _dateController.text.trim(),
        'gender': _selectedGender,
        'blood_group': _selectedBloodGroup,
        'is_donor_approved': false,
        'checkup_done': false,
        'checkup_required': true,
        'created_at': FieldValue.serverTimestamp(),
        'location': '',
        'donations': 0,
        'last_donation': '',
        'age': dob != null ? _calculateAge(dob) : 0,
      };

      // Also store a timestamp version of DOB (useful for queries)
      if (dob != null) {
        userDoc['dob_timestamp'] = Timestamp.fromDate(dob);
      }

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).set(userDoc);

      // Optional: you could send email verification here
      // await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please log in.'), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'Registration failed: ${e.message ?? e.code}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Input Decoration Helper
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
                      decoration: _inputDecoration("Name"),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.trim().isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) ? 'Enter a valid email' : null,
                      decoration: _inputDecoration("Email"),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter a valid phone number';
                        final digitsOnly = value.trim().replaceAll(RegExp(r'\D'), '');
                        if (digitsOnly.length < 10) return 'Enter a valid phone number';
                        return null;
                      },
                      decoration: _inputDecoration("Phone"),
                    ),
                    const SizedBox(height: 20),
                    // Gender Selection
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Text("Gender:", style: TextStyle(color: Colors.black54)),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Male"),
                              value: "Male",
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value),
                              activeColor: Colors.red,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Female"),
                              value: "Female",
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value),
                              activeColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Date of Birth
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: _inputDecoration("Date of Birth").copyWith(suffixIcon: const Icon(Icons.calendar_today, color: Colors.red)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select DOB' : null,
                    ),
                    const SizedBox(height: 20),
                    // Blood Group Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodGroup,
                      decoration: _inputDecoration("Blood Group"),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBloodGroup = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Select blood group' : null,
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Password").copyWith(suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey)),
                      validator: (v) => (v == null || v.isEmpty || v.length < 6) ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 30),
                    // Register Button
                    Padding(
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Register", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Login", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
