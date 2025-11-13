import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Blood Group Colors (Define globally) ---
const Map<String, Color> _bloodColors = {
  'A+': Color(0xFFF94747), 'A-': Color(0xFFF94747),
  'B+': Colors.blue, 'B-': Colors.blue,
  'AB+': Colors.purple, 'AB-': Colors.purple,
  'O+': Colors.green, 'O-': Colors.green,
};


class DonorRequestsPage extends StatefulWidget {
  const DonorRequestsPage({super.key});

  @override
  State<DonorRequestsPage> createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CRUD Operations ---
  Future<void> _updateRequestStatus(String docId, String newStatus) async {
    try {
      // TARGETS 'donor_requests' collection and updates status
      await _firestore.collection('donor_requests').doc(docId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request marked as $newStatus!"), 
                 backgroundColor: newStatus == 'Approved' ? Colors.green : Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _approveRequest(String docId) => _updateRequestStatus(docId, 'Approved');
  void _rejectRequest(String docId) => _updateRequestStatus(docId, 'Rejected');
  
  // --- Request Card Widget ---
  Widget _buildRequestCard(Map<String, dynamic> request, String docId) {
    final status = request['status'] ?? 'Pending';
    final bloodGroup = request['bloodGroup'] ?? 'N/A';
    final bloodColor = _bloodColors[bloodGroup] ?? Colors.grey;
    final isPending = status.toLowerCase() == 'pending';
    final isApproved = status == 'Approved';

    final cardColor = isPending ? const Color(0xFFFEE2E2) : Colors.white; 
    final detailTextColor = isPending ? Colors.red.shade900 : Colors.black87;

    Widget buttonRow;
    if (isPending) {
      buttonRow = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _approveRequest(docId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rejectRequest(docId),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Reject'),
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
            color: isApproved ? Colors.green : Colors.red,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bloodColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request['patientName'] ?? 'N/A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: detailTextColor)), 
                      Text("Location: ${request['location'] ?? 'N/A'}", style: TextStyle(color: detailTextColor.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                ),
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
            const SizedBox(height: 10),
            
            _buildDetailRow(Icons.phone, request['contactPhone'] ?? 'N/A', detailTextColor),
            _buildDetailRow(Icons.access_time, "Requested: ${request['timestamp'] != null ? (request['timestamp'] as Timestamp).toDate().toString().split(' ')[0] : 'N/A'}", detailTextColor),
            buttonRow,
          ],
        ),
      ),
    );
  }

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
        stream: _firestore.collection('donor_requests').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading requests: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No donor requests found.'));
          }

          final requestsList = snapshot.data!.docs;
          
          final totalRequests = requestsList.length;
          final approvedRequests = requestsList.where((doc) => doc['status'] == 'Approved').length;
          final rejectedRequests = requestsList.where((doc) => doc['status'] == 'Rejected').length;
          
          final pendingRequests = requestsList.where((doc) {
            final status = doc['status'] as String?;
            return status != null && status.toLowerCase() == 'pending';
          }).length;

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
                    const Text("Donor Requests", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: [
                          _buildStatCard("Total Requests", totalRequests.toString(), const Color(0xFFF94747), Icons.file_download),
                          const SizedBox(width: 12),
                          _buildStatCard("Pending", pendingRequests.toString(), Colors.blue, Icons.schedule),
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

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final requestData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final docId = snapshot.data!.docs[index].id;
                      return _buildRequestCard(requestData, docId);
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