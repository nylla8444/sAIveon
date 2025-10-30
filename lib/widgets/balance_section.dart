import 'package:flutter/material.dart';

/// Balance display section
/// Based on Figma node 2065-769 (Group 284)
class BalanceSection extends StatelessWidget {
  final String balance;

  const BalanceSection({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Balance" text - Make it bigger and more prominent
        const Text(
          'Balance',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFE6E6E6),
            fontSize: 24, // Increased from 20px
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8), // Reduced spacing
        // Balance amount - Make it even bigger
        Text(
          balance,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFBA9BFF),
            fontSize: 36, // Increased from 24px for more prominence
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
