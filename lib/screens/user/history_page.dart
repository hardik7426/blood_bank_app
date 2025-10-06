import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Helper function to build the list content for a tab
  Widget _buildHistoryList({required bool isDonated, required List<_HistoryEntry> transactions}) {
    // The list now iterates over all transactions to display the history log
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        // Dynamic title based on tab (Receiver ID for Donated, Donor ID for Received)
        final secondaryIdLabel = isDonated ? 'Receiver ID' : 'Donor ID';
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Date, Location, Qty
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${item.date} ${item.time}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Location: ${item.location}', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Qty: ${item.qty}', style: const TextStyle(color: Colors.red, fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  // Right Column: Receiver/Donor ID, Time, View Details (REMOVED)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$secondaryIdLabel: ${item.id}', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Date: ${item.date}', style: const TextStyle(color: Colors.black54, fontSize: 14)), // Displaying date on the right for spacing
                      
                      // The conditional block for "View Details >" is now removed entirely.
                      
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
    // Defines the list of dummy transactions
    final List<_HistoryEntry> donatedTransactions = [
      _HistoryEntry(date: '11/12/18', time: '5:30', id: '#43EQ', qty: '0.6 ounces', location: '123, XYZ Apt'),
      _HistoryEntry(date: '10/01/19', time: '6:00', id: '#1A2B', qty: '0.6 ounces', location: '456, ABC Rd'),
      _HistoryEntry(date: '05/05/20', time: '10:15', id: '#7C8D', qty: '0.6 ounces', location: '789, PQR Blvd'),
      _HistoryEntry(date: '12/12/20', time: '4:45', id: '#3I4J', qty: '0.6 ounces', location: '101, ABC Tower'),
      _HistoryEntry(date: '06/06/19', time: '9:30', id: '#1G2H', qty: '0.6 ounces', location: '456, ABC Rd'),
    ];
    
    final List<_HistoryEntry> receivedTransactions = [
      _HistoryEntry(date: '01/01/18', time: '8:00', id: '#9E0F', qty: '0.6 ounces', location: '123, XYZ Apt'),
      _HistoryEntry(date: '06/06/19', time: '9:30', id: '#1G2H', qty: '0.6 ounces', location: '456, ABC Rd'),
      _HistoryEntry(date: '12/12/20', time: '4:45', id: '#3I4J', qty: '0.6 ounces', location: '789, PQR Blvd'),
      _HistoryEntry(date: '10/01/19', time: '6:00', id: '#1A2B', qty: '0.6 ounces', location: '456, ABC Rd'),
      _HistoryEntry(date: '05/05/20', time: '10:15', id: '#7C8D', qty: '0.6 ounces', location: '789, PQR Blvd'),
    ];


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
                            Navigator.pop(context); 
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
                  // Tab Bar (Segmented Control Look)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.red, width: 1), // Outer red border
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.red, // Solid red background for selected tab
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.red, width: 0),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.red,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
                    transactions: donatedTransactions,
                  ),
                  
                  // Received Tab Content
                  _buildHistoryList(
                    isDonated: false,
                    transactions: receivedTransactions,
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