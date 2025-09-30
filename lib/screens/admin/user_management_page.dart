import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalUsersCard(total: _userData.length),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search users...",
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
            const SizedBox(height: 20),

            // User List
            Column(
              children: _userData
                  .map((user) => _buildUserCard(context, user))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Fixed Total Users Card
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
              mainAxisSize: MainAxisSize.min, // 👈 prevents overflow
              children: [
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4), // 👈 spacing
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
      margin: const EdgeInsets.only(bottom: 10),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Delete user ${user['name']}')),
            );
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
    'image': 'assets/images/user1.png'
  },
  {
    'name': 'Michael Chen',
    'email': 'michael.chen@gmail.com',
    'image': 'assets/images/user2.png'
  },
  {
    'name': 'David Rodriguez',
    'email': 'david.rodriguez@gmail.com',
    'image': 'assets/images/user3.png'
  },
  {
    'name': 'Emily Watson',
    'email': 'emily.watson@gmail.com',
    'image': 'assets/images/user4.png'
  },
  {
    'name': 'James Wilson',
    'email': 'james.wilson@gmail.com',
    'image': 'assets/images/user5.png'
  },
];
