// lib/screens/auth/verify_otp_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({Key? key}) : super(key: key);

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  // Replace with your backend endpoint
  final String _verifyOtpUrl = 'https://your-backend.example.com/api/auth/verify-otp';

  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('email')) {
      _email = args['email'] as String;
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse(_verifyOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email, 'otp': _otpController.text.trim()}),
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'OTP verified')),
          );
          // Navigate to reset password page passing some verification token or email/otp verified flag
          // Backend may return a temporary token (recommended). We'll look for 'reset_token'
          final resetToken = body['reset_token'];
          Navigator.pushReplacementNamed(
            context,
            '/reset-password',
            arguments: {'email': _email, 'reset_token': resetToken},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Invalid OTP')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String? _validateOtp(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter OTP';
    if (v.trim().length < 4) return 'OTP seems too short';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('An OTP was sent to $_email. Enter it here to verify.'),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                validator: _validateOtp,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _verifyOtp,
              child: _loading ? const CircularProgressIndicator() : const Text('Verify OTP'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // go back to email page to resend
                Navigator.pushReplacementNamed(context, '/forgot-password');
              },
              child: const Text('Resend / Change email'),
            ),
          ],
        ),
      ),
    );
  }
}