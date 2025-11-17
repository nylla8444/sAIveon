import 'package:flutter/material.dart';
import '../pages/add_expense_page.dart';
import '../pages/expense_detail_page.dart';

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
  final VoidCallback? onAddExpense;

  const ExpensesHorizontalScrollSection({
    super.key,
    required this.expenses,
    this.onSeeAllTap,
    this.onAddExpense,
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
            itemCount: expenses.length + 1, // +1 for the add button
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              // Show add expense button at the end
              if (index == expenses.length) {
                return _buildAddExpenseButton(context);
              }
              return ExpenseCard(expense: expenses[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddExpenseButton(BuildContext context) {
    return GestureDetector(
      onTap:
          onAddExpense ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpensePage()),
            );
          },
      child: Container(
        width: 89,
        height: 148,
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF191919), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.add, color: Color(0xFFBA9BFF), size: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add\nExpense',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final ExpenseData expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          expense.onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseDetailPage(
                  category: expense.category,
                  amount: expense.amount,
                  percentage: expense.percentage,
                  isIncrease: expense.isIncrease,
                  icon: expense.icon,
                ),
              ),
            );
          },
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
