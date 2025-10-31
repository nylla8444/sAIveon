import 'package:flutter/material.dart';

class IncomeValueSection extends StatelessWidget {
  final String amount;
  final double progress; // 0.0 to 1.0
  final VoidCallback? onTap;

  const IncomeValueSection({
    super.key,
    required this.amount,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Top section with icon, label, and amount
            Row(
              children: [
                // Arrow circle icon (small)
                Container(
                  width: 22.83,
                  height: 22.83,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA9BFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 12,
                  ),
                ),

                const SizedBox(width: 12),

                // "Income" label
                const Text(
                  'Income',
                  style: TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                    height: 1.366,
                  ),
                ),

                const Spacer(),

                // Amount value
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                    height: 1.366,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Progress bar
            Stack(
              children: [
                // Background bar
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA9BFF).withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Progress bar
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA9BFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
