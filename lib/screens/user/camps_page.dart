import 'package:flutter/material.dart';
import 'blood_donation_page.dart'; 
// Import your form page

class CampsPage extends StatelessWidget {
  const CampsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom Curved Header
          Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFFF94747),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 40),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    "Camps",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Camp Event Card (Scrollable Content)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildCampCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampCard(BuildContext context) {
    // Current dummy data
    const currentCapacity = 65;
    const maxCapacity = 100;
    final capacityPercentage = currentCapacity / maxCapacity;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  'assets/images/slider1.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('Active',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Community Blood Drive 2024",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.red, size: 16),
                    SizedBox(width: 5),
                    Text('Central Community Center, Downtown',
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 15),

                // Date/Time Boxes
                Row(
                  children: [
                    _buildDateBox('Start Date', 'Dec 15, 2024', '9:00 AM'),
                    const SizedBox(width: 15),
                    _buildDateBox('End Date', 'Dec 15, 2024', '5:00 PM'),
                  ],
                ),
                const SizedBox(height: 15),

                // Capacity Progress Bar
                const Text('Capacity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: capacityPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$currentCapacity/$maxCapacity',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                const Text('Description',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Join us for a community blood donation drive to help save lives. '
                  'Professional medical staff will be present to ensure safe donation '
                  'procedures. All blood types are welcome. Light refreshments will be provided.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 30),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to blood donation form
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BloodDonationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Register Now',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDateBox(String label, String date, String time) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black54)),
            const SizedBox(height: 3),
            Text(date,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red)),
            Text(time,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
