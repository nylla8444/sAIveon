import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartPeriod { daily, weekly, monthly }

class SpendingLineChartSection extends StatefulWidget {
  final Map<ChartPeriod, List<FlSpot>> chartData;

  const SpendingLineChartSection({super.key, required this.chartData});

  @override
  State<SpendingLineChartSection> createState() =>
      _SpendingLineChartSectionState();
}

class _SpendingLineChartSectionState extends State<SpendingLineChartSection> {
  ChartPeriod _selectedPeriod = ChartPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final currentData = widget.chartData[_selectedPeriod] ?? [];

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
                  // X-axis (bottom) - Days of week
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thur',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: Color(0xFF949494),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          );
                        }
                        return const Text('');
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
                maxX: 6,
                minY: 0,
                maxY: 2500,
                lineBarsData: [
                  // Purple line (Income)
                  LineChartBarData(
                    spots: currentData,
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
                  LineChartBarData(
                    spots: currentData.map((spot) {
                      return FlSpot(
                        spot.x,
                        spot.y - 300,
                      ); // Offset for expenses
                    }).toList(),
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

  Widget _buildTab(String text, ChartPeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
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
