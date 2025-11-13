import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    if (_searchController.text.toLowerCase() != _searchQuery) {
        setState(() {
            _searchQuery = _searchController.text.toLowerCase();
        });
    }
  }

  // --- CRUD Operations (Delete User Profile) ---
  void _deleteUserProfile(BuildContext context, String userId, String userName) async {
    // NOTE: For true admin deletion (Auth + Firestore), use Cloud Functions. 
    // Here we only delete the Firestore profile.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the profile for $userName?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile for $userName has been deleted.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UI Builder Methods ---

  Widget _buildTotalUsersCard({required int total}) {
    // This card remains outside the main StreamBuilder but gets its data from it.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Total Users",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group, color: Colors.blue, size: 35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.blue, size: 30),
        ),
        title: Text(
          user['name'] ?? 'N/A', 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user['email'] ?? 'N/A',
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          onPressed: () {
            _deleteUserProfile(context, userId, user['name'] ?? 'User');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "User Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Total Users Card and Search Field (Placed BEFORE the list)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Displaying a static placeholder for the total count here is difficult 
                // outside the stream, so we'll fetch and display the total inside the builder
                // but keep the search field here.
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _updateSearchQuery(), 
                  decoration: InputDecoration(
                    hintText: "Search by name or email...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => _searchController.clear())
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // --- USER LIST STREAMBUILDER (The Core) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                }
                // 2. Error State
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final allUserDocs = snapshot.data?.docs ?? [];
                
                // 3. Apply Filtering Logic Locally
                final filteredUsers = allUserDocs.where((doc) {
                    final userData = doc.data() as Map<String, dynamic>;
                    final name = userData['name']?.toLowerCase() ?? '';
                    final email = userData['email']?.toLowerCase() ?? '';
                    
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();
                
                final totalCount = allUserDocs.length;

                // 4. Update the Total Users Card UI (Placed inside builder to access totalCount)
                // We use Builder here to ensure the total count is displayed correctly
                return Builder(
                    builder: (context) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                                    child: _buildTotalUsersCard(total: totalCount),
                                ),
                                
                                // 5. Empty/List State
                                Expanded(
                                    child: filteredUsers.isEmpty
                                        ? const Center(child: Text('No users found matching your search.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                                        : ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            itemCount: filteredUsers.length,
                                            itemBuilder: (context, index) {
                                                final userData = filteredUsers[index].data() as Map<String, dynamic>;
                                                final userId = filteredUsers[index].id;
                                                return _buildUserCard(context, userData, userId);
                                            },
                                        ),
                                ),
                            ],
                        );
                    }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}