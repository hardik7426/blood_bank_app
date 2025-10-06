import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  // These lists hold the state for the user data
  late List<Map<String, String>> _allUsers;
  late List<Map<String, String>> _filteredUsers;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the lists with the sample data when the page loads
    _allUsers = List.from(_userData);
    _filteredUsers = List.from(_allUsers);
  }

  // Function to filter users based on search query
  void _filterUsers(String query) {
    final results = _allUsers.where((user) {
      final name = user['name']!.toLowerCase();
      final email = user['email']!.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input) || email.contains(input);
    }).toList();

    setState(() {
      _filteredUsers = results;
    });
  }

  // This function handles the actual deletion from the list
  void _deleteUser(Map<String, String> userToDelete) {
    setState(() {
      _allUsers.removeWhere((user) => user['email'] == userToDelete['email']);
      _filterUsers(_searchController.text);
    });
  }

  // This function shows a confirmation dialog before deleting
  void _showDeleteConfirmation(BuildContext context, Map<String, String> user) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${user['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(user);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user['name']} has been deleted.')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTotalUsersCard(total: _allUsers.length),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    hintText: "Search by name or email...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterUsers("");
                            },
                          )
                        : null,
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
              ],
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(context, _filteredUsers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalUsersCard({required int total}) {
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

  Widget _buildUserCard(BuildContext context, Map<String, String> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: user['image'] != null
              ? AssetImage(user['image']!) as ImageProvider
              : null,
          child: user['image'] == null
              ? Icon(Icons.person, color: Colors.grey.shade700)
              : null,
        ),
        title: Text(
          user['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user['email']!,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmation(context, user);
          },
        ),
      ),
    );
  }
}

// --- Sample Data ---
const List<Map<String, String>> _userData = [
  {
    'name': 'Sarah Johnson',
    'email': 'sarah.johnson@gmail.com',
    'image': 'assets/images/logo.png'
  },
  {
    'name': 'Michael Chen',
    'email': 'michael.chen@gmail.com',
    'image': 'assets/images/logo.png'
  },
  {
    'name': 'David Rodriguez',
    'email': 'david.rodriguez@gmail.com',
    'image': 'assets/images/logo.png'
  },
  {
    'name': 'Emily Watson',
    'email': 'emily.watson@gmail.com',
    'image': 'assets/images/logo.png'
  },
  {
    'name': 'James Wilson',
    'email': 'james.wilson@gmail.com',
    'image': 'assets/images/logo.png'
  },
];
