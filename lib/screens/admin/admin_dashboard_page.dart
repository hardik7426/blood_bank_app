import 'package:flutter/material.dart';
// NOTE: Ensure LoginPage is correctly imported elsewhere for logout functionality

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // Set AppBar properties for better visual clarity
        backgroundColor: const Color(0xFFF94747),
        title: const Text(
          "Blood Bank Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          CircleAvatar(
            // Use Icons as a fallback if the asset path is not working
            child: Icon(Icons.person, color: Color(0xFFF94747)), 
            backgroundColor: Colors.white,
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

            // Stats Cards (FIXED OVERFLOW BY ADJUSTING ASPECT RATIO)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4, // Fixed count of 4 cards
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Increasing the vertical space (making the card slightly taller)
                childAspectRatio: 1.2, 
              ),
              itemBuilder: (context, index) {
                switch (index) {
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
                  // Use pop to return to the LoginPage, assuming it's the previous route
                  Navigator.pop(context); 
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
            const SizedBox(height: 16),
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
        // Reduced vertical padding slightly to ensure content fits
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using a colored Container to mimic the icon + circle background from the image
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
            // Reduced font size slightly and margin for the overflowed text
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)), 
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
          // TODO: Implement navigation for module item
        },
      ),
    );
  }
}