import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/budget_entity.dart';

class MonthlyBudgetSection extends StatefulWidget {
  final VoidCallback? onSeeAllTap;

  const MonthlyBudgetSection({super.key, this.onSeeAllTap});

  @override
  State<MonthlyBudgetSection> createState() => _MonthlyBudgetSectionState();
}

class _MonthlyBudgetSectionState extends State<MonthlyBudgetSection> {
  Stream<Map<String, dynamic>> _getMonthlyBudgetStream(
    ServiceLocator locator,
    int month,
    int year,
  ) async* {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    // Helper function to calculate spending
    Future<double> calculateSpending() async {
      final allTransactions = await locator.transactionRepository
          .watchAllTransactions()
          .first;

      double spending = 0.0;
      for (var tx in allTransactions) {
        if (!tx.isDeleted &&
            tx.type == 'send' &&
            tx.date.isAfter(startDate) &&
            tx.date.isBefore(endDate)) {
          spending += tx.amount;
        }
      }
      return spending;
    }

    // Get or create monthly budget
    final budget = await locator.budgetRepository.getOrCreateMonthlyBudget(
      month,
      year,
    );

    // Calculate initial spending
    final spending = await calculateSpending();

    yield {'budget': budget, 'spent': spending};

    // Watch for both budget and transaction changes
    final budgetStream = locator.budgetRepository.watchAllBudgets();
    final transactionStream = locator.transactionRepository
        .watchAllTransactions();

    // Merge streams manually
    await for (final _ in _mergeStreams([budgetStream, transactionStream])) {
      final updatedBudget = await locator.budgetRepository
          .getOrCreateMonthlyBudget(month, year);
      final updatedSpending = await calculateSpending();

      yield {'budget': updatedBudget, 'spent': updatedSpending};
    }
  }

  Stream<dynamic> _mergeStreams(List<Stream<dynamic>> streams) async* {
    final controllers = <StreamSubscription>[];
    final streamController = StreamController<dynamic>.broadcast();

    for (final stream in streams) {
      controllers.add(
        stream.listen(
          (event) => streamController.add(event),
          onError: streamController.addError,
        ),
      );
    }

    await for (final event in streamController.stream) {
      yield event;
    }

    for (final controller in controllers) {
      await controller.cancel();
    }
    await streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    final locator = ServiceProvider.of(context);
    final now = DateTime.now();

    return StreamBuilder(
      stream: _getMonthlyBudgetStream(locator, now.month, now.year),
      builder: (context, snapshot) {
        final double spent;
        final double limit;

        if (!snapshot.hasData) {
          spent = 0;
          limit = 5000;
        } else {
          final data = snapshot.data as Map<String, dynamic>;
          final budget = data['budget'] as BudgetEntity;
          spent = data['spent'] as double;
          limit = budget.budgetAmount;
        }

        return _MonthlyBudgetDisplay(
          spent: spent,
          limit: limit,
          onSeeAllTap: widget.onSeeAllTap,
        );
      },
    );
  }
}

class _MonthlyBudgetDisplay extends StatelessWidget {
  final double spent;
  final double limit;
  final VoidCallback? onSeeAllTap;

  const _MonthlyBudgetDisplay({
    required this.spent,
    required this.limit,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (spent / limit).clamp(0.0, 1.0);
    final percentageText = '${(percentage * 100).toInt()}%';

    // Determine color based on percentage
    Color chartColor;
    if (percentage < 0.8) {
      chartColor = const Color(0xFFA882FF); // Purple - Within budget
    } else if (percentage < 1.0) {
      chartColor = const Color(0xFFFFE282); // Yellow - Risk
    } else {
      chartColor = const Color(0xFFFF8282); // Red - Overspending
    }

    return Container(
      width: double.infinity,
      height: 190, // Fixed height from Figma
      // 👉 ADJUST PADDING HERE: Change bottom padding to make it smaller
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        12,
      ), // 👈 left, top, right, bottom
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Header - "Monthly Budget" at (18, 15)
          const Positioned(
            left: 0,
            top: -3,
            child: Text(
              'Monthly Budget',
              style: TextStyle(
                color: Color(0xFFD6D6D6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope',
                height: 1.366,
              ),
            ),
          ),

          // "See All" at (270, 14) - adjusted for padding
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onSeeAllTap,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFFC6C6C6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Manrope',
                  height: 1.2,
                ),
              ),
            ),
          ),

          // Title "Monthly\nSpending Limit" at (18, 51)
          const Positioned(
            left: 0,
            top: 33,
            child: Text(
              'Monthly\nSpending Limit',
              style: TextStyle(
                color: Color(0xFFD6D6D6),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope',
                height: 1.366,
              ),
            ),
          ),

          // Spending info at (18, 103)
          Positioned(
            left: 0,
            top: 85,
            child: Text(
              'Spend: ${ServiceProvider.of(context).currencyService.formatWhole(spent)} / ${ServiceProvider.of(context).currencyService.formatWhole(limit)}',
              style: const TextStyle(
                color: Color(0xFF949494),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ),

          // Donut Chart at (169, 28) - adjusted for padding
          Positioned(
            right: 15,
            top: 10,
            child: SizedBox(
              width: 123,
              height: 123,
              child: CustomPaint(
                painter: MonthlyBudgetDonutChartPainter(
                  percentage: percentage,
                  color: chartColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        percentageText,
                        style: const TextStyle(
                          color: Color(0xFFE6E6E6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Manrope',
                          height: 1.366,
                        ),
                      ),
                      const Text(
                        'spent',
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
                ),
              ),
            ),
          ),

          // Legend at bottom - centered, pushed down more
          // 👉 ADJUST THIS: Change the "bottom" value to push legends up/down
          // Smaller number = closer to bottom edge
          // Larger number = moves up
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // 👈 CHANGE THIS VALUE (currently 10, was 3)
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem('Within', const Color(0xFFA882FF)),
                  const SizedBox(width: 18),
                  _buildLegendItem('Risk', const Color(0xFFFFE282)),
                  const SizedBox(width: 18),
                  _buildLegendItem('Overspending', const Color(0xFFFF8282)),
                ],
              ),
            ),
          ),
        ],
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
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC6C6C6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }
}

class MonthlyBudgetDonutChartPainter extends CustomPainter {
  final double percentage;
  final Color color;

  MonthlyBudgetDonutChartPainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle (unfilled portion with opacity)
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.43)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw filled circle based on percentage
    final filledPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate the angle for the filled portion (clockwise from top)
    final sweepAngle = 2 * math.pi * percentage;

    // Draw arc starting from top (-90 degrees / -pi/2 radians)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, -math.pi / 2, sweepAngle, false)
      ..close();

    canvas.drawPath(path, filledPaint);

    // Draw white center circle to create donut effect
    final centerPaint = Paint()
      ..color = const Color(0xFF101010)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 30, centerPaint);
  }

  @override
  bool shouldRepaint(MonthlyBudgetDonutChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
