import 'package:flutter/material.dart';

class CampRequestsPage extends StatefulWidget {
  const CampRequestsPage({super.key});

  @override
  State<CampRequestsPage> createState() => _CampRequestsPageState();
}

class _CampRequestsPageState extends State<CampRequestsPage> {
  final List<Map<String, dynamic>> _campRequests = List.from(_initialCampRequests);
  int _approved = 0;
  int _rejected = 0;

  @override
  void initState() {
    super.initState();
    _updateCounts();
  }

  void _updateCounts() {
    setState(() {
      // For this UI, total should reflect all original requests, not just pending
      _approved = _campRequests.where((r) => r['status'] == 'Approved').length;
      _rejected = _campRequests.where((r) => r['status'] == 'Rejected').length;
    });
  }

  void _handleAction(String id, String action) {
    final index = _campRequests.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      setState(() {
        // We can just remove it from the pending list for this UI
        _campRequests.removeAt(index);

        // Update counts based on the action
        if (action == 'Approved') {
          _approved++;
        } else if (action == 'Rejected') {
          _rejected++;
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camp Request ID $id was $action.')),
    );
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    // IMPROVEMENT: Filter the list before building for better performance
    final pendingRequests = _campRequests.where((r) => r['status'] == 'Pending').toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.grey[100],
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Camp Requests",
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Stat Cards (Total, Approved, Rejected)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard("Pending", pendingRequests.length.toString(), const Color(0xFFF94747)),
                      const SizedBox(width: 10),
                      _buildStatCard("Approved", _approved.toString(), Colors.green),
                      const SizedBox(width: 10),
                      _buildStatCard("Rejected", _rejected.toString(), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Requests List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final request = pendingRequests[index];
                  return _buildRequestCard(context, request);
                },
                childCount: pendingRequests.length, // Use the length of the filtered list
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // Helper Widget for Stat Cards
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 90, // <-- FIX: Increased height from 80 to 90 to solve overflow
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
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

  // Helper Widget for individual Request Cards
  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Organization
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(request['icon'], color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['campName'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      request['organizer'],
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details: Date and Location
            _buildDetailRow(Icons.calendar_today, request['dateRange']),
            _buildDetailRow(Icons.location_on, request['location']),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAction(request['id'], 'Approved'),
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
                      onPressed: () => _handleAction(request['id'], 'Rejected'),
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
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Detail Rows
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ],
      ),
    );
  }
}

// --- Sample Data ---
final List<Map<String, dynamic>> _initialCampRequests = [
  {
    'id': 'C101',
    'campName': 'City Hospital',
    'organizer': 'Sarah Johnson',
    'dateRange': 'March 15, 2024 - March 17, 2024',
    'location': 'Downtown Community Center',
    'icon': Icons.local_hospital,
    'status': 'Pending',
  },
  {
    'id': 'C102',
    'campName': 'Tech University',
    'organizer': 'Student Council',
    'dateRange': 'March 20, 2024 - March 21, 2024',
    'location': 'University Main Hall',
    'icon': Icons.school,
    'status': 'Pending',
  },
  {
    'id': 'C103',
    'campName': 'Red Cross Society',
    'organizer': 'Local Chapter',
    'dateRange': 'March 12, 2024 - March 13, 2024',
    'location': 'City Park Pavilion',
    'icon': Icons.favorite,
    'status': 'Pending',
  },
  {
    'id': 'C104',
    'campName': 'TechCorp Inc.',
    'organizer': 'HR Department',
    'dateRange': 'March 25, 2024 - March 26, 2024',
    'location': 'Corporate Office Lobby',
    'icon': Icons.business,
    'status': 'Pending',
  },
];