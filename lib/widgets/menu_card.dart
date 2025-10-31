import 'package:flutter/material.dart';

/// Menu card data model
class MenuCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  MenuCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });
}

/// Menu card widget for More page
/// Based on Figma rectangles with icons, titles, and subtitles
class MenuCard extends StatelessWidget {
  final MenuCardData data;

  const MenuCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        width: 155,
        height: 185,
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: const Color(0xFF000000), size: 24),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              data.title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFD6D6D6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle
            Flexible(
              child: Text(
                data.subtitle,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.366,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
