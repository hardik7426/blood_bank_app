import 'package:flutter/material.dart';

class ManageCampsPage extends StatefulWidget {
  const ManageCampsPage({super.key});

  @override
  State<ManageCampsPage> createState() => _ManageCampsPageState();
}

class _ManageCampsPageState extends State<ManageCampsPage> {
  final TextEditingController _searchController = TextEditingController();
  // NOTE: We must use a mutable List for _filteredCamps to modify it
  List<Map<String, dynamic>> _filteredCamps = List.from(_campData); 

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCamps);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Logic to filter the camps list based on search query
  void _filterCamps() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredCamps = List.from(_campData);
      } else {
        _filteredCamps = _campData.where((camp) {
          final name = camp['name'].toLowerCase();
          final location = camp['location'].toLowerCase();
          return name.contains(query) || location.contains(query);
        }).toList();
      }
    });
  }

  // Logic to handle deleting a camp
  void _deleteCamp(BuildContext context, String campName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the camp: $campName?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Perform the deletion logic
                setState(() {
                  _campData.removeWhere((camp) => camp['name'] == campName);
                  _filterCamps(); // Re-filter the displayed list
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$campName deleted.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(bool isTargetBased) {
    return isTargetBased ? Colors.blue.shade600 : Colors.red.shade600;
  }

  // --- UI Building ---
  
  @override
  Widget build(BuildContext context) {
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
                      hintText: "Search camps...",
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

          // Camps List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final camp = _filteredCamps[index];
                  return _buildCampCard(context, camp);
                },
                childCount: _filteredCamps.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCampCard(BuildContext context, Map<String, dynamic> camp) {
    final bool isTargetBased = camp.containsKey('target');
    final String statusValueLabel = isTargetBased ? 'Target:' : 'Collected:';
    final String statusValue =
        isTargetBased ? camp['target'].toString() : camp['collected'].toString();
    final Color statusColor = _getStatusColor(isTargetBased);

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
          child: Icon(camp['icon'], color: Colors.red, size: 30),
        ),
        title: Text(
          camp['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Location Row 
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    camp['location'],
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Date/Time Row
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${camp['date']} - ${camp['time']}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Status and Registered Count Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Registered Count
                Text(
                  'Registered: ${camp['registered']}/${camp['capacity']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                // Collected/Target Status
                Text(
                  '$statusValueLabel $statusValue units',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: statusColor),
                ),
              ],
            ),
          ],
        ),
        
        // --- DELETE BUTTON ---
        trailing: TextButton.icon(
          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
          label: const Text(
            'Delete',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _deleteCamp(context, camp['name']),
        ),
      ),
    );
  }
}

// NOTE: The sample data must be a mutable list (List<...>) if we want to delete items from it.
List<Map<String, dynamic>> _campData = [
  {
    'name': 'City Hospital Blood Drive',
    'location': 'Downtown Medical Center',
    'date': 'Dec 15, 2024',
    'time': '9:00 AM - 5:00 PM',
    'registered': 45,
    'capacity': 60,
    'collected': 32,
    'icon': Icons.local_hospital,
  },
  {
    'name': 'Corporate Blood Camp',
    'location': 'Tech Park Office Complex',
    'date': 'Dec 20, 2024',
    'time': '10:00 AM - 4:00 PM',
    'registered': 28,
    'capacity': 50,
    'target': 40,
    'icon': Icons.business,
  },
  {
    'name': 'University Blood Drive',
    'location': 'State University Campus',
    'date': 'Dec 10, 2024',
    'time': '11:00 AM - 6:00 PM',
    'registered': 75,
    'capacity': 75,
    'collected': 68,
    'icon': Icons.school,
  },
  {
    'name': 'Community Center Drive',
    'location': 'Central Community Hall',
    'date': 'Dec 25, 2024',
    'time': '8:00 AM - 3:00 PM',
    'registered': 12,
    'capacity': 40,
    'target': 30,
    'icon': Icons.home,
  },
];