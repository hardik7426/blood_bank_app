import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  // --- Firebase Submission Logic (CREATE) ---
  void _submitQuery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final queryData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'query_text': _queryController.text.trim(),
        'is_resolved': false, // Admin can mark this as resolved later
        'submitted_at': FieldValue.serverTimestamp(),
      };

      // CRUCIAL: Save data to the new 'user_queries' collection
      await FirebaseFirestore.instance.collection('user_queries').add(queryData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your query has been submitted successfully!'), backgroundColor: Colors.green),
      );
      
      // Clear form fields after successful submission
      _nameController.clear();
      _emailController.clear();
      _queryController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit query: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Helper widget for the custom text fields (Input Styling)
  InputDecoration _inputDecoration({required String hint, int maxLines = 1}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint: hint, maxLines: maxLines),
      validator: (v) => (v == null || v.isEmpty) ? '$hint is required' : null,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Curved Header with Title
            Container(
              width: double.infinity, height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFF94747),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              padding: const EdgeInsets.only(top: 40),
              child: Stack(children: [
                Positioned(top: 10, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),
                const Center(child: Text("About Us", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
              ]),
            ),
            const SizedBox(height: 30),
            
            // About Us Section
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0), child: Column(children: [
                const Icon(Icons.favorite, size: 80, color: Colors.red),
                const SizedBox(height: 10),
                const Text("About Us", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 10),
                const Text("Our mission is to provide top not healthcare services to ensure the well-being of our community. With a team of dedicated professionals.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                const SizedBox(height: 30),
              ])),

            // Get in touch Form Section (Toggled Red Background)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(25.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF94747),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text("Get in touch !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),
                    
                    _buildTextField(hint: "Enter your Name", controller: _nameController),
                    const SizedBox(height: 20),
                    _buildTextField(hint: "Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField(hint: "Any Query", controller: _queryController, maxLines: 5),
                    const SizedBox(height: 30),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitQuery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, foregroundColor: Colors.red,
                        minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.red)) : 
                                       const Text("Submit", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}