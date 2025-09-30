import 'package:flutter/material.dart';
// NOTE: Assuming LoginPage is correctly imported for logout functionality
import 'package:blood_bank_app/screens/auth/login_page.dart'; 
import 'package:blood_bank_app/screens/admin/add_new_camp_page.dart'; // Import the new page

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // Function to handle logout, clears navigation stack to return to LoginPage
  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to Login Page
      (Route<dynamic> route) => false, // Clears all history
    );
  }

  // Widget for Stats Cards - CORRECTED SIGNATURE
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container styling
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Widget for Management Module items
  Widget _buildModuleItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF94747),
        title: const Text(
          "Blood Bank Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
          const SizedBox(width: 16),
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                switch (index) {
                  // CORRECTED CALLS: Only pass 4 arguments
                  case 0:
                    return _buildStatCard("Total Users", "1,247", Icons.people, Colors.blue);
                  case 1:
                    return _buildStatCard("Blood Requests", "89", Icons.bloodtype, Colors.red);
                  case 2:
                    return _buildStatCard("Blood Units", "456", Icons.local_hospital, Colors.green);
                  case 3:
                    return _buildStatCard("Active Camps", "12", Icons.event, Colors.purple);
                  default:
                    return const SizedBox.shrink();
                }
              },
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
                    onPressed: () {
                      // Navigate to AddNewCampPage
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewCampPage()));
                    },
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
            // Example of using _buildModuleItem with placeholder navigation
            _buildModuleItem(Icons.people, "User Management", "Manage registered users", () {}),
            _buildModuleItem(Icons.favorite, "Blood Donation Requests", "89 pending requests", () {}),
            _buildModuleItem(Icons.inventory, "Inventory Management", "Blood stock levels", () {}),
            _buildModuleItem(Icons.history, "Donor History", "View donation records", () {}),
            _buildModuleItem(Icons.event, "Manage Camps", "Add & manage blood camps", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewCampPage()));
            }),
            _buildModuleItem(Icons.local_hospital, "Camp Blood Requests", "Camp donation requests", () {}),

            const SizedBox(height: 30),

            // Logout Button (Duplicated, but kept separate as per your original file structure)
            Center(
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}