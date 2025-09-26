import 'package:blood_bank_app/screens/user/user_dashboard_page.dart';
import 'package:flutter/material.dart';
//import 'user_dashboard_page.dart';

class CheckupPage extends StatefulWidget {
  const CheckupPage({super.key});

  @override
  State<CheckupPage> createState() => _CheckupPageState();
}

class _CheckupPageState extends State<CheckupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedBloodGroup;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for Checkup'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter full name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                ),
                onTap: () => _selectDate(context),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pick DOB' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Age required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Blood group'),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Select blood group' : null,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Navigate to dashboard
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDashboardPage(
                          fullName: _fullNameController.text.trim(),
                          age: int.tryParse(_ageController.text) ?? 0,
                          bloodGroup: _selectedBloodGroup ?? 'Unknown',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('REGISTER FOR CHECKUP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
