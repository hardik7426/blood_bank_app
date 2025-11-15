import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedFilter = 'All Types';
  String _searchQuery = '';

  // Helper function to get color based on blood type
  Color _getBloodColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
      case 'A-':
        return Colors.red.shade600;
      case 'B+':
      case 'B-':
        return Colors.blue.shade600;
      case 'O+':
      case 'O-':
        return Colors.green.shade600;
      case 'AB+':
      case 'AB-':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // --- Filtering and Search Logic ---
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }
  
  // Method to handle removal of an item (deleting document from Firestore)
  void _removeItem(String docId, String bloodType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Inventory Removal'),
          content: Text('Are you sure you want to remove 1 unit of $bloodType from inventory?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // In a real inventory system, you would decrement a count. 
        // Here, we simulate deleting the specific unit record.
        await _firestore.collection('donation_requests').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed 1 unit of $bloodType from inventory.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
    _searchController.addListener(() {
      _updateSearchQuery(_searchController.text);
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
                
                // Total Units Stat Card Placeholder (Updated in StreamBuilder)
                // We show the search bar below the initial UI setup
              ],
            ),
          ),

          // StreamBuilder for Live Data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // TARGET: All approved donation offers (which constitute the inventory)
              stream: _firestore.collection('donation_requests').where('status', isEqualTo: 'Approved').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading inventory: ${snapshot.error}'));
                }
                
                final allUnits = snapshot.data?.docs ?? [];
                
                // 1. Apply Filtering Logic
                final filteredUnits = allUnits.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final bloodType = data['bloodGroup']?.toUpperCase() ?? '';
                  final id = doc.id.toUpperCase();
                  
                  // Filter by Type
                  bool matchesType = _selectedFilter == 'All Types' || bloodType == _selectedFilter;
                  
                  // Filter by Search Query (ID or Blood Type)
                  bool matchesQuery = bloodType.contains(_searchQuery.toUpperCase()) || id.contains(_searchQuery.toUpperCase());
                  
                  return matchesType && matchesQuery;
                }).toList();
                
                final totalUnits = allUnits.length;
                
                // 2. Build the UI using the fetched data

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Total Units Card (Dynamic Value)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildTotalUnitsCard(total: totalUnits),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips (Needs to be rebuilt inside StreamBuilder if logic relies on snapshot)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
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
                    ),
                    const SizedBox(height: 15),

                    // Inventory List (Displays filtered results)
                    Expanded(
                      child: filteredUnits.isEmpty
                          ? const Center(child: Text('No matching blood units in inventory.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredUnits.length,
                              itemBuilder: (context, index) {
                                final unit = filteredUnits[index].data() as Map<String, dynamic>;
                                final docId = filteredUnits[index].id;
                                return _buildInventoryCard(context, unit, docId);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

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

  Widget _buildInventoryCard(BuildContext context, Map<String, dynamic> item, String docId) {
    final bloodType = item['bloodGroup'] ?? 'N/A';
    final color = _getBloodColor(bloodType);
    final unitId = docId.substring(0, 8).toUpperCase(); // Use part of document ID as unit ID

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
            bloodType,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(
          "Unit ID: $unitId",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Donor: ${item['name'] ?? 'N/A'}", style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text("Collection Date: ${item['dateOfDonation'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: TextButton.icon(
          onPressed: () => _removeItem(docId, bloodType),
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