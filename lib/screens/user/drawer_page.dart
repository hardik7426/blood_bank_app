import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/user/messages_page.dart'; // Import the new MessagesPage

class DrawerPage extends StatelessWidget {
  final String fullName;
  final int age;
  final String bloodGroup;

  const DrawerPage({
    super.key,
    required this.fullName,
    required this.age,
    required this.bloodGroup,
  });

  // Helper method to format the name for the header (e.g., "John #123")
  String _formatName(String name) {
    if (name.isEmpty) return 'User #123';
    final firstName = name.split(' ')[0];
    return '$firstName #123';
  }

  @override
  Widget build(BuildContext context) {
    final formattedName = _formatName(fullName);
    final canDonate = age >= 18;
    final donorStatus = canDonate ? 'Approved' : 'Not Approved';
    const approvedColor = Color(0xFFE8F5E9); 

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer header matching the provided image design
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFFF94747),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(80),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back arrow button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Closes the drawer
                    },
                  ),
                  const Spacer(),
                  // Heart icon
                  const Icon(
                    Icons.favorite,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  // User's name
                  Text(
                    formattedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Donor Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: canDonate ? approvedColor.withOpacity(0.5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Donor Status : $donorStatus",
                      style: TextStyle(
                        color: canDonate ? Colors.black : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer menu items
          _buildDrawerItem(context, 'Messages', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
          }),
          _buildDrawerItem(context, 'Camp', () {}),
          _buildDrawerItem(context, 'History', () {}),
          _buildDrawerItem(context, 'Profile', () {}),
          _buildDrawerItem(context, 'Contact us', () {}),

          const Divider(),
          const SizedBox(height: 20),

          // Sign Out button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                // TODO: Implement sign out logic and navigate back to LoginPage
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                "Sign Out",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
      onTap: () {
        Navigator.pop(context); // Close the drawer before navigating
        onTap();
      },
    );
  }
}