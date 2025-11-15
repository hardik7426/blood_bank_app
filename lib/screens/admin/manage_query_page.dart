// lib/screens/admin/manage_query_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageQueryPage extends StatefulWidget {
  const ManageQueryPage({super.key});

  @override
  State<ManageQueryPage> createState() => _ManageQueryPageState();
}

class _ManageQueryPageState extends State<ManageQueryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CRUD Operations (Toggle Resolution Status) ---
  Future<void> _toggleResolvedStatus(String docId, String userName, bool currentStatus) async {
    final newStatus = !currentStatus;
    try {
      await _firestore.collection('user_queries').doc(docId).update({
        'is_resolved': newStatus,
        'resolved_at': newStatus ? FieldValue.serverTimestamp() : null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Query from $userName marked as ${newStatus ? "Resolved" : "Unresolved"}'), 
                 backgroundColor: newStatus ? Colors.green : Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI Builder ---
  Widget _buildQueryCard(Map<String, dynamic> query, String docId) {
    final isResolved = query['is_resolved'] ?? false;
    final timeSubmitted = query['submitted_at'] != null 
                          ? DateFormat('MMM d, yyyy HH:mm').format((query['submitted_at'] as Timestamp).toDate()) 
                          : 'N/A';
                          
    final cardColor = isResolved ? Colors.lightGreen.shade50 : Colors.white;
    final statusColor = isResolved ? Colors.green : Colors.orange;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(isResolved ? Icons.check_circle : Icons.mail, color: statusColor, size: 30),
        title: Text(query['name'] ?? 'Guest User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(query['email'] ?? 'No Email', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(query['query_text'] ?? 'No text provided.', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Submitted: $timeSubmitted', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: TextButton(
          onPressed: () => _toggleResolvedStatus(docId, query['name'] ?? 'Guest', isResolved),
          child: Text(
            isResolved ? 'Mark Unresolved' : 'Mark Resolved',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Manage User Queries", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // TARGET: user_queries collection
        stream: _firestore.collection('user_queries').orderBy('submitted_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading queries: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No user queries found.'));
          }

          final queries = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: queries.length,
            itemBuilder: (context, index) {
              final queryData = queries[index].data() as Map<String, dynamic>;
              final docId = queries[index].id;
              return _buildQueryCard(queryData, docId);
            },
          );
        },
      ),
    );
  }
}