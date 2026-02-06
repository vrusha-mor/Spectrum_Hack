import 'package:flutter/material.dart';

class AppColors {
  // NutriScan "Professional Emerald" Palette
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFF1DB98D); // Specific NutriScan Green
  static const Color black = Color(0xFF1F2937);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFE5E7EB);
  
  static const Color protein = Color(0xFFA855F7); // Purple
  static const Color carbs = Color(0xFFF59E0B); // Orange
  static const Color fats = Color(0xFFEC4899); // Pink
  static const Color fiber = Color(0xFF10B981); // Emerald
  
  static const Color progressBackground = Color(0xFFF3F4F6);
  static const Color remainingColor = Color(0xFFF97316); // Orange-ish
  
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1DB98D), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
