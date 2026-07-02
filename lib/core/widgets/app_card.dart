import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final String role; // 'tu', 'koordinator', 'pengampu', 'orang_tua', 'kepsek'
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    required this.role,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double radius;
    BoxShadow? shadow;
    BoxBorder? border;

    if (role == 'tu') {
      radius = 6;
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1);
    } else if (role == 'koordinator' || role == 'kepsek') {
      radius = 8;
      shadow = BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 4,
        offset: const Offset(0, 1),
      );
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1);
    } else {
      // pengampu, orang_tua
      radius = 16;
      shadow = BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1);
    }

    final boxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: shadow != null ? [shadow] : null,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: boxDecoration,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: boxDecoration,
      child: child,
    );
  }
}
