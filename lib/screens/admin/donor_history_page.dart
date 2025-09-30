import 'package:flutter/material.dart';

class DonorHistoryPage extends StatelessWidget {
  const DonorHistoryPage({super.key});

  // Helper to get color based on blood type
  Color _getBloodColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
      case 'O+':
        return Colors.red.shade700;
      case 'B+':
        return Colors.blue.shade600;
      case 'AB+':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            toolbarHeight: 70,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16.0),
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Donor History",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Header + Total Donations Card
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "View all donation records",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildTotalDonationsCard(total: _donorRecords.length),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Donor Records List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final record = _donorRecords[index];
                  return _buildDonorRecordCard(context, record);
                },
                childCount: _donorRecords.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildTotalDonationsCard({required int total}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.water_drop, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Total Donations",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorRecordCard(
      BuildContext context, Map<String, dynamic> record) {
    final bloodColor = _getBloodColor(record['bloodGroup']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: record['image'] != null
                  ? AssetImage(record['image']!) as ImageProvider
                  : null,
              child: record['image'] == null
                  ? Icon(Icons.person, color: Colors.grey.shade700)
                  : null,
            ),
            const SizedBox(width: 12),

            // Expanded main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        record['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: bloodColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          record['bloodGroup'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      Text(
                        "ID: ${record['id']}",
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(record['date'],
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                      const SizedBox(width: 10),
                      const Icon(Icons.schedule,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(record['time'],
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          record['location'],
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Volume
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                record['volume'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sample Data ---
const List<Map<String, dynamic>> _donorRecords = [
  {
    'name': 'Sarah Johnson',
    'id': '#D001247',
    'bloodGroup': 'A+',
    'date': 'Dec 15, 2024',
    'time': '10:30 AM',
    'location': 'City Hospital - Blood Bank',
    'volume': '450ml',
    'image': null,
  },
  {
    'name': 'Michael Chen',
    'id': '#D001246',
    'bloodGroup': 'O+',
    'date': 'Dec 14, 2024',
    'time': '2:15 PM',
    'location': 'Central Medical Center',
    'volume': '450ml',
    'image': null,
  },
  {
    'name': 'Emma Davis',
    'id': '#D001245',
    'bloodGroup': 'B+',
    'date': 'Dec 13, 2024',
    'time': '11:45 AM',
    'location': 'Community Health Center',
    'volume': '450ml',
    'image': null,
  },
  {
    'name': 'James Wilson',
    'id': '#D001244',
    'bloodGroup': 'AB+',
    'date': 'Dec 12, 2024',
    'time': '9:20 AM',
    'location': 'Regional Blood Center',
    'volume': '450ml',
    'image': null,
  },
  {
    'name': 'Lisa Rodriguez',
    'id': '#D001243',
    'bloodGroup': 'O+',
    'date': 'Dec 11, 2024',
    'time': '3:00 PM',
    'location': 'Metro General Hospital',
    'volume': '450ml',
    'image': null,
  },
];
