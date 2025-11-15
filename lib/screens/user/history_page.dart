import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // --- Stream Helpers ---

  // Stream for donations (Users offering blood, approved by Admin)
  Stream<QuerySnapshot> _donationHistoryStream() {
    if (_userId == null) return const Stream.empty();
    return _firestore.collection('donation_requests')
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: 'Approved') // Only approved records
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream for received requests (Users asking for blood, approved by Admin)
  Stream<QuerySnapshot> _receivedHistoryStream() {
    if (_userId == null) return const Stream.empty();
    return _firestore.collection('donor_requests')
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: 'Approved') // Only approved records
        .orderBy('timestamp', descending: true)
        .snapshots();
  }


  // Helper function to build the list content for a tab
  Widget _buildHistoryList({required bool isDonated, required QuerySnapshot snapshot}) {
    final transactions = snapshot.docs;
    final secondaryIdLabel = isDonated ? 'Receiver ID' : 'Donor ID';

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          isDonated ? 'You have no confirmed donation records.' : 'You have no confirmed received records.',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final data = transactions[index].data() as Map<String, dynamic>;
        
        // Use consistent formatting for display
        final date = data['dateOfDonation'] ?? 'N/A';
        final location = data['location'] ?? (data['hospital'] ?? 'N/A');
        
        // Use document ID or a placeholder ID field
        final recordId = transactions[index].id; 
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Date, Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: $date', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Location: $location', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  // Right Column: Receiver/Donor ID, Blood Group
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$secondaryIdLabel: #${recordId.substring(0, 5).toUpperCase()}', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Blood: ${data['bloodGroup'] ?? 'N/A'}', style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: Text("Please log in to view history.")));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            // Custom Curved Header with TabBar
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFF94747),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.only(top: 40, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Positioned(
                        left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context), 
                        ),
                      ),
                      const Center(
                        child: Text(
                          "History",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Tab Bar (Segmented Control Look)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: const TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.red,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(text: "Donated"),
                          Tab(text: "Received"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Donated Tab Content (Your offers that were approved)
                  StreamBuilder<QuerySnapshot>(
                    stream: _donationHistoryStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                          return const Center(child: Text('No data found.'));
                      }
                      return _buildHistoryList(isDonated: true, snapshot: snapshot.data!);
                    },
                  ),
                  
                  // Received Tab Content (Your requests that were approved)
                  StreamBuilder<QuerySnapshot>(
                    stream: _receivedHistoryStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                          return const Center(child: Text('No data found.'));
                      }
                      return _buildHistoryList(isDonated: false, snapshot: snapshot.data!);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}