import 'package:chat_demo/routes/route_names.dart';
import 'package:chat_demo/widgets/buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_fields.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

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
                    controller: _nameController,
                    hintText: 'Full Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
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
                  SizedBox(height: 12),
                  AuthField(
                    isPassword: true,
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            MainButton(
              title: 'SignUp',
              onPressed: () {
                if(_formKey.currentState!.validate()) {
                  final auth = context.read<AuthProvider>();
                  auth.signUp(
                    name: _nameController.text,
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    context: context,
                  );
                }
              },
            ),
            SizedBox(height: 12),
            RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.grey.shade600),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigate to the login screen
                        context.go(RouteNames.login);
                      },
                    text: 'Login',
                    style: TextStyle(
                      color: AppColors.blue500,
                      fontWeight: FontWeight.bold,
                    ),
                    // Add a gesture recognizer to handle tap on "Login"
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
