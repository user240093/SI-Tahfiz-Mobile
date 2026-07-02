import 'package:flutter/material.dart';
import 'text_styles.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isSmall;
  final double borderRadius;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isSmall = false,
    this.borderRadius = 8,
    this.icon,
  });

  // Factory constructor helper per role
  factory AppButton.warm({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    bool isSmall = false,
    Widget? icon,
  }) => AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        variant: variant,
        isSmall: isSmall,
        borderRadius: 999, // StadiumBorder
        icon: icon,
      );

  factory AppButton.clean({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    bool isSmall = false,
    Widget? icon,
  }) => AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        variant: variant,
        isSmall: isSmall,
        borderRadius: 8,
        icon: icon,
      );

  factory AppButton.structured({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    bool isSmall = false,
    Widget? icon,
  }) => AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        variant: variant,
        isSmall: isSmall,
        borderRadius: 6,
        icon: icon,
      );

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    Color bg;
    Color textColor;
    BorderSide? border;
    Color pressedColor;

    if (isDisabled) {
      bg = const Color(0xFFF3F4F6);
      textColor = const Color(0xFFD1D5DB);
      pressedColor = bg;
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          bg = const Color(0xFF10B981);
          textColor = Colors.white;
          pressedColor = const Color(0xFF059669);
          break;
        case AppButtonVariant.secondary:
          bg = Colors.white;
          textColor = const Color(0xFF111827);
          border = const BorderSide(color: Color(0xFFE5E7EB), width: 1);
          pressedColor = const Color(0xFFF9FAFB);
          break;
        case AppButtonVariant.danger:
          bg = const Color(0xFFEF4444);
          textColor = Colors.white;
          pressedColor = const Color(0xFFDC2626);
          break;
        case AppButtonVariant.ghost:
          bg = Colors.transparent;
          textColor = const Color(0xFF10B981);
          pressedColor = const Color(0xFFD1FAE5);
          break;
      }
    }

    final double verticalPadding = isSmall ? 8 : 12;
    final double horizontalPadding = isSmall ? 14 : 20;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: border ?? BorderSide.none,
    );

    return Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: pressedColor.withOpacity(0.4),
        highlightColor: pressedColor.withOpacity(0.2),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
