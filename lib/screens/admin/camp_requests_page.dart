import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Blood Group Colors (Define globally) ---
const Map<String, Color> _bloodColors = {
  'A+': Color(0xFFF94747), 'A-': Color(0xFFF94747),
  'B+': Colors.blue, 'B-': Colors.blue,
  'AB+': Colors.purple, 'AB-': Colors.purple,
  'O+': Colors.green, 'O-': Colors.green,
};


class CampRequestsPage extends StatefulWidget { 
  const CampRequestsPage({super.key});

  @override
  State<CampRequestsPage> createState() => _CampRequestsPageState();
}

class _CampRequestsPageState extends State<CampRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Notification Write Helper ---
  Future<void> _sendNotification(String userId, String status, String campName) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': 'Camp Registration Status',
      'body': 'Your registration for the $campName drive has been $status.',
      'timestamp': FieldValue.serverTimestamp(),
      'type': status, 
    });
  }

  // --- CRUD Operations (Approve/Reject Camp Registration) ---
  Future<void> _updateCampStatus(String docId, String newStatus, Map<String, dynamic> request) async {
    try {
      // 1. Update status in the request collection
      await _firestore.collection('camp_registration_requests').doc(docId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // 2. SEND NOTIFICATION to the user
      await _sendNotification(
        request['userId'], 
        newStatus, 
        request['campName']
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration for ${request['campName']} $newStatus!'), 
                 backgroundColor: newStatus == 'Approved' ? Colors.green : Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _handleAction(String docId, Map<String, dynamic> request, String action) {
    _updateCampStatus(docId, action, request);
  }

  // --- Request Card Widget ---
  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request, String docId) {
    final status = request['status'] ?? 'Pending';
    final campName = request['campName'] ?? 'Unknown Camp';
    final userName = request['userName'] ?? 'N/A';
    final userEmail = request['userEmail'] ?? 'N/A';
    
    final isPending = status.toLowerCase() == 'pending';
    final isApproved = status == 'Approved';

    final cardColor = isPending ? const Color(0xFFFEEEEE) : Colors.white; // Very Light Red/White
    final detailTextColor = isPending ? Colors.red.shade900 : Colors.black87;

    Widget buttonRow;
    if (isPending) {
      buttonRow = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleAction(docId, request, 'Approved'),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleAction(docId, request, 'Rejected'),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade400),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      buttonRow = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Status: ${status.toUpperCase()}',
          style: TextStyle(
            color: isApproved ? Colors.green.shade700 : Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPending ? const BorderSide(color: Color(0xFFF94747), width: 2) : BorderSide.none,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Camp Name and Icon
            Row(
              children: [
                const Icon(Icons.campaign, color: Color(0xFFF94747), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: detailTextColor)),
                      Text('User: $userName', style: TextStyle(color: detailTextColor.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ),
                // Status Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.red.shade200 : isApproved ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(color: isPending ? Colors.red.shade900 : isApproved ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Divider(height: 24),
            
            // Details
            _buildDetailRow(Icons.email, userEmail, detailTextColor),
            _buildDetailRow(Icons.date_range, "Registration Date: ${request['registration_date'] != null ? (request['registration_date'] as Timestamp).toDate().toString().split(' ')[0] : 'N/A'}", detailTextColor),
            
            buttonRow, // Action Buttons / Final Status
          ],
        ),
      ),
    );
  }

  // Helper Widget for Detail Rows (Must be included)
  Widget _buildDetailRow(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 14))),
        ],
      ),
    );
  }

  // Helper Widget for Stat Cards (Must be included)
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                Icon(icon, color: Colors.white, size: 30),
              ],
            ),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // --- Main Build Method (StreamBuilder) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('camp_registration_requests').orderBy('registration_date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading requests: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text('No camp registration requests found.'))));
          }

          final requestsList = snapshot.data!.docs;
          
          final totalRequests = requestsList.length;
          final approvedRequests = requestsList.where((doc) => doc['status'] == 'Approved').length;
          final rejectedRequests = requestsList.where((doc) => doc['status'] == 'Rejected').length;
          final pendingRequests = requestsList.where((doc) => doc['status'] == 'Pending').length; 


          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 1,
                title: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
                    const Text("Camp Requests", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Statistics Cards Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: [
                          _buildStatCard("Total", totalRequests.toString(), const Color(0xFFF94747), Icons.local_hospital),
                          const SizedBox(width: 12),
                          _buildStatCard("Pending", pendingRequests.toString(), Colors.orange, Icons.schedule),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard("Approved", approvedRequests.toString(), Colors.green, Icons.check),
                          const SizedBox(width: 12),
                          _buildStatCard("Rejected", rejectedRequests.toString(), Colors.red, Icons.close),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Requests List Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final requestData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final docId = snapshot.data!.docs[index].id;
                      return _buildRequestCard(context, requestData, docId);
                    },
                    childCount: requestsList.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}