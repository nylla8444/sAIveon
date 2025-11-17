import 'package:flutter/material.dart';

/// Custom circular back button matching the app's design system
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const CustomBackButton({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back,
            color: iconColor ?? const Color(0xFFFFFFFF),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
