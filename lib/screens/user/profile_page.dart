import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  // Assuming these details are passed from the UserDashboard or a state management system
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
    // Using dummy data as default, but ideally this should come from user data
    this.fullName = 'Dabhi Dhiraj',
    this.email = 'bloodbanks@gmail.com',
    this.phone = '1234567890',
    this.location = 'India Gujarat',
    this.donations = 5,
    this.bloodGroup = 'A+',
    this.gender = 'Male',
    this.dob = '02/02/2000',
    this.age = 19,
    this.lastDonation = '3/9/2024',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom Curved Header
          Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFFF94747),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 40),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // White background circle for image
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: ClipOval(
                          // Placeholder for the user image
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

                  // Name and Email
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Detail Section (Profile button is redundant since we are on the profile page, removed for clean UI)
                  
                  // Profile Details List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        _ProfileDetailRow(label: "Phone", value: phone),
                        _ProfileDetailRow(label: "Location", value: location),
                        _ProfileDetailRow(label: "Donations", value: donations.toString()),
                        _ProfileDetailRow(label: "Blood Group", value: bloodGroup),
                        _ProfileDetailRow(label: "Gender", value: gender),
                        _ProfileDetailRow(label: "DOB", value: dob),
                        _ProfileDetailRow(label: "Age", value: age.toString()),
                        _ProfileDetailRow(label: "Last Donation", value: lastDonation),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Edit Profile Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement navigation to Edit Profile screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for displaying profile details in two columns
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
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 10, color: Colors.grey),
        ],
      ),
    );
  }
}