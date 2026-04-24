import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';
import 'otp_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() =>
      _PhoneInputScreenState();
}

class _PhoneInputScreenState
    extends State<PhoneInputScreen> {
  final controller = TextEditingController();
  final AuthService _auth = AuthService();

  bool loading = false;

  void sendOtp() async {
    setState(() => loading = true);

    await _auth.sendOtp(
      phone: "+91${controller.text.trim()}",
      onCodeSent: () {
        setState(() => loading = false);

        context.push(RouteNames.otp);
      },
      onError: (err) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Phone")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration:
              const InputDecoration(labelText: "Phone"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : sendOtp,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Send OTP"),
            )
          ],
        ),
      ),
    );
  }
}