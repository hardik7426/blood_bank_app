import 'dart:convert';
import 'package:blood_bank_app/screens/auth/verify_otp_reset_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String BASE_URL = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/api'; // <-- replace

class RequestOtpPage extends StatefulWidget {
  const RequestOtpPage({super.key});

  @override
  State<RequestOtpPage> createState() => _RequestOtpPageState();
}

class _RequestOtpPageState extends State<RequestOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _info;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none));

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _info = null; });
    final email = _emailCtrl.text.trim();

    try {
      final resp = await http.post(Uri.parse('$BASE_URL/request-reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}));
      final jsonResp = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        setState(() {
          _info = 'If an account exists, a code was sent to the email. Check inbox/spam.';
        });
      } else {
        setState(() {
          _info = jsonResp['message'] ?? jsonResp['error'] ?? 'Request failed';
        });
      }
    } catch (e) {
      setState(() { _info = 'Network error: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password'), backgroundColor: Colors.red),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailCtrl,
              decoration: _dec('Enter registered email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter valid email';
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _requestOtp,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send OTP'),
          ),
          const SizedBox(height: 16),
          if (_info != null) Text(_info!, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyOtpAndResetPage()));
            },
            child: const Text('I already have OTP / Reset now', style: TextStyle(color: Colors.red)),
          ),
        ]),
      ),
    );
  }
}
