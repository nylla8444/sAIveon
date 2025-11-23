import 'package:flutter/material.dart';
import '../pages/expense_detail_page.dart';
import '../../../../core/di/service_locator.dart';

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
  final VoidCallback? onSeeAllTap;

  const ExpensesHorizontalScrollSection({super.key, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = ServiceProvider.of(context);
    final transactionRepository = serviceProvider.transactionRepository;
    final currencyService = serviceProvider.currencyService;

    return StreamBuilder(
      stream: transactionRepository.watchAllTransactions(),
      builder: (context, snapshot) {
        final expenses = _calculateExpenseData(
          snapshot.data ?? [],
          currencyService,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191919),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Monthly',
                          style: TextStyle(
                            color: Color(0xFF949494),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ],
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
      },
    );
  }

  List<ExpenseData> _calculateExpenseData(
    List<dynamic> transactions,
    currencyService,
  ) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);

    // Define all spending categories
    final List<String> allCategories = [
      'Food & Dining',
      'Shopping',
      'Transportation',
      'Bills & Utilities',
      'Entertainment',
      'Healthcare',
      'Education',
      'Groceries',
      'Other Expenses',
    ];

    // Filter transactions for current and previous month (spending only)
    final currentMonthTransactions = transactions.where((tx) {
      final txDate = tx.date;
      return tx.type == 'send' &&
          txDate.year == currentMonth.year &&
          txDate.month == currentMonth.month;
    }).toList();

    final previousMonthTransactions = transactions.where((tx) {
      final txDate = tx.date;
      return tx.type == 'send' &&
          txDate.year == previousMonth.year &&
          txDate.month == previousMonth.month;
    }).toList();

    // Group by category and calculate totals
    final Map<String, double> currentMonthByCategory = {};
    final Map<String, double> previousMonthByCategory = {};

    for (var tx in currentMonthTransactions) {
      final category = tx.name;
      currentMonthByCategory[category] =
          (currentMonthByCategory[category] ?? 0) + tx.amount;
    }

    for (var tx in previousMonthTransactions) {
      final category = tx.name;
      previousMonthByCategory[category] =
          (previousMonthByCategory[category] ?? 0) + tx.amount;
    }

    // Create ExpenseData list for all categories
    final List<ExpenseData> expenseList = [];

    for (var category in allCategories) {
      final currentAmount = currentMonthByCategory[category] ?? 0;
      final previousAmount = previousMonthByCategory[category] ?? 0;

      // Calculate percentage change
      double percentageChange = 0;
      bool isIncrease = false;

      if (previousAmount > 0) {
        percentageChange =
            ((currentAmount - previousAmount) / previousAmount * 100).abs();
        isIncrease = currentAmount > previousAmount;
      } else if (currentAmount > 0) {
        percentageChange = 100;
        isIncrease = true;
      }

      expenseList.add(
        ExpenseData(
          category: category,
          amount: currencyService.formatWhole(currentAmount),
          percentage: '${percentageChange.toStringAsFixed(0)}%',
          isIncrease: isIncrease,
          icon: _getCategoryIcon(category),
        ),
      );
    }

    // Sort by amount (descending)
    expenseList.sort((a, b) {
      final aAmount = double.parse(a.amount.replaceAll(RegExp(r'[^\d.]'), ''));
      final bAmount = double.parse(b.amount.replaceAll(RegExp(r'[^\d.]'), ''));
      return bAmount.compareTo(aAmount);
    });

    return expenseList;
  }

  IconData _getCategoryIcon(String category) {
    final iconMap = {
      'Food & Dining': Icons.restaurant,
      'Shopping': Icons.shopping_bag,
      'Transportation': Icons.directions_car,
      'Bills & Utilities': Icons.receipt_long,
      'Entertainment': Icons.movie,
      'Healthcare': Icons.medical_services,
      'Education': Icons.school,
      'Groceries': Icons.shopping_cart,
      'Other Expenses': Icons.category,
    };
    return iconMap[category] ?? Icons.attach_money;
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
