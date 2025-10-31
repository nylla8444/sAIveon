import 'package:flutter/material.dart';

/// Header section with user profile, name, and notification bell
/// Based on Figma node 2101-1521 (Group 329)
/// Matches the statistics page header design
class HeaderSection extends StatelessWidget {
  final String userName;
  final bool hasNotification;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const HeaderSection({
    super.key,
    required this.userName,
    this.hasNotification = false,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          // Profile Picture (Layer 6 - circular avatar)
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFD6D6D6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBA9BFF).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF050505),
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 7),

          // User Name (Poppins 500, 14px) - Left aligned next to profile
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFE6E6E6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),

          // Notification Icon (26. Notification from Figma)
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 15,
                  height: 16,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                // Red dot indicator (Ellipse 221)
                if (hasNotification)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8282),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
