import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 1. Import the package
import 'package:blood_bank_app/screens/user/drawer_page.dart';
import 'package:blood_bank_app/screens/user/request_donors_page.dart';
import 'package:blood_bank_app/screens/user/blood_donation_page.dart';

class UserDashboardPage extends StatefulWidget {
  final String fullName;
  final int age;
  final String bloodGroup;

  const UserDashboardPage({
    super.key,
    required this.fullName,
    required this.age,
    required this.bloodGroup,
  });

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 2. This function handles opening the phone's dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Show an error if the call can't be made (e.g., on a tablet)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open phone dialer for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDonate = widget.age >= 18;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      drawer: DrawerPage(
        fullName: widget.fullName,
        age: widget.age,
        bloodGroup: widget.bloodGroup,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF94747),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Hello ${widget.fullName.split(' ').first}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Info cards
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            title: "Blood Group",
                            content: widget.bloodGroup,
                            color: Colors.red,
                            isBloodGroup: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _infoCard(
                            title: "Donor Status",
                            content: canDonate ? "Approved" : "Not eligible",
                            color: canDonate ? Colors.green : Colors.red,
                            isDonorStatus: true,
                            canDonate: canDonate,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestDonorsPage(),
                          ),
                        );
                      },
                      child: const Text('Request Donors', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BloodDonationPage(),
                          ),
                        );
                      },
                      child: const Text('Donate Blood', style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 24),
                    
                    // 3. The contact card is built here
                    _buildContactCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for info cards
  Widget _infoCard({
    required String title,
    required String content,
    required Color color,
    bool isBloodGroup = false,
    bool isDonorStatus = false,
    bool canDonate = false,
  }) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 10),
          if (isBloodGroup)
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.favorite, size: 80, color: Colors.red),
                Text(
                  content,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          if (isDonorStatus)
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(
                    canDonate ? Icons.check : Icons.close,
                    color: color,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 8),
                Text(content,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
        ],
      ),
    );
  }

  // Widget for the company contact card, now tappable
  Widget _buildContactCard() {
    const phoneNumber = '+919727619671';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell( // 4. This makes the card tappable
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // 5. On tap, the phone call function is called
          _makePhoneCall(phoneNumber);
        },
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.call, color: Colors.red, size: 30),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Contact",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}