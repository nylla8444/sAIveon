import 'package:flutter/material.dart';

/// Header section with user profile, name, and notification bell
/// Based on Figma node 2065-769 (Group 284)
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Image (Layer 6 from Figma)
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 28.07,
              height: 28.08,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ),

          // User Name (Poppins 500, 14px)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
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
          ),

          // Notification Icon (26. Notification from Figma)
          GestureDetector(
            onTap: onNotificationTap,
            child: SizedBox(
              width: 15,
              height: 16,
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  // Red dot indicator (Ellipse 221)
                  if (hasNotification)
                    Positioned(
                      right: 0,
                      top: 0,
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
          ),
        ],
      ),
    );
  }
}
