import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Was Blue, now Eco Green
  static const Color primary = Color(0xFF2E7D32); 
  static const Color accent = Color(0xFF81C784); 
  static const Color background = Color(0xFFF1F8E9); // Very light green
  
  static const Color textMain = Color(0xFF1B5E20);   // Dark Green text
  static const Color textSub = Color(0xFF558B2F);
  
  static var surface;
}

class AppTextStyles {
  static TextStyle get header => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textMain
  );
  
  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.surface
  );
  
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, color: AppColors.textSub
  );
}