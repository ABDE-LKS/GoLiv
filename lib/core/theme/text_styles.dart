import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wassali/core/theme/color_tokens.dart';

class AppTextStyles {
  // Arabic Font: Noto Kufi Arabic
  // Latin/Numbers Font: Inter
  
  static TextStyle get arabicBase => GoogleFonts.notoKufiArabic();
  static TextStyle get latinBase => GoogleFonts.inter();

  static TextStyle h1 = arabicBase.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ColorTokens.textPrimary,
  );

  static TextStyle h2 = arabicBase.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ColorTokens.textPrimary,
  );

  static TextStyle h3 = arabicBase.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ColorTokens.textPrimary,
  );

  static TextStyle bodyLarge = arabicBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle bodyMedium = arabicBase.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ColorTokens.textSecondary,
  );

  static TextStyle labelSmall = arabicBase.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: ColorTokens.textSecondary,
  );

  static TextStyle buttonLarge = arabicBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle priceLarge = latinBase.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ColorTokens.textPrimary,
  );
}


