import 'package:flutter/material.dart';

/// Individual bank card widget
/// Based on Figma node 2064-538 (Group 271)
class BankCardWidget extends StatelessWidget {
  final String bankName;
  final String amount;
  final IconData? bankIcon;
  final VoidCallback? onTap;
  final VoidCallback? onArrowTap;

  const BankCardWidget({
    super.key,
    required this.bankName,
    required this.amount,
    this.bankIcon,
    this.onTap,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 119,
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
        ),
        child: Stack(
          children: [
            // Bank Icon at x:17, y:17 (40x40)
            Positioned(
              left: 17,
              top: 17,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  bankIcon ?? Icons.account_balance,
                  color: const Color(0xFF2C2C2C),
                  size: 24,
                ),
              ),
            ),
            // Amount at x:17, y:79
            Positioned(
              left: 17,
              top: 79,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount (Manrope 700, 14px, #C6C6C6)
                  Text(
                    amount,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFFC6C6C6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.366,
                    ),
                  ),
                  const SizedBox(height: 1),
                  // Bank Name (Poppins 500, 12px, #949494)
                  Text(
                    bankName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF949494),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon at x:97, y:100 (8x15.95, #BA9BFF)
            Positioned(
              right: 14, // 119 - 97 - 8 = 14
              bottom: 14, // 130 - 100 - 15.95 ≈ 14
              child: GestureDetector(
                onTap: onArrowTap ?? onTap,
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFBA9BFF),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
