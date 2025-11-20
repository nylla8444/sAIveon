import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../../core/di/service_locator.dart';

enum StatsPeriod { daily, weekly, monthly, yearly }

class StatisticsChartSection extends StatefulWidget {
  const StatisticsChartSection({super.key});

  @override
  State<StatisticsChartSection> createState() => _StatisticsChartSectionState();
}

class _StatisticsChartSectionState extends State<StatisticsChartSection> {
  StatsPeriod _selectedPeriod = StatsPeriod.daily;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getPeriodLabel(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.daily:
        return 'Daily';
      case StatsPeriod.weekly:
        return 'Weekly';
      case StatsPeriod.monthly:
        return 'Monthly';
      case StatsPeriod.yearly:
        return 'Yearly';
    }
  }

  Map<String, double> _calculatePeriodData(
    List<TransactionEntity> transactions,
    String type, // 'receive' for income, 'send' for spending
  ) {
    final Map<String, double> data = {};
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case StatsPeriod.daily:
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

      case StatsPeriod.weekly:
        // Last 4-5 weeks
        final weeksToShow = 4;
        for (int i = 0; i < weeksToShow; i++) {
          final weekStart = now.subtract(
            Duration(days: (weeksToShow - 1 - i) * 7),
          );
          final weekEnd = weekStart.add(const Duration(days: 6));
          final weekKey = 'W${i + 1}';
          data[weekKey] = transactions
              .where(
                (t) =>
                    t.type == type &&
                    t.date.isAfter(
                      weekStart.subtract(const Duration(days: 1)),
                    ) &&
                    t.date.isBefore(weekEnd.add(const Duration(days: 1))),
              )
              .fold(0.0, (sum, t) => sum + t.amount);
        }
        break;

      case StatsPeriod.monthly:
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

      case StatsPeriod.yearly:
        // Last 5 years
        for (int i = 4; i >= 0; i--) {
          final year = now.year - i;
          final yearKey = year.toString();
          data[yearKey] = transactions
              .where((t) => t.type == type && t.date.year == year)
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

    return Column(
      children: [
        // Period selector tabs
        _buildPeriodSelector(),

        const SizedBox(height: 20),

        // Statistics chart container with StreamBuilder
        StreamBuilder<List<TransactionEntity>>(
          stream: locator.transactionRepository.watchAllTransactions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                width: double.infinity,
                height: 211,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFA47FFA)),
                ),
              );
            }

            final transactions = snapshot.data!;
            return _buildChartContainer(transactions);
          },
        ),
      ],
    );
  }

  Widget _buildChartContainer(List<TransactionEntity> transactions) {
    return Container(
      width: double.infinity,
      height: 211,
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Date label at top
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              DateFormat('dd MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(
                color: Color(0xFFD6D6D6),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Manrope',
                height: 1.366,
              ),
            ),
          ),

          const SizedBox(height: 11),

          // Chart area
          Expanded(child: _buildChart(transactions)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPeriodTab(StatsPeriod.daily),
          const SizedBox(width: 30),
          _buildPeriodTab(StatsPeriod.weekly),
          const SizedBox(width: 30),
          _buildPeriodTab(StatsPeriod.monthly),
          const SizedBox(width: 30),
          _buildPeriodTab(StatsPeriod.yearly),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(StatsPeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getPeriodLabel(period),
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Manrope',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          // Underline indicator
          Container(
            width:
                _getPeriodLabel(period).length *
                7.0, // Approximate width based on text
            height: 1,
            color: isSelected ? const Color(0xFFA47FFA) : Colors.transparent,
          ),
        ],
      ),
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

    // Monthly period needs horizontal scroll
    if (_selectedPeriod == StatsPeriod.monthly) {
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
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFF949494).withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
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
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: index == labels.length - 1
                          ? const Color(0xFFBA9BFF)
                          : const Color(0xFF949494),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF949494),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                );
              },
            ),
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
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          // Red line (Spending)
          if (spendingSpots.isNotEmpty)
            LineChartBarData(
              spots: spendingSpots,
              isCurved: true,
              color: const Color(0xFFFF8282),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
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
    // For monthly view, show all 12 months with horizontal scroll
    const chartWidth = 800.0; // Wide enough for 12 months

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 500,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: const Color(0xFF949494).withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
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
                    // Highlight current month
                    final now = DateTime.now();
                    final currentMonthIndex = now.month - 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: index == currentMonthIndex
                              ? const Color(0xFFBA9BFF)
                              : const Color(0xFF949494),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 500,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF949494),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    );
                  },
                ),
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
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              // Red line (Spending)
              if (spendingSpots.isNotEmpty)
                LineChartBarData(
                  spots: spendingSpots,
                  isCurved: true,
                  color: const Color(0xFFFF8282),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
