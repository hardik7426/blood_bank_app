import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/user/edit_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required String fullName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Use state variables to hold dynamic data fetched from Firestore
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // --- 1. FETCH USER DATA FROM FIRESTORE ---
  Future<void> _fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data()!;
            _isLoading = false;
          });
        } else {
          // Profile document doesn't exist yet
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error fetching profile: $e");
      }
    }
  }

  // --- 2. NAVIGATION TO EDIT PAGE ---
  void _navigateToEditProfile(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null || _userData.isEmpty) return;

    // Navigate and await the result (the updated data map)
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          // Pass the CURRENT data loaded from Firestore
          initialData: _userData,
        ),
      ),
    );

    // If data was returned (user clicked Save Changes in EditProfilePage)
    if (updatedData != null && updatedData is Map<String, dynamic>) {
      // Re-fetch data to reflect changes saved to Firestore
      _fetchUserProfile(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: PreferredSize(preferredSize: const Size.fromHeight(56), child: AppBar(backgroundColor: const Color(0xFFF94747))), body: const Center(child: CircularProgressIndicator(color: Colors.red)));
    }

    final String fullName = _userData['name'] ?? 'User Name';
    final String email = _userData['email'] ?? 'N/A';

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
          
          // --- Removed Profile Picture Section ---

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
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    // Display details using fetched data
                    _ProfileDetailRow(label: "Phone", value: _userData['phone'] ?? 'N/A'),
                    _ProfileDetailRow(label: "Location", value: _userData['location'] ?? 'N/A'),
                    _ProfileDetailRow(label: "Donations", value: (_userData['donations'] ?? 0).toString()),
                    _ProfileDetailRow(label: "Blood Group", value: _userData['blood_group'] ?? 'N/A'),
                    _ProfileDetailRow(label: "Gender", value: _userData['gender'] ?? 'N/A'),
                    _ProfileDetailRow(label: "DOB", value: _userData['date_of_birth'] ?? 'N/A'),
                    _ProfileDetailRow(label: "Age", value: (_userData['age'] ?? 0).toString()),
                    _ProfileDetailRow(label: "Last Donation", value: _userData['last_donation'] ?? 'N/A'),

                    const SizedBox(height: 30),

                    // Edit Profile Button
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
                    const SizedBox(height: 20),
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