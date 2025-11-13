import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Ensure correct path to BloodDonationPage

class CampsPage extends StatelessWidget {
  const CampsPage({super.key});

  // Helper method to submit the user's registration for the camp
  Future<void> _registerForCamp(BuildContext context, String campId, String campName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to register for a camp."), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Simple placeholder for user data (you should fetch actual user data)
    final userName = user.displayName ?? user.email ?? 'Registered User';
    final userEmail = user.email;

    try {
      // 1. Check if the user has already registered for this specific camp
      final existing = await FirebaseFirestore.instance.collection('camp_registration_requests')
          .where('userId', isEqualTo: user.uid)
          .where('campId', isEqualTo: campId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are already registered for this camp!"), backgroundColor: Colors.orange),
        );
        return;
      }

      // 2. Submit user registration request for the camp
      await FirebaseFirestore.instance.collection('camp_registration_requests').add({
        'campId': campId,
        'campName': campName,
        'userId': user.uid,
        'userName': userName,
        'userEmail': userEmail,
        'status': 'Pending',
        'registration_date': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully registered for the camp! Awaiting approval."), backgroundColor: Colors.green),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

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
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    "Camps",
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

          // Camp Event List (Dynamic Content from Firestore)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('available_camps')
                  .where('status', isEqualTo: 'Active')
                  .orderBy('startDate', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // FIX: Display helpful error if index is missing
                  final errorMessage = snapshot.error.toString().contains('requires an index')
                      ? 'Error: Query requires a Firebase index. Please check your console.'
                      : 'Error loading camps: ${snapshot.error}';
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(errorMessage, textAlign: TextAlign.center),
                  ));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No active camps have been added by the admin yet.', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54)
                    ),
                  ));
                }

                final camps = snapshot.data!.docs;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: camps.length,
                  itemBuilder: (context, index) {
                    final campData = camps[index].data() as Map<String, dynamic>;
                    final docId = camps[index].id;
                    
                    return _buildCampCard(context, docId, campData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampCard(BuildContext context, String campId, Map<String, dynamic> data) {
    // Safely retrieve data
    final currentParticipants = data['currentParticipants'] as int? ?? 0;
    final capacity = data['capacity'] as int? ?? 100;
    final capacityPercentage = capacity > 0 ? currentParticipants / capacity : 0.0;
    final startDate = data['startDate'] ?? 'N/A';
    final endDate = data['endDate'] ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder (No upload needed)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  'assets/images/slider1.png', // Placeholder image
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('Active',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? "Blood Donation Camp",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 5),
                    Text(data['location'] ?? 'Unknown Location',
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 15),

                // Date/Time Boxes
                Row(
                  children: [
                    _buildDateBox('Start Date', startDate, ''),
                    const SizedBox(width: 15),
                    _buildDateBox('End Date', endDate, ''),
                  ],
                ),
                const SizedBox(height: 15),

                // Capacity Progress Bar
                const Text('Capacity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: capacityPercentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$currentParticipants/$capacity',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                const Text('Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  data['description'] ?? 'No description provided.',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 30),

                // Register Button - CALLS FIREBASE SUBMISSION
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _registerForCamp(context, campId, data['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Register Now',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDateBox(String label, String date, String time) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black54)),
            const SizedBox(height: 3),
            Text(date,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red)),
            if (time.isNotEmpty) Text(time,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}