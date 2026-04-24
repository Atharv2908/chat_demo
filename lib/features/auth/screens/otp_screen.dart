import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/prefs_service.dart';
import '../../../routes/route_names.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final AuthService _auth = AuthService();

  bool loading = false;

  void verifyOtp() async {
    setState(() => loading = true);

    final user =
    await _auth.verifyOtp(otp: controller.text.trim());

    setState(() => loading = false);

    if (user != null) {
      await PrefsService.updateLastActive();
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: "OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : verifyOtp,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            )
          ],
        ),
      ),
    );
  }
}