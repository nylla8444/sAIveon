import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';

class ExpenseDetailPage extends StatelessWidget {
  final String category;
  final String amount;
  final String percentage;
  final bool isIncrease;
  final IconData icon;

  const ExpenseDetailPage({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.isIncrease,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final serviceProvider = ServiceProvider.of(context);
    final transactionRepository = serviceProvider.transactionRepository;
    final currencyService = serviceProvider.currencyService;

    return StreamBuilder(
      stream: transactionRepository.watchAllTransactions(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];
        final categoryTransactions = _filterCategoryTransactions(transactions);
        final groupedTransactions = _groupTransactionsByDate(
          categoryTransactions,
          currencyService,
        );
        final chartData = _calculateMonthlyData(transactions);

        return Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button and title
                  Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 12),
                      Text(
                        '$category Expenses',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 19),

                  // Search bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFD6D6D6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Super AI Search',
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF949494),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 19),

                  // Spending chart card
                  _buildSpendingChart(chartData, currencyService),

                  const SizedBox(height: 19),

                  // Transaction history sections
                  if (groupedTransactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFF949494),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    ...groupedTransactions.entries.map((entry) {
                      return Column(
                        children: [
                          _buildTransactionSection(entry.key, entry.value),
                          const SizedBox(height: 14),
                        ],
                      );
                    }).toList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _filterCategoryTransactions(List<dynamic> transactions) {
    return transactions.where((tx) {
      return tx.type == 'send' && tx.name == category;
    }).toList();
  }

  Map<String, List<_TransactionData>> _groupTransactionsByDate(
    List<dynamic> transactions,
    currencyService,
  ) {
    final Map<String, List<_TransactionData>> grouped = {};

    for (var tx in transactions) {
      final dateStr = DateFormat('dd MMMM yyyy').format(tx.date);

      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }

      grouped[dateStr]!.add(
        _TransactionData(
          category: tx.name,
          description: tx.status,
          time: DateFormat('hh:mma').format(tx.date),
          amount: '-${currencyService.formatWhole(tx.amount)}',
          icon: icon,
        ),
      );
    }

    // Sort by date descending
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd MMMM yyyy').parse(a.key);
        final dateB = DateFormat('dd MMMM yyyy').parse(b.key);
        return dateB.compareTo(dateA);
      });

    return Map.fromEntries(sortedEntries);
  }

  Map<int, double> _calculateMonthlyData(List<dynamic> transactions) {
    final now = DateTime.now();
    final Map<int, double> monthlyData = {};

    // Initialize last 6 months with 0 (current month + 5 previous months)
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      monthlyData[month.month] = 0.0;
    }

    // Calculate spending for each month
    for (var tx in transactions) {
      if (tx.type == 'send' && tx.name == category) {
        final txMonth = tx.date.month;
        final txYear = tx.date.year;

        // Only include transactions from the last 6 months
        final monthsDiff = (now.year - txYear) * 12 + (now.month - txMonth);
        if (monthsDiff >= 0 && monthsDiff <= 5) {
          monthlyData[txMonth] = (monthlyData[txMonth] ?? 0) + tx.amount;
        }
      }
    }

    return monthlyData;
  }

  Widget _buildSpendingChart(Map<int, double> chartData, currencyService) {
    final now = DateTime.now();
    final totalSpent = chartData.values.fold(0.0, (sum, val) => sum + val);

    // Get the last 6 months data in chronological order
    final List<MapEntry<int, double>> sortedData = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      sortedData.add(MapEntry(month.month, chartData[month.month] ?? 0.0));
    }

    // Calculate max value for chart scaling
    final maxValue = sortedData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final chartMax = maxValue > 0 ? maxValue : 2500.0;

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
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.366,
              ),
              children: [
                const TextSpan(text: 'You spent '),
                TextSpan(text: currencyService.formatWhole(totalSpent)),
                const TextSpan(text: ' on '),
                TextSpan(
                  text: category,
                  style: const TextStyle(color: Color(0xFFBA9BFF)),
                ),
                const TextSpan(text: ' in six months'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chart area
          SizedBox(
            height: 152,
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
                      _buildYAxisLabel(
                        currencyService.formatWhole(chartMax * 1.0),
                      ),
                      _buildYAxisLabel(
                        currencyService.formatWhole(chartMax * 0.8),
                      ),
                      _buildYAxisLabel(
                        currencyService.formatWhole(chartMax * 0.6),
                      ),
                      _buildYAxisLabel(
                        currencyService.formatWhole(chartMax * 0.4),
                      ),
                      _buildYAxisLabel(
                        currencyService.formatWhole(chartMax * 0.2),
                      ),
                      _buildYAxisLabel('${currencyService.currencySymbol}0'),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                // Chart
                Expanded(
                  child: CustomPaint(
                    painter: _ExpenseChartPainter(
                      chartData: sortedData,
                      maxValue: chartMax,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 50),
              const SizedBox(width: 9),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final monthLabels = <Widget>[];
                    for (int i = 0; i < 6; i++) {
                      final month = DateTime(now.year, now.month - (5 - i));
                      final monthName = DateFormat('MMM').format(month);
                      final isCurrentMonth =
                          month.month == now.month && month.year == now.year;

                      monthLabels.add(
                        _buildCenteredXAxisLabel(
                          monthName,
                          constraints.maxWidth,
                          i,
                          6,
                          isHighlighted: isCurrentMonth,
                        ),
                      );
                    }

                    return SizedBox(
                      height: 15,
                      child: Stack(children: monthLabels),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildCenteredXAxisLabel(
    String text,
    double width,
    int index,
    int total, {
    bool isHighlighted = false,
  }) {
    final spacing = width / (total + 1);
    final centerX = spacing * (index + 1);

    return Positioned(
      left: centerX,
      child: Transform.translate(
        offset: const Offset(-15, 0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isHighlighted
                ? const Color(0xFFBA9BFF)
                : const Color(0xFF949494),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    String date,
    List<_TransactionData> transactions,
  ) {
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
          // Date header
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFC6C6C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFC6C6C6)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Transactions
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return Column(
              children: [
                if (index > 0) ...[
                  Container(
                    height: 1,
                    color: const Color(0xFF4F4F4F),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ],
                _buildTransactionItem(transaction),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(_TransactionData transaction) {
    return Row(
      children: [
        // Icon
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(transaction.icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 11),
        // Category and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.category,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFE6E6E6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.366,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.description,
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
        // Amount and time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.amount,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF949494),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              transaction.time,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF9E9E9E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter for expense chart
class _ExpenseChartPainter extends CustomPainter {
  final List<MapEntry<int, double>> chartData;
  final double maxValue;

  _ExpenseChartPainter({required this.chartData, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF8282)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFFF8282)
      ..style = PaintingStyle.fill;

    if (chartData.isEmpty) return;

    final path = Path();
    for (int i = 0; i < chartData.length; i++) {
      final spacing = size.width / (chartData.length + 1);
      final x = spacing * (i + 1);
      final normalizedValue = maxValue > 0
          ? chartData[i].value / maxValue
          : 0.0;
      final y = size.height * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dots at data points
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Transaction data model
class _TransactionData {
  final String category;
  final String description;
  final String time;
  final String amount;
  final IconData icon;

  _TransactionData({
    required this.category,
    required this.description,
    required this.time,
    required this.amount,
    required this.icon,
  });
}
