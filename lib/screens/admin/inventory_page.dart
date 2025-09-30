import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // State variables for filtering and searching
  String _selectedFilter = 'All Types';
  final TextEditingController _searchController = TextEditingController();

  // Helper function to get color based on blood type
  Color _getBloodColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
        return Colors.red.shade400;
      case 'B+':
        return Colors.blue.shade400;
      case 'O+':
        return Colors.green.shade400;
      case 'AB+':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade600; // Fallback for unknown types
    }
  }

  // --- Filtering and Search Logic ---

  List<Map<String, String>> get _filteredInventoryData {
    String query = _searchController.text.toLowerCase();
    
    // 1. Filter by blood type
    List<Map<String, String>> filteredByType = _inventoryData.where((item) {
      if (_selectedFilter == 'All Types') {
        return true;
      }
      return item['bloodType'] == _selectedFilter;
    }).toList();

    // 2. Filter by search query (ID or blood type)
    if (query.isEmpty) {
      return filteredByType;
    }

    return filteredByType.where((item) {
      final id = item['id']!.toLowerCase();
      final bloodType = item['bloodType']!.toLowerCase();
      
      return id.contains(query) || bloodType.contains(query);
    }).toList();
  }
  
  // Method to handle removal of an item (for demonstration purposes only)
  void _removeItem(String id) {
    setState(() {
      // Find and remove the item from the sample data list
      _inventoryData.removeWhere((item) => item['id'] == id);
    });
    // In a real app, you would call a database service here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed Inventory ID: $id')),
    );
  }


  // Helper function to build the filter chip
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
        selectedColor: Colors.red,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to search field changes to trigger re-filtering
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom AppBar/Header Area
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            color: Colors.grey[100],
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button and Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Inventory",
                      style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Total Units Stat Card
                _buildTotalUnitsCard(total: _inventoryData.length), // Use dynamic count
                const SizedBox(height: 20),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Types'),
                      _buildFilterChip('A+'),
                      _buildFilterChip('B+'),
                      _buildFilterChip('O+'),
                      _buildFilterChip('AB+'),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by donor ID, blood type...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
              ],
            ),
          ),

          // Inventory List (Displays filtered results)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: _filteredInventoryData.map((item) => _buildInventoryCard(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalUnitsCard({required int total}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Container(
        height: 85,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Total Units",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            // Right side: Red Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop, color: Colors.red, size: 35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, Map<String, String> item) {
    final color = _getBloodColor(item['bloodType']!);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            item['bloodType']!,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(
          "ID: ${item['id']!}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Collected: ${item['date']!}", style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text("Volume: ${item['volume']!}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: TextButton.icon(
          onPressed: () => _removeItem(item['id']!),
          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
          label: const Text(
            'Remove',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// NOTE: This list MUST be defined outside the widget class if you want to modify it with setState.
// In a real app, this would be a list fetched from Firestore.
List<Map<String, String>> _inventoryData = [
  {'id': 'BD001234', 'bloodType': 'A+', 'date': '15 Dec 2024', 'volume': '450ml'},
  {'id': 'BD001235', 'bloodType': 'B+', 'date': '14 Dec 2024', 'volume': '450ml'},
  {'id': 'BD001236', 'bloodType': 'O+', 'date': '13 Dec 2024', 'volume': '450ml'},
  {'id': 'BD001237', 'bloodType': 'A-', 'date': '12 Dec 2024', 'volume': '450ml'},
  {'id': 'BD001238', 'bloodType': 'AB+', 'date': '11 Dec 2024', 'volume': '450ml'},
  {'id': 'BD001239', 'bloodType': 'O-', 'date': '10 Dec 2024', 'volume': '450ml'},
  {'id': 'BD001240', 'bloodType': 'B-', 'date': '09 Dec 2024', 'volume': '450ml'},
];