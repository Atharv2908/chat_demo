import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color? color;
  final TextAlign align;

  const HeadingText(
      this.text, {
        super.key,
        this.size = 16,
        this.weight = FontWeight.normal,
        this.color,
        this.align = TextAlign.start,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.grey.shade400,
      ),
    );
  }
}