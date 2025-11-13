import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCampsPage extends StatefulWidget {
  const ManageCampsPage({super.key});

  @override
  State<ManageCampsPage> createState() => _ManageCampsPageState();
}

class _ManageCampsPageState extends State<ManageCampsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  // NOTE: In a stream builder, we don't need _filteredCamps state, as Firestore does the filtering.
  // We will use the search controller to refine the Firestore query.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // -------------------- DELETE Camp Logic --------------------
  Future<void> _deleteCamp(BuildContext context, String docId, String campName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the camp: $campName? This cannot be undone."),
          actions: [
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(child: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('available_camps').doc(docId).delete(); // CRUCIAL: DELETE
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$campName deleted successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete camp: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    return status == 'Active' ? Colors.green.shade600 : Colors.red.shade600;
  }

  // --- UI Building ---
  
  @override
  Widget build(BuildContext context) {
    // Determine the Firestore query based on the search input
    Query baseQuery = _firestore.collection('available_camps').orderBy('createdAt', descending: true);
    
    // NOTE: Filtering by name/location in Firestore requires special indexing/search techniques (like full-text search) 
    // for complex queries. For simplicity in this StreamBuilder, we'll use a basic name filter in memory.
    // If you need large-scale search, consider using Firebase Cloud Functions + Algolia.

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
                    "Manage Camps",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search camps by name or location...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Camps List using StreamBuilder (READ Operation)
          StreamBuilder<QuerySnapshot>(
            stream: baseQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator())));
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text('No camps have been created yet.'))));
              }

              // Filter data locally based on the search query
              final filteredCamps = snapshot.data!.docs.where((doc) {
                final name = doc['name']?.toLowerCase() ?? '';
                final location = doc['location']?.toLowerCase() ?? '';
                return name.contains(_searchQuery) || location.contains(_searchQuery);
              }).toList();


              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final camp = filteredCamps[index].data() as Map<String, dynamic>;
                      final docId = filteredCamps[index].id;
                      return _buildCampCard(context, camp, docId);
                    },
                    childCount: filteredCamps.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCampCard(BuildContext context, Map<String, dynamic> camp, String docId) {
    // Safely retrieve and display camp data
    final capacity = camp['capacity'] ?? 0;
    final registered = camp['currentParticipants'] ?? 0;
    final status = camp['status'] ?? 'Draft';
    final statusColor = _getStatusColor(status);
    final iconData = (camp['icon'] == 'Icons.local_hospital') ? Icons.local_hospital : Icons.event; // Placeholder icon logic

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(iconData, color: Colors.red, size: 30),
        ),
        title: Text(camp['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.black54), const SizedBox(width: 4), Flexible(child: Text(camp['location'], style: const TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis))]),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.black54), const SizedBox(width: 4), Flexible(child: Text('${camp['startDate']} - ${camp['endDate']}', style: const TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis))]),
            const SizedBox(height: 8),
            Text('Registered: $registered/$capacity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
            Text('Status: $status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: statusColor)),
          ],
        ),
        trailing: TextButton.icon(
          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
          label: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onPressed: () => _deleteCamp(context, docId, camp['name']), // DELETE logic call
        ),
      ),
    );
  }
}