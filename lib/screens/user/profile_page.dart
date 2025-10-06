// profile_page.dart
import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/user/edit_profile_page.dart'; // Ensure correct import

class ProfilePage extends StatefulWidget {
  // All fields are now passed into the widget's constructor
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final int donations;
  final String bloodGroup;
  final String gender;
  final String dob;
  final int age;
  final String lastDonation;

  const ProfilePage({
    super.key,
    this.fullName = 'User name',
    this.email = 'bloodbanks@gmail.com',
    this.phone = '1234567890',
    this.location = 'India,Gujrat ',
    this.donations = 5,
    this.bloodGroup = 'A+',
    this.gender = 'Male',
    this.dob = '02/02/2000',
    this.age = 19,
    this.lastDonation = '3/9/2024',
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Convert fields to state variables to hold dynamic data
  late String _fullName;
  late String _email;
  late String _phone;
  late String _location;
  late int _donations;
  late String _bloodGroup;
  late String _gender;
  late String _dob;
  late int _age;
  late String _lastDonation;

  @override
  void initState() {
    super.initState();
    // Initialize state variables with constructor values
    _fullName = widget.fullName;
    _email = widget.email;
    _phone = widget.phone;
    _location = widget.location;
    _donations = widget.donations;
    _bloodGroup = widget.bloodGroup;
    _gender = widget.gender;
    _dob = widget.dob;
    _age = widget.age;
    _lastDonation = widget.lastDonation;
  }

  // Function to handle navigation and state update
  void _navigateToEditProfile(BuildContext context) async {
    // Navigate and await result (the updated data map)
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          fullName: _fullName,
          email: _email,
          phone: _phone,
          location: _location,
          donations: _donations,
          bloodGroup: _bloodGroup,
          gender: _gender,
          dob: _dob,
          age: _age,
          lastDonation: _lastDonation,
        ),
      ),
    );

    // Check if data was returned (user clicked Save Changes)
    if (updatedData != null && updatedData is Map<String, dynamic>) {
      setState(() {
        _fullName = updatedData['fullName'];
        _email = updatedData['email'];
        _phone = updatedData['phone'];
        _location = updatedData['location'];
        _donations = updatedData['donations'];
        _bloodGroup = updatedData['bloodGroup'];
        _gender = updatedData['gender'];
        _dob = updatedData['dob'];
        _age = updatedData['age'];
        _lastDonation = updatedData['lastDonation'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF94747),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

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
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _fullName, // Use state variable
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            _email, // Use state variable
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    // Use state variables for detail rows
                    _ProfileDetailRow(label: "Phone", value: _phone),
                    _ProfileDetailRow(label: "Location", value: _location),
                    _ProfileDetailRow(label: "Donations", value: _donations.toString()),
                    _ProfileDetailRow(label: "Blood Group", value: _bloodGroup),
                    _ProfileDetailRow(label: "Gender", value: _gender),
                    _ProfileDetailRow(label: "DOB", value: _dob),
                    _ProfileDetailRow(label: "Age", value: _age.toString()),
                    _ProfileDetailRow(label: "Last Donation", value: _lastDonation),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () => _navigateToEditProfile(context), // Call the state handler
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
          const Divider(height: 10, color: Colors.grey),
        ],
      ),
    );
  }
}