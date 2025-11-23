import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../../ai_chat/presentation/widgets/ai_welcome_section.dart';
import '../../../ai_chat/presentation/widgets/new_chat_button.dart';
import '../../../ai_chat/presentation/widgets/previous_chats_section.dart';
import '../../../ai_chat/domain/entities/chat_entity.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../ai_chat/presentation/pages/new_chat_page.dart';
import '../../../ai_chat/presentation/pages/chat_history_page.dart';
import '../../../ai_chat/presentation/pages/chat_detail_page.dart';

class AIPage extends StatelessWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatRepository = ServiceProvider.of(context).chatRepository;

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
                Row(
                  children: [
                    Expanded(
                      child: HeaderSection(
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
                    ),
                    // Chat History Icon Button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatHistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.history,
                        color: Color(0xFFBA9BFF),
                        size: 28,
                      ),
                      tooltip: 'Chat History',
                    ),
                  ],
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

                // Previous Chats Section - centered with real data
                Center(
                  child: StreamBuilder<List<ChatSessionEntity>>(
                    stream: chatRepository.watchAllChatSessions(),
                    builder: (context, snapshot) {
                      final sessions = snapshot.data ?? [];
                      final activeSessions =
                          sessions.where((s) => !s.isDeleted).toList()..sort(
                            (a, b) =>
                                b.lastMessageTime.compareTo(a.lastMessageTime),
                          );

                      final recentChats = activeSessions.take(3).map((session) {
                        return ChatData(
                          message: session.title,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatDetailPage(sessionId: session.id!),
                              ),
                            );
                          },
                        );
                      }).toList();

                      return Column(
                        children: [
                          if (recentChats.isNotEmpty)
                            PreviousChatsSection(chats: recentChats),
                          if (activeSessions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatHistoryPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.history,
                                size: 16,
                                color: Color(0xFFBA9BFF),
                              ),
                              label: Text(
                                activeSessions.length > 3
                                    ? 'View All ${activeSessions.length} Chats'
                                    : 'View Chat History',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFBA9BFF),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
