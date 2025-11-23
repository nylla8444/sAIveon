import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../../../../core/di/service_locator.dart';

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
  final List<ScheduledPaymentEntity> payments;
  final VoidCallback? onSeeAllTap;
  final Function(ScheduledPaymentEntity)? onPaymentTap;

  const ScheduledPaymentsSection({
    super.key,
    required this.payments,
    this.onSeeAllTap,
    this.onPaymentTap,
  });

  IconData _getIconFromName(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('car') || nameLower.contains('vehicle')) {
      return Icons.directions_car;
    } else if (nameLower.contains('internet') || nameLower.contains('wifi')) {
      return Icons.wifi;
    } else if (nameLower.contains('home') ||
        nameLower.contains('rent') ||
        nameLower.contains('house')) {
      return Icons.home;
    } else if (nameLower.contains('phone') || nameLower.contains('mobile')) {
      return Icons.phone;
    } else if (nameLower.contains('electric') || nameLower.contains('power')) {
      return Icons.electric_bolt;
    } else if (nameLower.contains('water')) {
      return Icons.water_drop;
    } else if (nameLower.contains('insurance') ||
        nameLower.contains('health')) {
      return Icons.health_and_safety;
    } else {
      return Icons.payment;
    }
  }

  String _getStatusText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = ServiceProvider.of(context).currencyService;
    // Convert entities to display data
    final displayPayments = payments.map((payment) {
      return ScheduledPaymentData(
        title: payment.name,
        amount: '-${currencyService.formatWhole(payment.amount)}',
        status: _getStatusText(payment.nextPaymentDate),
        date: DateFormat('d MMM').format(payment.nextPaymentDate),
        isOverdue: _isOverdue(payment.nextPaymentDate),
        icon: _getIconFromName(payment.name),
        onTap: onPaymentTap != null ? () => onPaymentTap!(payment) : null,
      );
    }).toList();

    // Show only first 3 payments
    final displayedPayments = displayPayments.take(3).toList();

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

          // Payment items or empty state
          if (displayedPayments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No scheduled payments',
                style: TextStyle(
                  color: Color(0xFF949494),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                ),
              ),
            )
          else
            ...displayedPayments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              return Column(
                children: [
                  PaymentItem(payment: payment),
                  if (index < displayedPayments.length - 1)
                    const SizedBox(height: 9),
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
