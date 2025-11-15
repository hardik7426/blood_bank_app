import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String BASE_URL = 'https://us-central1-blood-bank-app-986a4.cloudfunctions.net/api';

class VerifyOtpAndResetPage extends StatefulWidget {
  const VerifyOtpAndResetPage({super.key});

  @override
  State<VerifyOtpAndResetPage> createState() => _VerifyOtpAndResetPageState();
}

class _VerifyOtpAndResetPageState extends State<VerifyOtpAndResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _info;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none));

  Future<void> _verifyAndReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _info = null; });

    final email = _emailCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    final newPass = _passCtrl.text.trim();

    try {
      final resp = await http.post(Uri.parse('$BASE_URL/verify-reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPass}));
      final jsonResp = jsonDecode(resp.body);
      if (resp.statusCode == 200 && jsonResp['ok'] == true) {
        setState(() { _info = 'Password updated. Please login with the new password.'; });
        // Optionally, navigate to Login Page after a short delay
      } else {
        setState(() { _info = jsonResp['message'] ?? jsonResp['error'] ?? 'Verification failed'; });
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
      appBar: AppBar(title: const Text('Verify OTP & Reset'), backgroundColor: Colors.red),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _emailCtrl, decoration: _dec('Registered email'), keyboardType: TextInputType.emailAddress, validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter valid email';
                  return null;
                }),
                const SizedBox(height: 12),
                TextFormField(controller: _otpCtrl, decoration: _dec('Enter OTP'), keyboardType: TextInputType.number, validator: (v) => (v==null||v.isEmpty)?'Enter OTP':null),
                const SizedBox(height: 12),
                TextFormField(controller: _passCtrl, decoration: _dec('New password'), obscureText: true, validator: (v) => (v==null||v.length<6)?'Min 6 chars':null),
              ]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _verifyAndReset,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify & Reset'),
            ),
            const SizedBox(height: 16),
            if (_info != null) Text(_info!, style: const TextStyle(color: Colors.black87)),
          ]),
        ),
      ),
    );
  }
}
