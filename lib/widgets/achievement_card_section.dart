import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Achievement card with donut chart showing savings
/// Based on Figma node 2069-820 (Group 304)
class AchievementCardSection extends StatelessWidget {
  final String title;
  final String description;
  final String amount;
  final String subtitle;
  final double percentage; // 0.0 to 1.0 for the donut chart
  final VoidCallback? onViewDetailsTap;

  const AchievementCardSection({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.subtitle,
    this.percentage = 0.66,
    this.onViewDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Take full available width
      height: 115,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
      ),
      child: Stack(
        children: [
          // Left side text content - positioned according to Figma
          Positioned(
            left: 17,
            top: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Well done!" at y:13 (Manrope 800, 20px)
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFE6E6E6),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.366,
                  ),
                ),
                const SizedBox(height: 3),
                // Description at y:43 (Poppins 500, 12px)
                SizedBox(
                  width: 156,
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFFC6C6C6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // "View Details" at y:89 (Manrope 600, 11px, #A882FF)
          Positioned(
            left: 21,
            bottom: 11, // 115 - 89 - 15 (text height) = 11
            child: GestureDetector(
              onTap: onViewDetailsTap,
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFA882FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.366,
                ),
              ),
            ),
          ),
          // Right side: Donut chart at x:199, y:11
          Positioned(
            right: 21, // 313 - 199 - 93 = 21
            top: 11,
            child: SizedBox(
              width: 93,
              height: 93,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Custom Donut Chart using CustomPaint for exact Figma match
                  CustomPaint(
                    size: const Size(93, 93),
                    painter: DonutChartPainter(
                      percentage: percentage,
                      fillColor: const Color(0xFFA882FF),
                      backgroundColor: const Color(
                        0xFFA882FF,
                      ).withOpacity(0.43),
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount (Manrope 800, 16px) at y:39 from container top
                      Text(
                        amount,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          color: Color(0xFFE6E6E6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.366,
                        ),
                      ),
                      // Subtitle (Manrope 500, 12px) at y:56 from container top
                      Text(
                        subtitle,
                        style: const TextStyle(
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
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing a thick donut chart that matches Figma design
class DonutChartPainter extends CustomPainter {
  final double percentage; // 0.0 to 1.0
  final Color fillColor;
  final Color backgroundColor;
  final double strokeWidth;

  DonutChartPainter({
    required this.percentage,
    required this.fillColor,
    required this.backgroundColor,
    this.strokeWidth = 15.0, // Thick ring like in Figma
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc (unfilled portion) - lighter purple, only the remaining portion
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc for the unfilled portion
    const startAngle = -math.pi / 2;
    final filledSweepAngle = 2 * math.pi * percentage;
    final unfilledStartAngle = startAngle + filledSweepAngle;
    final unfilledSweepAngle = 2 * math.pi * (1 - percentage);

    // Draw unfilled portion (light purple)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      unfilledStartAngle,
      unfilledSweepAngle,
      false,
      backgroundPaint,
    );

    // Foreground arc (filled portion) - solid purple
    final foregroundPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw filled arc starting from top
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      filledSweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
