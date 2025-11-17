import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../ai_chat/presentation/widgets/ai_welcome_section.dart';
import '../../../ai_chat/presentation/widgets/new_chat_button.dart';
import '../../../ai_chat/presentation/widgets/previous_chats_section.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../ai_chat/presentation/pages/new_chat_page.dart';

class AIPage extends StatelessWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const SizedBox(height: 20),
                HeaderSection(
                  userName: 'Allyn Ralf Ledesma',
                  hasNotification: true,
                  onProfileTap: () {
                    // TODO: Navigate to profile page
                  },
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // AI Welcome Section - centered
                const Center(child: AIWelcomeSection()),

                const SizedBox(height: 30),

                // New Chat Button - centered
                Center(
                  child: NewChatButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewChatPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Previous Chats Section - centered
                Center(
                  child: PreviousChatsSection(
                    chats: [
                      ChatData(
                        message: 'Can you recommend investment...',
                        onTap: () {
                          // TODO: Open chat
                          print('Chat 1 tapped');
                        },
                      ),
                      ChatData(
                        message: 'What are some times for building...',
                        onTap: () {
                          print('Chat 2 tapped');
                        },
                      ),
                      ChatData(
                        message: 'Can you provide me investment re...',
                        onTap: () {
                          print('Chat 3 tapped');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
