import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography System using Poppins (headers) and Lato (body)
class AppTypography {
  // Display - Used for large, impactful text
  static TextStyle display1 = GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static TextStyle display2 = GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static TextStyle display3 = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  // Headline - Main page headers
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  
  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle h5 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle h6 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  // Body - Main content text
  static TextStyle bodyLarge = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static TextStyle bodySmall = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  // Label - Buttons, chips, labels
  static TextStyle labelLarge = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall = GoogleFonts.lato(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  // Button
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
  );
  
  // Caption
  static TextStyle caption = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  // Overline
  static TextStyle overline = GoogleFonts.lato(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
}
