import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController manages the tabs and their views
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
                          onPressed: () {
                            Navigator.pop(context); // Navigate back to the dashboard
                          },
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
                  // Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.red,
                        tabs: const [
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
                  // Donated Tab Content
                  _buildHistoryList(
                    isDonated: true,
                    transactions: [
                      _HistoryEntry(date: '11/12/18', time: '5:30', id: '#43EQ', qty: '0.6 ounces', location: '123, XYZ Apt'),
                      _HistoryEntry(date: '10/01/19', time: '6:00', id: '#1A2B', qty: '0.6 ounces', location: '456, ABC Rd'),
                      _HistoryEntry(date: '05/05/20', time: '10:15', id: '#7C8D', qty: '0.6 ounces', location: '789, PQR Blvd'),
                    ],
                  ),
                  
                  // Received Tab Content
                  _buildHistoryList(
                    isDonated: false,
                    transactions: [
                      _HistoryEntry(date: '01/01/18', time: '8:00', id: '#9E0F', qty: '0.6 ounces', location: '123, XYZ Apt'),
                      _HistoryEntry(date: '06/06/19', time: '9:30', id: '#1G2H', qty: '0.6 ounces', location: '456, ABC Rd'),
                      _HistoryEntry(date: '12/12/20', time: '4:45', id: '#3I4J', qty: '0.6 ounces', location: '789, PQR Blvd'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build the list content for a tab
  Widget _buildHistoryList({required bool isDonated, required List<_HistoryEntry> transactions}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date : ${item.date} ${item.time}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Location : ${item.location}', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Qty: ${item.qty}', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(isDonated ? 'Receiver ID: ${item.id}' : 'Donor ID: ${item.id}', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      if (!isDonated)
                        TextButton(
                          onPressed: () {
                            // TODO: Implement View Details action
                          },
                          child: const Text('View Details >', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// Data model for history entries
class _HistoryEntry {
  final String date;
  final String time;
  final String id;
  final String qty;
  final String location;

  _HistoryEntry({
    required this.date,
    required this.time,
    required this.id,
    required this.qty,
    required this.location,
  });
}