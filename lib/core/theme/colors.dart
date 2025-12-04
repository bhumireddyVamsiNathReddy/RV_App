import 'package:flutter/material.dart';

/// Rose Gold Color Palette
class AppColors {
  // Primary Rose Gold Shades
  static const Color roseGoldPrimary = Color(0xFFB76E79);
  static const Color roseGoldLight = Color(0xFFE8B4BC);
  static const Color roseGoldDark = Color(0xFF8B4E5A);
  
  // Accent Colors
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentCream = Color(0xFFFFF8E7);
  
  // Gradients
  static const LinearGradient roseGoldGradient = LinearGradient(
    colors: [roseGoldLight, roseGoldPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFF8F0), Color(0xFFFFE8E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1F1F1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey900 = Color(0xFF212121);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey100 = Color(0xFFF5F5F5);
  
  // Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
