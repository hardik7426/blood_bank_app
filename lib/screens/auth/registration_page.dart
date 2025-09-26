import 'package:blood_bank_app/screens/auth/login_page.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top red curved section
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Registration",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Input Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("Name"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration("Email"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration("Phone"),
                  ),
                  const SizedBox(height: 20),

                  // Gender
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Man"),
                          value: "man",
                          groupValue: _selectedGender,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          activeColor: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Female"),
                          value: "female",
                          groupValue: _selectedGender,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          activeColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // DOB
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputDecoration("Date of Birth").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Blood Group
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: _inputDecoration("Blood Group"),
                    items: [
                      'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                    ].map((bg) {
                      return DropdownMenuItem(
                        value: bg,
                        child: Text(bg),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedBloodGroup = value),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Password").copyWith(
                      suffixIcon:
                          const Icon(Icons.visibility_off, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Register button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  // Directly go back to LoginPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Already have account?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ",
                    style: TextStyle(color: Colors.black54)),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }
}