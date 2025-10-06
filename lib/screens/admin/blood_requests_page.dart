import 'package:flutter/material.dart';

// --- Global Data Structure (Moved inside the State for modification) ---
// Note: In a real app, this would be fetched from Firestore.
const Map<String, Color> _bloodColors = {
  'A+': Color(0xFFF94747), // Red
  'A-': Color(0xFFF94747),
  'B+': Colors.blue,
  'B-': Colors.blue,
  'AB+': Colors.purple,
  'AB-': Colors.purple,
  'O+': Colors.green,
  'O-': Colors.green,
};


class BloodRequestsPage extends StatefulWidget {
  const BloodRequestsPage({super.key});

  @override
  State<BloodRequestsPage> createState() => _BloodRequestsPageState();
}

class _BloodRequestsPageState extends State<BloodRequestsPage> {
  // Use a List of Maps that can be modified via setState
  final List<Map<String, dynamic>> _requestsData = [
    {'name': 'Sarah Johnson', 'id': '#12847', 'bloodGroup': 'A+', 'hospital': 'City General Hospital', 'time': '2 hours ago', 'units': 2, 'status': 'pending'},
    {'name': 'Michael Chen', 'id': '#12848', 'bloodGroup': 'O-', 'hospital': 'Metro Medical Center', 'time': '4 hours ago', 'units': 1, 'status': 'pending'},
    {'name': 'Emma Rodriguez', 'id': '#12849', 'bloodGroup': 'B+', 'hospital': 'Regional Hospital', 'time': '6 hours ago', 'units': 3, 'status': 'completed'},
    {'name': 'David Park', 'id': '#12850', 'bloodGroup': 'AB-', 'hospital': 'Emergency Care Unit', 'time': '1 hour ago', 'units': 4, 'status': 'pending'},
    {'name': 'Alice Smith', 'id': '#12851', 'bloodGroup': 'A-', 'hospital': 'Westside Clinic', 'time': '3 hours ago', 'units': 2, 'status': 'cancelled'},
  ];

  // --- Data Manipulation Methods ---

  void _updateRequestStatus(String requestId, String newStatus) {
    setState(() {
      final index = _requestsData.indexWhere((req) => req['id'] == requestId);
      if (index != -1) {
        _requestsData[index]['status'] = newStatus;
      }
    });
  }

  void _acceptRequest(String requestId) {
    _updateRequestStatus(requestId, 'completed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request accepted and marked as completed!")),
    );
  }

  void _cancelRequest(String requestId) {
    _updateRequestStatus(requestId, 'cancelled');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request cancelled.")),
    );
  }

  // --- Dynamic Statistics Calculation ---

  int _countByStatus(String status) {
    return _requestsData.where((req) => req['status'] == status).length;
  }

  // --- Helper Widgets ---

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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 30),
              ],
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    final bloodColor = _bloodColors[request['bloodGroup']] ?? Colors.grey;

    // Determine the button row based on status
    Widget buttonRow;
    if (status == 'completed') {
      buttonRow = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelRequest(request['id']), // Cancel logic
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'pending') {
      buttonRow = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _acceptRequest(request['id']), // Accept logic
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Accept'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelRequest(request['id']), // Cancel logic
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      );
    } else { // status == 'cancelled'
        buttonRow = const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Request Cancelled',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Blood Group Circle
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bloodColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    request['bloodGroup'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Patient ID: ${request['id']}",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Details
            _buildDetailRow(Icons.business, request['hospital']),
            _buildDetailRow(Icons.access_time, request['time']),
            _buildDetailRow(Icons.water_drop, "${request['units']} units required"),
            
            buttonRow,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Stats
    final totalRequests = _requestsData.length;
    final completedRequests = _countByStatus('completed');
    final cancelledRequests = _countByStatus('cancelled');
    final pendingRequests = totalRequests - completedRequests - cancelledRequests;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Custom AppBar
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.grey[100],
            elevation: 0,
            expandedHeight: 40.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16.0),
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Blood Requests",
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Statistics Cards Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    children: [
                      _buildStatCard("Total Requests", totalRequests.toString(), const Color(0xFFF94747), Icons.file_download),
                      const SizedBox(width: 12),
                      _buildStatCard("Pending", pendingRequests.toString(), Colors.blue, Icons.schedule), // Pending requests
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                       _buildStatCard("Completed", completedRequests.toString(), Colors.green, Icons.check),
                      const SizedBox(width: 12),
                      _buildStatCard("Cancelled", cancelledRequests.toString(), Colors.orange, Icons.close), // Cancelled requests
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
                  return _buildRequestCard(_requestsData[index]);
                },
                childCount: _requestsData.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}