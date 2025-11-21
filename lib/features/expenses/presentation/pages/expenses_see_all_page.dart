import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import 'expense_detail_page.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

class ExpensesSeeAllPage extends StatefulWidget {
  const ExpensesSeeAllPage({super.key});

  @override
  State<ExpensesSeeAllPage> createState() => _ExpensesSeeAllPageState();
}

class _ExpensesSeeAllPageState extends State<ExpensesSeeAllPage> {
  TimePeriod _selectedFilter = TimePeriod.monthly;
  final TextEditingController _searchController = TextEditingController();

  // All spending categories
  final List<String> _categories = [
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

  // Category colors
  final Map<String, Color> _categoryColors = {
    'Food & Dining': Color(0xFFFF8282),
    'Shopping': Color(0xFFF982FF),
    'Transportation': Color(0xFFFFF782),
    'Bills & Utilities': Color(0xFF82FFB4),
    'Entertainment': Color(0xFFA882FF),
    'Healthcare': Color(0xFFFF82D4),
    'Education': Color(0xFF82CFFF),
    'Groceries': Color(0xFFFFC882),
    'Other Expenses': Color(0xFFD6D6D6),
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionRepository = ServiceProvider.of(
      context,
    ).transactionRepository;

    return StreamBuilder(
      stream: transactionRepository.watchAllTransactions(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];
        final expenseData = _calculateExpenseData(transactions);
        final totalSpent = expenseData.values.fold(
          0.0,
          (sum, val) => sum + val,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
                  child: Row(
                    children: [
                      CustomBackButton(
                        size: 40,
                        backgroundColor: const Color(0xFF2A2A2A),
                        iconColor: const Color(0xFFFFFFFF),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Expenses',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 19),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Color(0xFF949494),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Super AI Search',
                        hintStyle: const TextStyle(
                          color: Color(0xFF949494),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF949494),
                          size: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 19),

                // Filter tabs with underline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterTab('This Day', TimePeriod.daily),
                      _buildFilterTab('This Week', TimePeriod.weekly),
                      _buildFilterTab('This Month', TimePeriod.monthly),
                      _buildFilterTab('This Year', TimePeriod.yearly),
                    ],
                  ),
                ),

                const SizedBox(height: 33),

                // Expenses donut chart section with legend below
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      // Donut chart centered
                      Center(
                        child: SizedBox(
                          width: 166,
                          height: 166,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Colored donut chart using fl_chart
                              PieChart(
                                PieChartData(
                                  sections: expenseData.entries.map((entry) {
                                    return PieChartSectionData(
                                      color:
                                          _categoryColors[entry.key] ??
                                          Color(0xFFD6D6D6),
                                      value: entry.value > 0
                                          ? entry.value
                                          : 0.01,
                                      title: '',
                                      radius: 40,
                                    );
                                  }).toList(),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 63,
                                  startDegreeOffset: -90,
                                ),
                              ),
                              // Center text
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$${totalSpent.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Color(0xFFE6E6E6),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Manrope',
                                      height: 1.366,
                                    ),
                                  ),
                                  const Text(
                                    'total',
                                    style: TextStyle(
                                      color: Color(0xFFE6E6E6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Manrope',
                                      height: 1.366,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Legend below chart - flexible wrap layout
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: () {
                          final allCategories = expenseData.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));

                          return allCategories.map((entry) {
                            return _buildLegendItem(
                              entry.key,
                              _categoryColors[entry.key] ?? Color(0xFFD6D6D6),
                            );
                          }).toList();
                        }(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Expenses list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        ...() {
                          final previousPeriodData =
                              _calculatePreviousPeriodData(transactions);
                          final sortedCategories = expenseData.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));

                          return sortedCategories.map((entry) {
                            final category = entry.key;
                            final amount = entry.value;
                            final previousAmount =
                                previousPeriodData[category] ?? 0;

                            double percentageChange = 0;
                            bool isIncrease = false;

                            if (previousAmount > 0) {
                              percentageChange =
                                  ((amount - previousAmount) /
                                          previousAmount *
                                          100)
                                      .abs();
                              isIncrease = amount > previousAmount;
                            } else if (amount > 0) {
                              percentageChange = 100;
                              isIncrease = true;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _buildExpenseCard(
                                title: category,
                                amount: '\$${amount.toStringAsFixed(0)}',
                                percentChange:
                                    '${percentageChange.toStringAsFixed(0)}%',
                                isIncrease: isIncrease,
                                icon: _getCategoryIcon(category),
                              ),
                            );
                          }).toList();
                        }(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, double> _calculateExpenseData(List<dynamic> transactions) {
    final now = DateTime.now();
    final Map<String, double> categoryData = {};

    // Initialize all categories with 0
    for (var category in _categories) {
      categoryData[category] = 0.0;
    }

    // Filter transactions based on selected period
    final filteredTransactions = transactions.where((tx) {
      if (tx.type != 'send') return false;

      final txDate = tx.date;
      switch (_selectedFilter) {
        case TimePeriod.daily:
          return txDate.year == now.year &&
              txDate.month == now.month &&
              txDate.day == now.day;
        case TimePeriod.weekly:
          final weekAgo = now.subtract(Duration(days: 7));
          return txDate.isAfter(weekAgo) &&
              txDate.isBefore(now.add(Duration(days: 1)));
        case TimePeriod.monthly:
          return txDate.year == now.year && txDate.month == now.month;
        case TimePeriod.yearly:
          return txDate.year == now.year;
      }
    }).toList();

    // Calculate totals by category
    for (var tx in filteredTransactions) {
      final category = tx.name;
      if (_categories.contains(category)) {
        categoryData[category] = (categoryData[category] ?? 0) + tx.amount;
      }
    }

    return categoryData;
  }

  Map<String, double> _calculatePreviousPeriodData(List<dynamic> transactions) {
    final now = DateTime.now();
    final Map<String, double> categoryData = {};

    // Initialize all categories with 0
    for (var category in _categories) {
      categoryData[category] = 0.0;
    }

    // Filter transactions based on previous period
    final filteredTransactions = transactions.where((tx) {
      if (tx.type != 'send') return false;

      final txDate = tx.date;
      switch (_selectedFilter) {
        case TimePeriod.daily:
          final yesterday = now.subtract(Duration(days: 1));
          return txDate.year == yesterday.year &&
              txDate.month == yesterday.month &&
              txDate.day == yesterday.day;
        case TimePeriod.weekly:
          final twoWeeksAgo = now.subtract(Duration(days: 14));
          final weekAgo = now.subtract(Duration(days: 7));
          return txDate.isAfter(twoWeeksAgo) && txDate.isBefore(weekAgo);
        case TimePeriod.monthly:
          final lastMonth = DateTime(now.year, now.month - 1);
          return txDate.year == lastMonth.year &&
              txDate.month == lastMonth.month;
        case TimePeriod.yearly:
          return txDate.year == now.year - 1;
      }
    }).toList();

    // Calculate totals by category
    for (var tx in filteredTransactions) {
      final category = tx.name;
      if (_categories.contains(category)) {
        categoryData[category] = (categoryData[category] ?? 0) + tx.amount;
      }
    }

    return categoryData;
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

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    return _categoryColors[category] ?? const Color(0xFFD6D6D6);
  }

  Widget _buildFilterTab(String title, TimePeriod period) {
    final isSelected = _selectedFilter == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = period;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Manrope',
              height: 1.366,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(width: 63, height: 1, color: const Color(0xFFA47FFA)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD6D6D6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
            height: 1.366,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard({
    required String title,
    required String amount,
    required String percentChange,
    required bool isIncrease,
    required IconData icon,
  }) {
    final categoryColor = _getCategoryColor(title);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseDetailPage(
              category: title,
              amount: amount,
              percentage: percentChange,
              isIncrease: isIncrease,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        height: 67,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD6D6D6).withOpacity(0.05),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Icon with category color
            Positioned(
              left: 19,
              top: 17,
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ),

            // Title
            Positioned(
              left: 61,
              top: 23,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Amount
            Positioned(
              right: 23,
              top: 15,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Percent change
            Positioned(
              right: 23,
              top: 33,
              child: Row(
                children: [
                  Text(
                    percentChange,
                    style: const TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                      height: 1.366,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncrease
                        ? const Color(0xFFFF8282)
                        : const Color(0xFF8CFF82),
                    size: 10,
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
