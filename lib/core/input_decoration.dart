import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppInputDecoration {
  static InputDecoration create({
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFF9CA3AF),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFF6B7280),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}
