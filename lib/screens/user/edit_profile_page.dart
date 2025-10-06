// edit_profile_page.dart
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  // Fields to receive and pre-populate the form
  final String fullName;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String dob;
  final String bloodGroup;
  final String location;
  final int donations;
  final String lastDonation;

  const EditProfilePage({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.location,
    required this.donations,
    required this.lastDonation,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedGender;
  String? _selectedBloodGroup;

  // Controllers to pre-fill data and handle edits
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _dobController;
  late TextEditingController _locationController;
  late TextEditingController _donationsController;
  late TextEditingController _lastDonationController;

  @override
  void initState() {
    super.initState();
    // Initialize state fields from widget properties
    _selectedGender = widget.gender;
    _selectedBloodGroup = widget.bloodGroup;

    // Initialize controllers with incoming data
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _ageController = TextEditingController(text: widget.age.toString());
    _dobController = TextEditingController(text: widget.dob);
    _locationController = TextEditingController(text: widget.location);
    _donationsController = TextEditingController(text: widget.donations.toString());
    _lastDonationController = TextEditingController(text: widget.lastDonation);
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateParts = widget.dob.split('/');
    DateTime initialDate = DateTime.tryParse('${dateParts[2]}-${dateParts[1]}-${dateParts[0]}') ?? DateTime(2000);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _saveChanges(BuildContext context) {
    // Collect all updated data into a Map
    final updatedData = {
      'fullName': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'age': int.tryParse(_ageController.text) ?? widget.age,
      'gender': _selectedGender,
      'dob': _dobController.text,
      'bloodGroup': _selectedBloodGroup ?? widget.bloodGroup,
      'location': _locationController.text,
      'donations': int.tryParse(_donationsController.text) ?? widget.donations,
      'lastDonation': _lastDonationController.text,
    };

    // Pop the screen and pass the data Map back to the previous widget
    Navigator.pop(context, updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Changes Saved!")),
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
              // Profile Picture
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png', // Placeholder image
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Change image ✏️", style: TextStyle(color: Colors.red)),

              const SizedBox(height: 20),

              // Input Fields
              _buildTextField("Name", _nameController),
              _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField("Phone", _phoneController, keyboardType: TextInputType.phone),
              _buildTextField("Age", _ageController, keyboardType: TextInputType.number),

              // Gender
              Row(
                children: [
                  Expanded(child: RadioListTile(title: const Text("Man"), value: "Male", groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value.toString()))),
                  Expanded(child: RadioListTile(title: const Text("Female"), value: "Female", groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value.toString()))),
                ],
              ),

              // Date of Birth
              _buildTextField("Date of Birth", _dobController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context)),

              // Blood Group
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: _inputDecoration("Blood Group"),
                items: ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
              ),
              
              _buildTextField("Location", _locationController),
              _buildTextField("Donation", _donationsController, keyboardType: TextInputType.number),
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
      ),
    );
  }
}