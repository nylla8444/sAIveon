import 'package:flutter/material.dart';

/// New Chat button for AI page
/// Based on Figma node 2101-1571 (Group 334)
class NewChatButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NewChatButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 275,
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFBA9BFF),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          'New Chat',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF000000),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.366,
          ),
        ),
      ),
    );
  }
}
