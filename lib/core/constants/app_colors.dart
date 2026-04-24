import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //========================
  // BRAND
  //========================

  static const blue500 = Color(0xFF1565C0);
  static const gradientBlueStart = Color(0xFF1565C0);
  static const gradientBlueEnd = Color(0xFF29B6F6);
  static const profileBg = Color(0xE08EE0FF);

  //========================
  // NEUTRALS
  //========================

  static const neutral50  = Color(0xFFF3F4F6);
  static const neutral100 = Color(0xFFD1D5DB);
  static const neutral300 = Color(0xFFA1A1AA);
  static const neutral400 = Color(0xFF8686A0);
  static const neutral500 = Color(0xFF6D6D84);
  static const neutral700 = Color(0xFF4A4A62);
  static const neutral800 = Color(0xFF29314C);
  static const neutral900 = Color(0xFF2C2D3A);

  static const white = Colors.white;
  static const black = Color(0xFF292929);


  //========================
  // LIGHT THEME TOKENS
  //========================

  static const lightBackground = white;
  static const lightSurface = white;

  static const lightTextPrimary = neutral900;
  static const lightTextSecondary = neutral500;

  static const lightBorder = neutral100;
  static const lightBorderHover = neutral100;

  static const lightInputBg = Color(0x0D2C2D3A); //5%
  static const lightCardBg = white;

  //========================
  // DARK THEME TOKENS
  //========================

  static const darkBackground = black;
  static const darkSurface = neutral700;

  static const darkTextPrimary = neutral50;
  static const darkTextSecondary = neutral300;

  static const darkBorder = neutral400;
  static const darkBorderHover = neutral300;

  static const darkInputBg = Color(0x33FFFFFF); //20%
  static const darkCardBg = neutral800;
}