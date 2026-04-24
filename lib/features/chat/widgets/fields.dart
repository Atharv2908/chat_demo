import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class Fields extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  const Fields({
    super.key,
    required this.controller,
    this.hintText = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.blue500),
        ),
      ),
    );
  }
}
