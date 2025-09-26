import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      // Navigate back to the previous screen (the dashboard)
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    "Messages",
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

          // Messages List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10),
              children: const [
                _MessageItem(
                  title: 'A+',
                  subtitle: "Hello, It's Blood available",
                  date: '11/12/18 5:30',
                ),
                _MessageItem(
                  title: 'B+',
                  subtitle: "Hello, It's Blood not available",
                  date: '11/12/18 5:30',
                ),
                _MessageItem(
                  title: 'RKU Blood Camp',
                  subtitle: "Hello, Your Request Approve",
                  date: '11/12/18 5:30',
                ),
                // Add more messages here
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Message List Items
class _MessageItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const _MessageItem({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Date: $date',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
        ],
      ),
    );
  }
}