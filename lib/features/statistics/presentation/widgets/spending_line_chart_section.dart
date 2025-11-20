import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../../core/di/service_locator.dart';

enum ChartPeriod { daily, weekly, monthly }

class SpendingLineChartSection extends StatefulWidget {
  const SpendingLineChartSection({super.key});

  @override
  State<SpendingLineChartSection> createState() =>
      _SpendingLineChartSectionState();
}

class _SpendingLineChartSectionState extends State<SpendingLineChartSection> {
  ChartPeriod _selectedPeriod = ChartPeriod.daily;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPeriod() {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final now = DateTime.now();
      double targetOffset = 0;

      switch (_selectedPeriod) {
        case ChartPeriod.daily:
          // Scroll to current day of week (0-6, Mon-Sun)
          final currentDayIndex = now.weekday - 1;
          // Each day takes roughly 1/7 of the chart width
          targetOffset =
              (currentDayIndex / 7) *
              _scrollController.position.maxScrollExtent;
          break;

        case ChartPeriod.weekly:
          // Scroll to current week (last week in 7-week view)
          targetOffset = _scrollController.position.maxScrollExtent;
          break;

        case ChartPeriod.monthly:
          // Scroll to current month
          final currentMonthIndex = now.month - 1;
          const chartWidth = 1000.0;
          final itemWidth = chartWidth / 12;
          targetOffset = (currentMonthIndex * itemWidth) - 100;
          break;
      }

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Map<String, double> _calculatePeriodData(
    List<TransactionEntity> transactions,
    String type, // 'receive' for income, 'send' for spending
  ) {
    final Map<String, double> data = {};
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case ChartPeriod.daily:
        // Last 7 days (Mon-Sun of current week)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final day = startOfWeek.add(Duration(days: i));
          final dayKey = DateFormat('EEE').format(day);
          data[dayKey] = transactions
              .where(
                (t) =>
                    t.type == type &&
                    t.date.year == day.year &&
                    t.date.month == day.month &&
                    t.date.day == day.day,
              )
              .fold(0.0, (sum, t) => sum + t.amount);
        }
        break;

      case ChartPeriod.weekly:
        // Weeks in current month
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

        // Calculate number of weeks in current month
        int weekNumber = 1;
        DateTime currentWeekStart = firstDayOfMonth;

        while (currentWeekStart.isBefore(lastDayOfMonth) ||
            currentWeekStart.isAtSameMomentAs(lastDayOfMonth)) {
          final weekEnd = currentWeekStart.add(const Duration(days: 6));
          final actualWeekEnd = weekEnd.isAfter(lastDayOfMonth)
              ? lastDayOfMonth
              : weekEnd;

          final weekKey = 'W$weekNumber';
          data[weekKey] = transactions
              .where(
                (t) =>
                    t.type == type &&
                    !t.date.isBefore(currentWeekStart) &&
                    !t.date.isAfter(actualWeekEnd),
              )
              .fold(0.0, (sum, t) => sum + t.amount);

          currentWeekStart = currentWeekStart.add(const Duration(days: 7));
          weekNumber++;
        }
        break;

      case ChartPeriod.monthly:
        // All 12 months of current year
        for (int month = 1; month <= 12; month++) {
          final monthKey = DateFormat('MMM').format(DateTime(now.year, month));
          data[monthKey] = transactions
              .where(
                (t) =>
                    t.type == type &&
                    t.date.year == now.year &&
                    t.date.month == month,
              )
              .fold(0.0, (sum, t) => sum + t.amount);
        }
        break;
    }

    return data;
  }

  List<FlSpot> _convertToSpots(Map<String, double> data) {
    final entries = data.entries.toList();
    return List.generate(
      entries.length,
      (index) => FlSpot(index.toDouble(), entries[index].value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locator = ServiceProvider.of(context);

    return StreamBuilder<List<TransactionEntity>>(
      stream: locator.transactionRepository.watchAllTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: double.infinity,
            height: 223,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 2,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFA47FFA)),
            ),
          );
        }

        final transactions = snapshot.data!;
        return _buildChart(transactions);
      },
    );
  }

  Widget _buildChart(List<TransactionEntity> transactions) {
    final incomeData = _calculatePeriodData(transactions, 'receive');
    final spendingData = _calculatePeriodData(transactions, 'send');

    final incomeSpots = _convertToSpots(incomeData);
    final spendingSpots = _convertToSpots(spendingData);
    final labels = incomeData.keys.toList();

    // Calculate max value for Y axis
    final maxIncome = incomeSpots.isEmpty
        ? 0.0
        : incomeSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxSpending = spendingSpots.isEmpty
        ? 0.0
        : spendingSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxValue = [
      maxIncome,
      maxSpending,
      2500.0,
    ].reduce((a, b) => a > b ? a : b);
    final roundedMax = ((maxValue / 500).ceil() * 500).toDouble();

    // Scroll to current period after chart is built
    _scrollToCurrentPeriod();

    // Monthly period needs horizontal scroll
    if (_selectedPeriod == ChartPeriod.monthly) {
      return _buildScrollableChart(
        incomeSpots,
        spendingSpots,
        labels,
        roundedMax,
      );
    }

    return _buildStaticChart(incomeSpots, spendingSpots, labels, roundedMax);
  }

  Widget _buildStaticChart(
    List<FlSpot> incomeSpots,
    List<FlSpot> spendingSpots,
    List<String> labels,
    double maxY,
  ) {
    return Container(
      width: double.infinity,
      height: 223,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
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
          // Tabs
          Row(
            children: [
              _buildTab('Daily', ChartPeriod.daily),
              const SizedBox(width: 40),
              _buildTab('Weekly', ChartPeriod.weekly),
              const SizedBox(width: 40),
              _buildTab('Monthly', ChartPeriod.monthly),
              // Show date label for Daily view
              if (_selectedPeriod == ChartPeriod.daily) ...[
                const Spacer(),
                Text(
                  '${DateFormat('EEEE').format(DateTime.now())}, ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  style: const TextStyle(
                    color: Color(0xFF949494),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
              // Show month label for Weekly view
              if (_selectedPeriod == ChartPeriod.weekly) ...[
                const Spacer(),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: Color(0xFF949494),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Line Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  // Y-axis (left) - Dollar amounts
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(
                            color: Color(0xFF949494),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ),
                  // X-axis (bottom) - Days/Weeks/Months
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const Text('');
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              color: Color(0xFF949494),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (labels.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  // Purple line (Income)
                  if (incomeSpots.isNotEmpty)
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: const Color(0xFFBA9BFF),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFFBA9BFF),
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  // Red line (Expenses)
                  if (spendingSpots.isNotEmpty)
                    LineChartBarData(
                      spots: spendingSpots,
                      isCurved: true,
                      color: const Color(0xFFFF8282),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFFFF8282),
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableChart(
    List<FlSpot> incomeSpots,
    List<FlSpot> spendingSpots,
    List<String> labels,
    double maxY,
  ) {
    const chartWidth = 1000.0;

    return Container(
      width: double.infinity,
      height: 223,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
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
          // Tabs
          Row(
            children: [
              _buildTab('Daily', ChartPeriod.daily),
              const SizedBox(width: 40),
              _buildTab('Weekly', ChartPeriod.weekly),
              const SizedBox(width: 40),
              _buildTab('Monthly', ChartPeriod.monthly),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable Line Chart with fixed Y-axis
          Expanded(
            child: Row(
              children: [
                // Fixed Y-axis labels
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 0,
                      ), // Top padding to align with chart
                      for (int i = 5; i >= 0; i--)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '\$${(i * 500).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: const TextStyle(
                              color: Color(0xFF949494),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 22,
                      ), // Bottom padding for x-axis labels
                    ],
                  ),
                ),
                // Scrollable chart area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15, left: 15),
                      child: SizedBox(
                        width: chartWidth,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= labels.length) {
                                      return const Text('');
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        labels[index],
                                        style: const TextStyle(
                                          color: Color(0xFF949494),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: (labels.length - 1).toDouble(),
                            minY: 0,
                            maxY: maxY,
                            lineBarsData: [
                              // Purple line (Income)
                              if (incomeSpots.isNotEmpty)
                                LineChartBarData(
                                  spots: incomeSpots,
                                  isCurved: true,
                                  color: const Color(0xFFBA9BFF),
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: const Color(0xFFBA9BFF),
                                            strokeWidth: 0,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              // Red line (Expenses)
                              if (spendingSpots.isNotEmpty)
                                LineChartBarData(
                                  spots: spendingSpots,
                                  isCurved: true,
                                  color: const Color(0xFFFF8282),
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: const Color(0xFFFF8282),
                                            strokeWidth: 0,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(show: false),
                                ),
                            ],
                          ),
                        ), // Close LineChart
                      ), // Close SizedBox
                    ), // Close Padding
                  ), // Close SingleChildScrollView
                ), // Close Expanded (scrollable chart area)
              ], // Close Row children
            ), // Close Row
          ), // Close Expanded (outer)
        ], // Close Column children
      ), // Close Column
    ); // Close Container
  }

  Widget _buildTab(String text, ChartPeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _scrollToCurrentPeriod();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
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
          const SizedBox(height: 6),
          if (isSelected)
            Container(
              height: 1,
              width: text == 'Daily' ? 30 : (text == 'Weekly' ? 43 : 49),
              color: const Color(0xFFA47FFA),
            ),
        ],
      ),
    );
  }
}
