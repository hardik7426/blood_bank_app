
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF94747),
        title: const Text("Blood Bank Admin"),
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/logo.png"), // Change to admin profile image
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard("Total Users", "1,247", Icons.people, Colors.blue),
                _buildStatCard("Blood Requests", "89", Icons.bloodtype, Colors.red),
                _buildStatCard("Blood Units", "456", Icons.local_hospital, Colors.green),
                _buildStatCard("Active Camps", "12", Icons.event, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Camp"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.list_alt, color: Colors.red),
                    label: const Text("View Requests"),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Management Modules
            const Text(
              "Management Modules",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildModuleItem(Icons.people, "User Management", "Manage registered users"),
            _buildModuleItem(Icons.favorite, "Blood Donation Requests", "89 pending requests"),
            _buildModuleItem(Icons.inventory, "Inventory Management", "Blood stock levels"),
            _buildModuleItem(Icons.history, "Donor History", "View donation records"),
            _buildModuleItem(Icons.event, "Manage Camps", "Add & manage blood camps"),
            _buildModuleItem(Icons.local_hospital, "Camp Blood Requests", "Camp donation requests"),

            const SizedBox(height: 30),

            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Back to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Logout", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Stats Cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Widget for Management Module items
  Widget _buildModuleItem(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
        onTap: () {
          // TODO: Navigate to respective page
        },
      ),
    );
  }
}
