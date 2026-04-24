import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class MainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  const MainButton({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gradientBlueStart,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        minimumSize: Size(double.infinity, 48),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}



