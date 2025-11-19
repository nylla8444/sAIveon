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
    final now = DateTime.now();
    final currentMonth = now.month;

    // Generate months from January to current month
    final months = <String>[];
    for (int i = 1; i <= currentMonth; i++) {
      months.add(_getMonthAbbreviation(i));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
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
                      const SizedBox(height: 23), // Space for labels below
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
                          final maxScroll = _monthlyChartScrollController
                              .position
                              .maxScrollExtent;
                          if (maxScroll > 0) {
                            _monthlyChartScrollController.animateTo(
                              maxScroll,
                              duration: const Duration(milliseconds: 300),
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
                                child: CustomPaint(
                                  painter: _MonthlyBudgetChartPainter(
                                    months.length,
                                  ),
                                  child: Container(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Month labels
                              SizedBox(
                                height: 15,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: months.asMap().entries.map((entry) {
                                    return Text(
                                      entry.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: entry.key == months.length - 1
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
        ],
      ),
    );
  }

  Widget _buildLast6PeriodsChart() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Generate last 6 months (current month as last)
    final months = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(currentYear, currentMonth - i, 1);
      months.add(_getMonthAbbreviation(date.month));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
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
                      child: CustomPaint(
                        painter: _Last6PeriodsChartPainter(),
                        child: Container(),
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
  }

  Widget _buildExpensesChart() {
    final locator = ServiceProvider.of(context);
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return StreamBuilder<List<dynamic>>(
      stream: locator.expenseRepository.watchAllExpenses(),
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

        // Filter expenses for current month and group by category
        final allExpenses = snapshot.data!;
        final categoryTotals = <String, double>{};
        double total = 0;

        for (var expense in allExpenses) {
          if (!expense.isDeleted &&
              expense.date.isAfter(startDate) &&
              expense.date.isBefore(endDate)) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
            total += expense.amount;
          }
        }

        // Define category colors
        final categoryColors = {
          'Shopping': const Color(0xFFFF8282),
          'Food': const Color(0xFFF982FF),
          'Groceries': const Color(0xFF82FFB4),
          'Health': const Color(0xFFA882FF),
          'Transpo': const Color(0xFFFFF782),
        };

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
                  // Legend - always show all categories
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildExpenseLegendItem(
                          'Shopping',
                          categoryColors['Shopping']!,
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseLegendItem(
                          'Food',
                          categoryColors['Food']!,
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseLegendItem(
                          'Groceries',
                          categoryColors['Groceries']!,
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseLegendItem(
                          'Health',
                          categoryColors['Health']!,
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseLegendItem(
                          'Transpo',
                          categoryColors['Transpo']!,
                        ),
                      ],
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

  Widget _buildExpenseLegendItem(String label, Color color) {
    return Row(
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
            fontFamily: 'Manrope',
            color: Color(0xFFD6D6D6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.366,
          ),
        ),
      ],
    );
  }
}

// Custom painter for Monthly Budget chart
class _MonthlyBudgetChartPainter extends CustomPainter {
  final int monthCount;

  _MonthlyBudgetChartPainter(this.monthCount);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Generate data points for available months (using sample data)
    // Normalized to 0-1 where 1 = $2500
    final budgetData = List<double>.generate(
      monthCount,
      (i) => 0.48 + (i * 0.05), // Sample increasing pattern
    );

    final spendingData = List<double>.generate(
      monthCount,
      (i) => 0.36 + (i * 0.05), // Sample increasing pattern
    );

    // Draw purple budget line
    final budgetPaint = Paint()
      ..color = const Color(0xFFBA9BFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final budgetPath = Path();
    for (int i = 0; i < budgetData.length; i++) {
      final spacing = width / (budgetData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - budgetData[i]);
      if (i == 0) {
        budgetPath.moveTo(x, y);
      } else {
        budgetPath.lineTo(x, y);
      }
    }
    canvas.drawPath(budgetPath, budgetPaint);

    // Draw red spending line
    final spendingPaint = Paint()
      ..color = const Color(0xFFFF8282)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final spendingPath = Path();
    for (int i = 0; i < spendingData.length; i++) {
      // Use spaceEvenly logic: equal spacing on both sides and between items
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

    // Draw circles at data points for purple line
    final circlePaint = Paint()
      ..color = const Color(0xFFBA9BFF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < budgetData.length; i++) {
      final spacing = width / (budgetData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - budgetData[i]);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for Last 6 Periods chart
class _Last6PeriodsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = 16.0;

    // Bar data with actual values (max $2500)
    final bars = [
      {
        'height': 0.58,
        'color': const Color(0xFFA882FF),
        'value': '\$1,450',
      }, // Jan - Within ($1450)
      {
        'height': 0.83,
        'color': const Color(0xFFFF8282),
        'value': '\$2,075',
      }, // Feb - Overspending ($2075)
      {
        'height': 0.69,
        'color': const Color(0xFFFFE282),
        'value': '\$1,725',
      }, // Mar - Risk ($1725)
      {
        'height': 0.64,
        'color': const Color(0xFFA882FF),
        'value': '\$1,600',
      }, // Apr - Within ($1600)
      {
        'height': 0.58,
        'color': const Color(0xFFA882FF),
        'value': '\$1,450',
      }, // May - Within ($1450)
      {
        'height': 0.50,
        'color': const Color(0xFFA882FF),
        'value': '\$1,250',
      }, // Jun - Within ($1250)
    ];

    for (int i = 0; i < bars.length; i++) {
      // Position bars to match MainAxisAlignment.spaceEvenly
      // Equal spacing on both sides and between all items
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for Donut chart
class _DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final Map<String, Color> categoryColors;

  _DonutChartPainter(this.categoryTotals, this.categoryColors);

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

    // Calculate total and percentages
    final total = categoryTotals.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );
    var startAngle = -90.0; // Start at top

    // Draw each category segment
    for (var entry in categoryTotals.entries) {
      final sweepAngle = (entry.value / total) * 360;
      paint.color = categoryColors[entry.key] ?? const Color(0xFF949494);

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
