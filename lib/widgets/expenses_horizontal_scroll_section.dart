import 'package:flutter/material.dart';

class ExpenseData {
  final String category;
  final String amount;
  final String percentage;
  final bool isIncrease; // true = red (increase), false = green (decrease)
  final IconData icon;
  final VoidCallback? onTap;

  ExpenseData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.isIncrease,
    required this.icon,
    this.onTap,
  });
}

class ExpensesHorizontalScrollSection extends StatelessWidget {
  final List<ExpenseData> expenses;
  final VoidCallback? onSeeAllTap;

  const ExpensesHorizontalScrollSection({
    super.key,
    required this.expenses,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Expenses',
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
        ),
        const SizedBox(height: 15),

        // Horizontal Scroll List
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ExpenseCard(expense: expenses[index]);
            },
          ),
        ),
      ],
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final ExpenseData expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: expense.onTap,
      child: Container(
        width: 89,
        height: 148,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon
            const SizedBox(height: 4),
            Container(
              width: 33,
              height: 33,
              decoration: const BoxDecoration(
                color: Color(0xFFE6E6E6),
                shape: BoxShape.circle,
              ),
              child: Icon(expense.icon, color: Colors.black, size: 18),
            ),
            const SizedBox(height: 4),

            // Category name
            Text(
              expense.category,
              style: const TextStyle(
                color: Color(0xFFD6D6D6),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: 'Manrope',
                height: 1.366,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 22),

            // Amount
            Text(
              expense.amount,
              style: const TextStyle(
                color: Color(0xFFB7B7B7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Manrope',
                height: 1.366,
              ),
            ),
            const SizedBox(height: 2),

            // Percentage with arrow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expense.percentage,
                  style: const TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                    height: 1.366,
                  ),
                ),
                const SizedBox(width: 3),
                // Arrow icon
                Icon(
                  expense.isIncrease
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: expense.isIncrease
                      ? const Color(0xFFFF8282) // Red for increase
                      : const Color(0xFF82FF82), // Green for decrease
                  size: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
