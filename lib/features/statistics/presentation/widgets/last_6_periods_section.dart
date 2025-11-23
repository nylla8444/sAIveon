import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';

class PeriodBarData {
  final double within; // Purple section
  final double risk; // Yellow section
  final double overspending; // Red section

  const PeriodBarData({
    required this.within,
    required this.risk,
    required this.overspending,
  });
}

class Last6PeriodsSection extends StatelessWidget {
  final Map<String, PeriodBarData> data; // Month name -> bar data

  const Last6PeriodsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyService = ServiceProvider.of(context).currencyService;
    final months = data.keys.toList();
    final isLastMonth = (String month) => month == months.last;

    return Container(
      width: double.infinity,
      height: 230,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 21),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Last 6 periods',
            style: TextStyle(
              color: Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Manrope',
              height: 1.366,
            ),
          ),

          const SizedBox(height: 12),

          // Chart area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildYAxisLabel(currencyService.formatWhole(2500)),
                    _buildYAxisLabel(currencyService.formatWhole(2000)),
                    _buildYAxisLabel(currencyService.formatWhole(1500)),
                    _buildYAxisLabel(currencyService.formatWhole(1000)),
                    _buildYAxisLabel(currencyService.formatWhole(500)),
                    _buildYAxisLabel(currencyService.formatWhole(0)),
                  ],
                ),

                const SizedBox(width: 8),

                // Bars and X-axis
                Expanded(
                  child: Column(
                    children: [
                      // Bars
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: months.map((month) {
                            return _buildBar(data[month]!, isLastMonth(month));
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // X-axis labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: months.map((month) {
                          return Text(
                            month,
                            style: TextStyle(
                              color: isLastMonth(month)
                                  ? const Color(0xFFBA9BFF)
                                  : const Color(0xFF949494),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              height: 1.5,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
              _buildLegendItem('Within', const Color(0xFFA882FF)),
              const SizedBox(width: 13),
              _buildLegendItem('Risk', const Color(0xFFFFE282)),
              const SizedBox(width: 13),
              _buildLegendItem('Overspending', const Color(0xFFFF8282)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF949494),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
    );
  }

  Widget _buildBar(PeriodBarData data, bool isLast) {
    const maxHeight = 113.0; // Maximum bar height in pixels (reduced to fit)
    const maxValue = 2500.0; // Maximum value ($2,500)

    final withinHeight = (data.within / maxValue) * maxHeight;
    final riskHeight = (data.risk / maxValue) * maxHeight;
    final overspendingHeight = (data.overspending / maxValue) * maxHeight;

    return SizedBox(
      width: 16,
      height: maxHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red (Overspending) - top
          if (overspendingHeight > 0)
            Container(
              width: 16,
              height: overspendingHeight.clamp(1.0, maxHeight),
              decoration: const BoxDecoration(
                color: Color(0xFFFF8282),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          // Yellow (Risk) - middle
          if (riskHeight > 0)
            Container(
              width: 16,
              height: riskHeight.clamp(1.0, maxHeight),
              color: const Color(0xFFFFE282),
            ),
          // Purple (Within) - bottom
          if (withinHeight > 0)
            Container(
              width: 16,
              height: withinHeight.clamp(1.0, maxHeight),
              decoration: BoxDecoration(
                color: const Color(0xFFA882FF),
                borderRadius: overspendingHeight == 0 && riskHeight == 0
                    ? const BorderRadius.vertical(top: Radius.circular(4))
                    : BorderRadius.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC6C6C6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
            height: 1.366,
          ),
        ),
      ],
    );
  }
}
