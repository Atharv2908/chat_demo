import 'package:chat_demo/core/constants/app_images.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../widgets/buttons.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController  _passwordController = TextEditingController();

  final TextEditingController  _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(AppImages.logo,),
                  const SizedBox(height: 16),
                  AuthField(
                    controller: _emailController,
                    hintText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  AuthField(
                    isPassword: true,
                    controller: _passwordController,
                    hintText: 'Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            MainButton(
              title: 'Login',
              onPressed: () {
                if(_formKey.currentState!.validate()) {
                  final auth = context.read<AuthProvider>();
                  auth.login(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    context: context,
                  );
                }
              },
            ),
            SizedBox(height: 12),
            RichText(text: TextSpan(
              text: 'Don\'t have an account? ',
              style: TextStyle(color: Colors.grey.shade600),
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to the login screen
                      context.go(RouteNames.signup);
                    },
                  text: 'SignUp!',
                  style: TextStyle(
                    color: AppColors.blue500,
                    fontWeight: FontWeight.bold,
                  ),
                  // Add a gesture recognizer to handle tap on "Login"
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
