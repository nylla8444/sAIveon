import 'package:flutter/material.dart';

class ScheduledPaymentData {
  final String title;
  final String amount;
  final String status;
  final String date;
  final bool isOverdue;
  final IconData icon;
  final VoidCallback? onTap;

  ScheduledPaymentData({
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
    this.isOverdue = false,
    required this.icon,
    this.onTap,
  });
}

class ScheduledPaymentsSection extends StatelessWidget {
  final List<ScheduledPaymentData> payments;
  final VoidCallback? onSeeAllTap;

  const ScheduledPaymentsSection({
    super.key,
    required this.payments,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scheduled Payments',
                style: TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
              GestureDetector(
                onTap: onSeeAllTap,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFFC6C6C6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Manrope',
                    height: 1.366,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payment items
          ...payments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return Column(
              children: [
                PaymentItem(payment: payment),
                if (index < payments.length - 1) const SizedBox(height: 9),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class PaymentItem extends StatelessWidget {
  final ScheduledPaymentData payment;

  const PaymentItem({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: payment.onTap,
      child: Container(
        height: 67,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD6D6D6).withValues(alpha: 0.05),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Icon at (15, 22) - dark circle with white icon
            Positioned(
              left: 15,
              top: 22,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD6D6D6).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(payment.icon, color: Colors.white, size: 12),
              ),
            ),

            // Title at (48, 17)
            Positioned(
              left: 48,
              top: 17,
              child: Text(
                payment.title,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Status at (48, 33)
            Positioned(
              left: 48,
              top: 33,
              child: Text(
                payment.status,
                style: TextStyle(
                  color: payment.isOverdue
                      ? const Color(0xFFFF8282)
                      : const Color(0xFFADACAC),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Amount - right aligned
            Positioned(
              right: 52,
              top: 18,
              child: Text(
                payment.amount,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Date - right aligned
            Positioned(
              right: 52,
              top: 35,
              child: Text(
                payment.date,
                style: const TextStyle(
                  color: Color(0xFFC6C6C6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Arrow - rightmost
            Positioned(
              right: 10,
              top: 20,
              child: GestureDetector(
                onTap: payment.onTap,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFD6D6D6),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
