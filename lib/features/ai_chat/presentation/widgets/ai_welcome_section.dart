import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AI welcome section with icon, title, and subtitle
/// Based on Figma node 2101-1569 (Group 333)
class AIWelcomeSection extends StatelessWidget {
  const AIWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 182,
      height: 189,
      child: Column(
        children: [
          // AI Icon (Vector - purple sparkle/star icon from Figma)
          SizedBox(
            width: 66,
            height: 68,
            child: SvgPicture.asset(
              'assets/images/ai_icon.svg',
              width: 66,
              height: 68,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 15),

          // Welcome title - "Welcome to AI Chat"
          const Text(
            'Welcome to\nAI Chat',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.366,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle - "Start chatting with AI Chat now"
          const Text(
            'Start chatting with AI Chat now',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.366,
            ),
          ),
        ],
      ),
    );
  }
}
