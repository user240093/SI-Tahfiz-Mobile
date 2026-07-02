import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSizeWidget buildCustomAppBar({
  required BuildContext context,
  required String role,
  bool isNested = false,
  String? title,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    // Bottom border: 1px solid #E5E7EB
    shape: const Border(
      bottom: BorderSide(
        color: Color(0xFFE5E7EB),
        width: 1.0,
      ),
    ),
    leadingWidth: isNested ? null : 180,
    leading: isNested
        ? IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
            onPressed: () => Navigator.maybePop(context),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFF10B981), size: 24),
                const SizedBox(width: 8),
                Text(
                  'SI-Tahfiz',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
    title: isNested && title != null
        ? Text(
            title.startsWith('/') ? title.split('/').last.toUpperCase() : title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          )
        : null,
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF6B7280), size: 28),
        onPressed: () {
          String route = '/$role/profil';
          if (role == 'orang_tua') {
            route = '/ortu/profil';
          } else if (role == 'pengampu') {
            route = '/pengampu/profil';
          }
          Navigator.pushNamed(context, route);
        },
      ),
      const SizedBox(width: 12),
    ],
  );
}
