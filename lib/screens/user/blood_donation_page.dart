import 'package:flutter/material.dart';

class BloodDonationPage extends StatefulWidget {
  const BloodDonationPage({super.key});

  @override
  State<BloodDonationPage> createState() => _BloodDonationPageState();
}

class _BloodDonationPageState extends State<BloodDonationPage> {
  String? _selectedGender;
  String? _selectedBloodGroup;
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
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

            // Input fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  TextField(
                    decoration: _inputDecoration("Name"),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    decoration: _inputDecoration("Email"),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    decoration: _inputDecoration("Phone"),
                  ),
                  const SizedBox(height: 20),

                  // Gender
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Man'),
                          value: 'man',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() => _selectedGender = value);
                          },
                          activeColor: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Female'),
                          value: 'female',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() => _selectedGender = value);
                          },
                          activeColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputDecoration("Date of Birth").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Blood Group Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Blood Group"),
                        value: _selectedBloodGroup,
                        items: <String>[
                          'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Form submitted!")),
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
                      "Submit",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }
}
