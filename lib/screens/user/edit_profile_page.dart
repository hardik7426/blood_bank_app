// edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditProfilePage({
    super.key,
    required this.initialData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  // Controllers initialized with current data
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _dobController;
  late TextEditingController _locationController;
  late TextEditingController _donationsController;
  late TextEditingController _lastDonationController;

  late String _selectedGender;
  late String? _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    // Initialize state variables from initialData
    _selectedGender = widget.initialData['gender'] ?? 'Male';
    _selectedBloodGroup = widget.initialData['blood_group'];

    // Initialize controllers
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _ageController = TextEditingController(text: (widget.initialData['age'] ?? 0).toString());
    _dobController = TextEditingController(text: widget.initialData['date_of_birth'] ?? '');
    _locationController = TextEditingController(text: widget.initialData['location'] ?? '');
    _donationsController = TextEditingController(text: (widget.initialData['donations'] ?? 0).toString());
    _lastDonationController = TextEditingController(text: widget.initialData['last_donation'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _donationsController.dispose();
    _lastDonationController.dispose();
    super.dispose();
  }

  // Helper method for input decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(2000);
    
    // Attempt to parse DOB for initial selection
    try {
      if (_dobController.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      }
    } catch (e) {
      // Ignore parsing errors, keep default initialDate
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        // Recalculate age after DOB change
        final today = DateTime.now();
        int age = today.year - picked.year;
        if (today.month < picked.month || (today.month == picked.month && today.day < picked.day)) { age--; }
        _ageController.text = age.toString();
      });
    }
  }

  // --- 3. SAVE CHANGES TO FIRESTORE (CRUD: UPDATE) ---
  void _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    // Collect all updated data
    final updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _selectedGender,
      'date_of_birth': _dobController.text,
      'blood_group': _selectedBloodGroup,
      'location': _locationController.text,
      'donations': int.tryParse(_donationsController.text) ?? 0,
      'last_donation': _lastDonationController.text,
    };
    
    try {
      await _firestore.collection('users').doc(_userId).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );

      // Pop the screen and pass the *result* back to ProfilePage to trigger UI refresh
      Navigator.pop(context, true); 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- Build UI ---
  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, TextInputType keyboardType = TextInputType.text, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label).copyWith(
          suffixIcon: icon != null ? Icon(icon, color: Colors.red) : null,
        ),
        validator: (v) => (v == null || v.isEmpty) ? '$label is required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF94747),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Removed Profile Picture Section ---
              
              // Input Fields (pre-filled)
              _buildTextField("Name", _nameController),
              _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress, readOnly: true), // Email should usually be read-only
              _buildTextField("Phone", _phoneController, keyboardType: TextInputType.phone),
              
              // Gender
              Row(
                children: [
                  Expanded(child: RadioListTile(title: const Text("Male"), value: "Male", groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value.toString()))),
                  Expanded(child: RadioListTile(title: const Text("Female"), value: "Female", groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value.toString()))),
                ],
              ),

              // Date of Birth (Tappable ReadOnly field)
              _buildTextField("Date of Birth", _dobController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context)),
              _buildTextField("Age", _ageController, keyboardType: TextInputType.number, readOnly: true), // Age is auto-calculated

              // Blood Group
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: _inputDecoration("Blood Group"),
                items: ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                validator: (v) => (v == null || v.isEmpty) ? 'Select blood group' : null,
              ),
              
              _buildTextField("Location", _locationController),
              _buildTextField("Donations", _donationsController, keyboardType: TextInputType.number),
              _buildTextField("Last Donation", _lastDonationController),

              const SizedBox(height: 20),

              // Save Changes Button
              ElevatedButton(
                onPressed: () => _saveChanges(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}