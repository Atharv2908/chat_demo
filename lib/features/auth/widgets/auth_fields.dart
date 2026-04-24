import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthField extends StatefulWidget {
  final bool isPassword;
  final String? hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  AuthField({
    super.key,
    this.isPassword = false,
    this.hintText,
    this.controller,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,

      keyboardType: widget.isPassword
          ? TextInputType.text
          : TextInputType.emailAddress,

      decoration: InputDecoration(

        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.blue500),
        ),

        hintText: widget.hintText ?? (widget.isPassword ? 'Password' : 'Email'),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: widget.validator,

    );
  }
}
