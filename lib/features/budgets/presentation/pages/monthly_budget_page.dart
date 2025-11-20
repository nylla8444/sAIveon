import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../../budgets/domain/entities/budget_entity.dart';

class MonthlyBudgetPage extends StatefulWidget {
  const MonthlyBudgetPage({super.key});

  @override
  State<MonthlyBudgetPage> createState() => _MonthlyBudgetPageState();
}

class _MonthlyBudgetPageState extends State<MonthlyBudgetPage> {
  final ScrollController _monthlyChartScrollController = ScrollController();

  @override
  void dispose() {
    _monthlyChartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _getMonthlyBudgetStream(currentMonth, currentYear),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final budget = snapshot.data!['budget'] as BudgetEntity;
            final spending = snapshot.data!['spending'] as double;
            final limit = budget.budgetAmount;
            final percentage = (spending / limit).clamp(0.0, 1.0);
            final percentageText = '${(percentage * 100).toInt()}%';

            // Determine color based on percentage
            Color progressColor;
            if (percentage < 0.8) {
              progressColor = const Color(0xFFA882FF); // Purple - Within budget
            } else if (percentage < 1.0) {
              progressColor = const Color(0xFFFFE282); // Yellow - Risk
            } else {
              progressColor = const Color(0xFFFF8282); // Red - Overspending
            }

            return Column(
              children: [
                // Header with back button and edit button
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Row(
                    children: [
                      CustomBackButton(
                        size: 40,
                        backgroundColor: const Color(0xFF2A2A2A),
                        iconColor: const Color(0xFFFFFFFF),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _showEditBudgetDialog(context, budget),
                        icon: const Icon(Icons.edit, color: Color(0xFFA882FF)),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Progress bar section with dynamic data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Column(
                    children: [
                      // Text above progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spend: \$${spending.toStringAsFixed(0)} / \$${limit.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF949494),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            percentageText,
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
                      const SizedBox(height: 8),
                      // Progress bar with dynamic color and percentage
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Light background
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.43),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // Progress
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: progressColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        // Monthly Budget Chart
                        _buildMonthlyBudgetChart(),

                        const SizedBox(height: 14),

                        // Last 6 Periods Chart
                        _buildLast6PeriodsChart(),

                        const SizedBox(height: 14),

                        // Expenses Donut Chart
                        _buildExpensesChart(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Stream<Map<String, dynamic>> _getMonthlyBudgetStream(
    int month,
    int year,
  ) async* {
    final locator = ServiceProvider.of(context);
    final budgetRepo = locator.budgetRepository;
    final transactionRepo = locator.transactionRepository;

    // Get or create monthly budget
    final budget = await budgetRepo.getOrCreateMonthlyBudget(month, year);

    // Calculate spending (sum of all 'send' transactions in current month)
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    final allTransactions = await transactionRepo.watchAllTransactions().first;

    double spending = 0.0;
    for (var tx in allTransactions) {
      if (!tx.isDeleted &&
          tx.type == 'send' &&
          tx.date.isAfter(startDate) &&
          tx.date.isBefore(endDate)) {
        spending += tx.amount;
      }
    }

    yield {'budget': budget, 'spending': spending};

    // Continue watching for changes
    await for (final _ in budgetRepo.watchAllBudgets()) {
      final updatedBudget = await budgetRepo.getOrCreateMonthlyBudget(
        month,
        year,
      );
      final updatedTransactions = await transactionRepo
          .watchAllTransactions()
          .first;

      double updatedSpending = 0.0;
      for (var tx in updatedTransactions) {
        if (!tx.isDeleted &&
            tx.type == 'send' &&
            tx.date.isAfter(startDate) &&
            tx.date.isBefore(endDate)) {
          updatedSpending += tx.amount;
        }
      }

      yield {'budget': updatedBudget, 'spending': updatedSpending};
    }
  }

  void _showEditBudgetDialog(BuildContext context, BudgetEntity currentBudget) {
    final locator = ServiceProvider.of(context);
    final controller = TextEditingController(
      text: currentBudget.budgetAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Edit Monthly Budget',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Budget Limit',
            labelStyle: TextStyle(color: Color(0xFF949494)),
            prefixText: '\$',
            prefixStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFA882FF)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFA882FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF949494)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newAmount = double.tryParse(controller.text);
              if (newAmount != null && newAmount > 0) {
                final budgetRepo = locator.budgetRepository;
                final updatedBudget = currentBudget.copyWith(
                  budgetAmount: newAmount,
                );
                await budgetRepo.updateBudget(updatedBudget);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFA882FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBudgetChart() {
    final locator = ServiceProvider.of(context);
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Generate months from January to current month
    final months = <String>[];
    for (int i = 1; i <= currentMonth; i++) {
      months.add(_getMonthAbbreviation(i));
    }

    return StreamBuilder<List<dynamic>>(
      stream: locator.transactionRepository.watchAllTransactions(),
      builder: (context, txSnapshot) {
        return StreamBuilder<List<dynamic>>(
          stream: locator.budgetRepository.watchAllBudgets(),
          builder: (context, budgetSnapshot) {
            // Calculate data for each month
            final List<double> incomeData = [];
            final List<double> spendingData = [];

            for (int month = 1; month <= currentMonth; month++) {
              final startDate = DateTime(currentYear, month, 1);
              final endDate = DateTime(currentYear, month + 1, 0, 23, 59, 59);

              // Calculate income and spending for this month
              double income = 0;
              double spending = 0;

              if (txSnapshot.hasData) {
                final transactions = txSnapshot.data!;
                for (var tx in transactions) {
                  if (!tx.isDeleted &&
                      tx.date.isAfter(startDate) &&
                      tx.date.isBefore(endDate)) {
                    if (tx.type == 'receive') {
                      income += tx.amount;
                    } else if (tx.type == 'send') {
                      spending += tx.amount;
                    }
                  }
                }
              }

              // Normalize to 0-1 where 1 = max value for chart scaling
              final maxValue = 2500.0;
              incomeData.add((income / maxValue).clamp(0.0, 1.0));
              spendingData.add((spending / maxValue).clamp(0.0, 1.0));
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Budget',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.366,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chart and labels area - scrollable together
                  SizedBox(
                    height: 175, // 152 (chart) + 8 (spacing) + 15 (labels)
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Y-axis labels
                        SizedBox(
                          width: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildYAxisLabel('\$2,500'),
                              _buildYAxisLabel('\$2,000'),
                              _buildYAxisLabel('\$1,500'),
                              _buildYAxisLabel('\$1,000'),
                              _buildYAxisLabel('\$500'),
                              _buildYAxisLabel('\$0'),
                              const SizedBox(
                                height: 23,
                              ), // Space for labels below
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        // Chart and labels - scrollable together
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Auto-scroll to current month after first build
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_monthlyChartScrollController.hasClients) {
                                  // Calculate scroll position to show current month
                                  // If there are many months, scroll to the end to show recent months
                                  final maxScroll =
                                      _monthlyChartScrollController
                                          .position
                                          .maxScrollExtent;
                                  if (maxScroll > 0) {
                                    _monthlyChartScrollController.animateTo(
                                      maxScroll,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                }
                              });

                              return SingleChildScrollView(
                                controller: _monthlyChartScrollController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: months.length * 50.0, // 50px per month
                                  child: Column(
                                    children: [
                                      // Chart
                                      SizedBox(
                                        height: 152,
                                        child: _InteractiveLineChart(
                                          incomeData: incomeData,
                                          spendingData: spendingData,
                                          months: months,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Month labels
                                      SizedBox(
                                        height: 15,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: months.asMap().entries.map((
                                            entry,
                                          ) {
                                            return Text(
                                              entry.value,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color:
                                                    entry.key ==
                                                        months.length - 1
                                                    ? const Color(0xFFBA9BFF)
                                                    : const Color(0xFF949494),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                height: 1.5,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Income', const Color(0xFFBA9BFF)),
                      const SizedBox(width: 16),
                      _buildLegendItem('Spending', const Color(0xFFFF8282)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLast6PeriodsChart() {
    final locator = ServiceProvider.of(context);
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Generate last 6 months (current month as last)
    final months = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(currentYear, currentMonth - i, 1);
      months.add(_getMonthAbbreviation(date.month));
    }

    return StreamBuilder<List<dynamic>>(
      stream: locator.transactionRepository.watchAllTransactions(),
      builder: (context, txSnapshot) {
        return StreamBuilder<List<dynamic>>(
          stream: locator.budgetRepository.watchAllBudgets(),
          builder: (context, budgetSnapshot) {
            // Calculate spending and budget status for last 6 months
            final List<Map<String, dynamic>> barData = [];

            for (int i = 5; i >= 0; i--) {
              final date = DateTime(currentYear, currentMonth - i, 1);
              final startDate = DateTime(date.year, date.month, 1);
              final endDate = DateTime(
                date.year,
                date.month + 1,
                0,
                23,
                59,
                59,
              );

              // Get budget for this month
              double budgetLimit = 5000; // default
              if (budgetSnapshot.hasData) {
                final budgets = budgetSnapshot.data!;
                for (var budget in budgets) {
                  if (!budget.isDeleted &&
                      budget.category == 'Monthly Overall' &&
                      budget.month == date.month &&
                      budget.year == date.year) {
                    budgetLimit = budget.budgetAmount;
                    break;
                  }
                }
              }

              // Calculate spending for this month
              double spending = 0;
              if (txSnapshot.hasData) {
                final transactions = txSnapshot.data!;
                for (var tx in transactions) {
                  if (!tx.isDeleted &&
                      tx.type == 'send' &&
                      tx.date.isAfter(startDate) &&
                      tx.date.isBefore(endDate)) {
                    spending += tx.amount;
                  }
                }
              }

              // Determine status color
              final percentage = budgetLimit > 0 ? spending / budgetLimit : 0;
              Color barColor;
              if (percentage < 0.8) {
                barColor = const Color(0xFFA882FF); // Within budget
              } else if (percentage < 1.0) {
                barColor = const Color(0xFFFFE282); // Risk
              } else {
                barColor = const Color(0xFFFF8282); // Overspending
              }

              // Normalize to 0-1 where 1 = $2500
              final maxValue = 2500.0;
              final height = (spending / maxValue).clamp(0.0, 1.0);

              barData.add({
                'height': height,
                'color': barColor,
                'value': '\$${spending.toStringAsFixed(0)}',
              });
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last 6 periods',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.366,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chart area with horizontal scroll
                  SizedBox(
                    height: 134,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Y-axis labels
                        SizedBox(
                          width: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildYAxisLabel('\$2,500'),
                              _buildYAxisLabel('\$2,000'),
                              _buildYAxisLabel('\$1,500'),
                              _buildYAxisLabel('\$1,000'),
                              _buildYAxisLabel('\$500'),
                              _buildYAxisLabel('\$0'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        // Chart bars - scrollable
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 6 * 50.0, // 6 months * 50px
                              child: _InteractiveBarChart(
                                barData: barData,
                                months: months,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // X-axis labels - scrollable
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 50),
                      const SizedBox(width: 9),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 6 * 50.0,
                            height: 15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: months.asMap().entries.map((entry) {
                                return Text(
                                  entry.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color:
                                        entry.key ==
                                            5 // Last month is highlighted
                                        ? const Color(0xFFBA9BFF)
                                        : const Color(0xFF949494),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Within', const Color(0xFFA882FF)),
                      const SizedBox(width: 16),
                      _buildLegendItem('Risk', const Color(0xFFFFE282)),
                      const SizedBox(width: 16),
                      _buildLegendItem('Overspending', const Color(0xFFFF8282)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpensesChart() {
    final locator = ServiceProvider.of(context);
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return StreamBuilder<List<dynamic>>(
      stream: locator.transactionRepository.watchAllTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 2,
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Filter spending transactions for current month and group by category name
        final allTransactions = snapshot.data!;
        final categoryTotals = <String, double>{};
        double total = 0;

        for (var tx in allTransactions) {
          if (!tx.isDeleted &&
              tx.type == 'send' &&
              tx.date.isAfter(startDate) &&
              tx.date.isBefore(endDate)) {
            // Use the transaction name directly as category
            categoryTotals[tx.name] =
                (categoryTotals[tx.name] ?? 0) + tx.amount;
            total += tx.amount;
          }
        }

        // Define category colors for all 9 spending categories
        final categoryColors = {
          'Food & Dining': const Color(0xFFFF8282), // Red
          'Shopping': const Color(0xFFA882FF), // Purple
          'Transportation': const Color(0xFF82E5E5), // Cyan
          'Bills & Utilities': const Color(0xFFFFAD5C), // Orange
          'Entertainment': const Color(0xFFFFC759), // Yellow
          'Healthcare': const Color(0xFF82FFB4), // Green
          'Education': const Color(0xFFFF82D4), // Pink
          'Groceries': const Color(0xFFB8B88F), // Beige
          'Other Expenses': const Color(0xFF949494), // Gray
        };

        // Define the order of categories (all 9 spending categories)
        final categoryOrder = [
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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expenses',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.366,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Donut chart
                  SizedBox(
                    width: 166,
                    height: 166,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(166, 166),
                          painter: _DonutChartPainter(
                            categoryTotals,
                            categoryColors,
                            categoryOrder,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                color: Color(0xFFE6E6E6),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.366,
                              ),
                            ),
                            const Text(
                              'total',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                color: Color(0xFFE6E6E6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.366,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 34),
                  // Legend - show all categories with percentages
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryOrder.map((category) {
                        final amount = categoryTotals[category] ?? 0;
                        final percentage = total > 0
                            ? (amount / total * 100).toDouble()
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildExpenseLegendItemWithPercentage(
                            category,
                            categoryColors[category] ?? const Color(0xFF949494),
                            percentage,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseLegendItemWithPercentage(
    String label,
    Color color,
    double percentage,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.366,
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildYAxisLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF949494),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFC6C6C6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.366,
          ),
        ),
      ],
    );
  }
}

// Interactive Line Chart Widget with tap detection
class _InteractiveLineChart extends StatefulWidget {
  final List<double> incomeData;
  final List<double> spendingData;
  final List<String> months;

  const _InteractiveLineChart({
    required this.incomeData,
    required this.spendingData,
    required this.months,
  });

  @override
  State<_InteractiveLineChart> createState() => _InteractiveLineChartState();
}

class _InteractiveLineChartState extends State<_InteractiveLineChart> {
  int? _selectedIndex;
  Offset? _tapPosition;

  void _handleTapDown(TapDownDetails details, Size size) {
    final localPosition = details.localPosition;

    // Calculate which data point was tapped
    final spacing = size.width / (widget.months.length + 1);

    for (int i = 0; i < widget.months.length; i++) {
      final x = spacing * (i + 1);
      final incomeY = size.height * (1 - widget.incomeData[i]);
      final spendingY = size.height * (1 - widget.spendingData[i]);

      // Check if tap is near income or spending point (within 20px radius)
      final distanceToIncome = (localPosition - Offset(x, incomeY)).distance;
      final distanceToSpending =
          (localPosition - Offset(x, spendingY)).distance;

      if (distanceToIncome < 20 || distanceToSpending < 20) {
        setState(() {
          _selectedIndex = i;
          _tapPosition = localPosition;
        });

        // Auto-hide after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _selectedIndex == i) {
            setState(() {
              _selectedIndex = null;
              _tapPosition = null;
            });
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _handleTapDown(details, constraints.biggest),
          child: Stack(
            children: [
              CustomPaint(
                size: constraints.biggest,
                painter: _MonthlyBudgetChartPainter(
                  widget.incomeData,
                  widget.spendingData,
                ),
              ),
              if (_selectedIndex != null && _tapPosition != null)
                Positioned(
                  left: _tapPosition!.dx - 60,
                  top: _tapPosition!.dy - 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFA882FF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.months[_selectedIndex!],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFD6D6D6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFBA9BFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '\$${(widget.incomeData[_selectedIndex!] * 2500).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFFBA9BFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8282),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '\$${(widget.spendingData[_selectedIndex!] * 2500).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFFFF8282),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Interactive Bar Chart Widget with tap detection
class _InteractiveBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> barData;
  final List<String> months;

  const _InteractiveBarChart({required this.barData, required this.months});

  @override
  State<_InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<_InteractiveBarChart> {
  int? _selectedIndex;
  Offset? _tapPosition;

  void _handleTapDown(TapDownDetails details, Size size) {
    final localPosition = details.localPosition;
    final barWidth = 16.0;

    for (int i = 0; i < widget.barData.length; i++) {
      final spacing = size.width / (widget.barData.length + 1);
      final centerX = spacing * (i + 1);
      final x = centerX - (barWidth / 2);
      final barHeight = size.height * (widget.barData[i]['height'] as double);

      // Check if tap is within bar bounds
      if (localPosition.dx >= x &&
          localPosition.dx <= x + barWidth &&
          localPosition.dy >= size.height - barHeight &&
          localPosition.dy <= size.height) {
        setState(() {
          _selectedIndex = i;
          _tapPosition = Offset(centerX, size.height - barHeight - 10);
        });

        // Auto-hide after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _selectedIndex == i) {
            setState(() {
              _selectedIndex = null;
              _tapPosition = null;
            });
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _handleTapDown(details, constraints.biggest),
          child: Stack(
            children: [
              CustomPaint(
                size: constraints.biggest,
                painter: _Last6PeriodsChartPainter(widget.barData),
              ),
              if (_selectedIndex != null && _tapPosition != null)
                Positioned(
                  left: _tapPosition!.dx - 40,
                  top: _tapPosition!.dy - 35,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            widget.barData[_selectedIndex!]['color'] as Color,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.months[_selectedIndex!],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFD6D6D6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.barData[_selectedIndex!]['value'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color:
                                widget.barData[_selectedIndex!]['color']
                                    as Color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for Monthly Budget chart with real data
class _MonthlyBudgetChartPainter extends CustomPainter {
  final List<double> incomeData;
  final List<double> spendingData;

  _MonthlyBudgetChartPainter(this.incomeData, this.spendingData);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    if (incomeData.isEmpty || spendingData.isEmpty) {
      return; // Nothing to draw
    }

    // Draw purple income line
    final incomePaint = Paint()
      ..color = const Color(0xFFBA9BFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final incomePath = Path();
    for (int i = 0; i < incomeData.length; i++) {
      final spacing = width / (incomeData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - incomeData[i]);
      if (i == 0) {
        incomePath.moveTo(x, y);
      } else {
        incomePath.lineTo(x, y);
      }
    }
    canvas.drawPath(incomePath, incomePaint);

    // Draw red spending line
    final spendingPaint = Paint()
      ..color = const Color(0xFFFF8282)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final spendingPath = Path();
    for (int i = 0; i < spendingData.length; i++) {
      final spacing = width / (spendingData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - spendingData[i]);
      if (i == 0) {
        spendingPath.moveTo(x, y);
      } else {
        spendingPath.lineTo(x, y);
      }
    }
    canvas.drawPath(spendingPath, spendingPaint);

    // Draw circles at data points for purple income line
    final circlePaint = Paint()
      ..color = const Color(0xFFBA9BFF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < incomeData.length; i++) {
      final spacing = width / (incomeData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - incomeData[i]);
      canvas.drawCircle(Offset(x, y), 3, circlePaint);
    }

    // Draw circles at data points for red line
    circlePaint.color = const Color(0xFFFF8282);
    for (int i = 0; i < spendingData.length; i++) {
      final spacing = width / (spendingData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - spendingData[i]);
      canvas.drawCircle(Offset(x, y), 3, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for Last 6 Periods chart with real data
class _Last6PeriodsChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> barData;

  _Last6PeriodsChartPainter(this.barData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = 16.0;

    final bars = barData.isNotEmpty
        ? barData
        : [
            {'height': 0.5, 'color': const Color(0xFFA882FF), 'value': '\$0'},
          ];

    for (int i = 0; i < bars.length; i++) {
      // Position bars to match MainAxisAlignment.spaceEvenly
      final spacing = size.width / (bars.length + 1);
      final centerX = spacing * (i + 1);
      final x = centerX - (barWidth / 2);

      final barHeight = size.height * (bars[i]['height'] as double);
      paint.color = bars[i]['color'] as Color;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for Donut chart
class _DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final Map<String, Color> categoryColors;
  final List<String> categoryOrder;

  _DonutChartPainter(
    this.categoryTotals,
    this.categoryColors,
    this.categoryOrder,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    if (categoryTotals.isEmpty) {
      // Draw a gray circle if no data
      paint.color = const Color(0xFF3A3A3A);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -90 * (3.14159 / 180),
        360 * (3.14159 / 180),
        false,
        paint,
      );
      return;
    }

    // Calculate total
    final total = categoryTotals.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );
    var startAngle = -90.0; // Start at top

    // Draw each category segment in the specified order
    for (var category in categoryOrder) {
      final value = categoryTotals[category] ?? 0;
      if (value > 0) {
        final sweepAngle = (value / total) * 360;
        paint.color = categoryColors[category] ?? const Color(0xFF949494);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle * (3.14159 / 180),
          sweepAngle * (3.14159 / 180),
          false,
          paint,
        );

        startAngle += sweepAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
