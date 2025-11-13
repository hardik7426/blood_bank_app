import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Required for date formatting

class BloodDonationPage extends StatefulWidget {
  const BloodDonationPage({super.key});

  @override
  State<BloodDonationPage> createState() => _BloodDonationPageState();
}

class _BloodDonationPageState extends State<BloodDonationPage> {
  // -------------------- Firebase Instances -------------------- //
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------- Form and Controllers -------------------- //
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _selectedGender = userData['gender'];
          _selectedBloodGroup = userData['blood_group'];
          setState(() {}); 
        }
      } catch (e) {
        debugPrint('Error loading user profile for donation form: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFF94747)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Use DateFormat to ensure consistent display
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedGender == null || _selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields."), backgroundColor: Colors.red),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to submit a request."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final requestData = {
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'dateOfDonation': _dateController.text,
        'bloodGroup': _selectedBloodGroup,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('donation_requests').add(requestData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation request sent successfully for approval!"), backgroundColor: Colors.green),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit request: $e"), backgroundColor: Colors.red),
      );
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  // --- Form Field Helper ---
  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPhone = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: onTap != null ? const Icon(Icons.calendar_today, color: Colors.grey) : null,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter your $hint";
        }
        if (isPhone && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
          return "Enter a valid 10-digit phone number";
        }
        return null;
      },
    );
  }

  // --- Dropdown Field Helper ---
  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration("Blood Group"),
      initialValue: _selectedBloodGroup,
      hint: const Text("Select Blood Group"),
      items: <String>[
        'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBloodGroup = newValue;
        });
      },
      validator: (value) => value == null ? "Please select your blood group" : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFF94747),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 60,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Positioned(
                    top: 65,
                    child: Text(
                      "Blood Donation Form",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildValidatedTextField(controller: _nameController, hint: "Name"),
                    const SizedBox(height: 20),

                    _buildValidatedTextField(controller: _emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),

                    _buildValidatedTextField(controller: _phoneController, hint: "Phone", keyboardType: TextInputType.phone, isPhone: true),
                    const SizedBox(height: 20),

                    // Gender
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text('Gender:'),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Man'),
                              value: 'Male',
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value),
                              activeColor: Colors.red,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Female'),
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value),
                              activeColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date of Donation
                    _buildValidatedTextField(
                      controller: _dateController,
                      hint: "Date of Donation",
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),

                    // Blood Group Dropdown
                    _buildBloodGroupDropdown(),
                    const SizedBox(height: 40),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, 
                        foregroundColor: Colors.white, 
                        minimumSize: const Size(double.infinity, 50), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Submit", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
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