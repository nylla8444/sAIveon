import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum StatsPeriod { daily, weekly, monthly, yearly }

class StatisticsChartSection extends StatefulWidget {
  final Map<StatsPeriod, List<FlSpot>> chartData;

  const StatisticsChartSection({super.key, required this.chartData});

  @override
  State<StatisticsChartSection> createState() => _StatisticsChartSectionState();
}

class _StatisticsChartSectionState extends State<StatisticsChartSection> {
  StatsPeriod _selectedPeriod = StatsPeriod.daily;

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

  List<String> _getBottomTitles() {
    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        return ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];
      case StatsPeriod.weekly:
        return ['W1', 'W2', 'W3', 'W4'];
      case StatsPeriod.monthly:
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
      case StatsPeriod.yearly:
        return ['2020', '2021', '2022', '2023', '2024'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Period selector tabs
        _buildPeriodSelector(),

        const SizedBox(height: 20),

        // Statistics chart container
        Container(
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
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '11 October 2025',
                  style: TextStyle(
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
              Expanded(child: _buildChart()),
            ],
          ),
        ),
      ],
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

  Widget _buildChart() {
    final data = widget.chartData[_selectedPeriod] ?? [];
    final bottomTitles = _getBottomTitles();

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
                if (index < 0 || index >= bottomTitles.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    bottomTitles[index],
                    style: TextStyle(
                      color: index == bottomTitles.length - 1
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
        maxX: (bottomTitles.length - 1).toDouble(),
        minY: 0,
        maxY: 2500,
        lineBarsData: [
          // Purple line
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: const Color(0xFFBA9BFF),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // Red line (slightly offset)
          LineChartBarData(
            spots: data.map((spot) {
              return FlSpot(spot.x, spot.y - 300);
            }).toList(),
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
}
