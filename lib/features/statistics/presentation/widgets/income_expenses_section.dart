import 'package:flutter/material.dart';

class IncomeExpensesSection extends StatelessWidget {
  final String incomePercentage;
  final String expensesPercentage;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpensesTap;

  const IncomeExpensesSection({
    super.key,
    required this.incomePercentage,
    required this.expensesPercentage,
    this.onIncomeTap,
    this.onExpensesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Income Card
        Expanded(
          child: _buildCard(
            label: 'Income',
            percentage: incomePercentage,
            isIncome: true,
            onTap: onIncomeTap,
          ),
        ),

        const SizedBox(width: 17),

        // Expenses Card
        Expanded(
          child: _buildCard(
            label: 'Expenses',
            percentage: expensesPercentage,
            isIncome: false,
            onTap: onExpensesTap,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String label,
    required String percentage,
    required bool isIncome,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 67,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Arrow Circle Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFFBA9BFF)
                    : const Color(0xFFFF8282),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 7),

            // Label and Percentage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    percentage,
                    style: const TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Manrope',
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
