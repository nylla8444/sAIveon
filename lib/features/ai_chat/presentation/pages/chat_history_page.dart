import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/chat_entity.dart';
import 'chat_detail_page.dart';
import 'new_chat_page.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final chatRepository = ServiceProvider.of(context).chatRepository;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 12),
                  const Text(
                    'Chat History',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Chat Sessions List
            Expanded(
              child: StreamBuilder<List<ChatSessionEntity>>(
                stream: chatRepository.watchAllChatSessions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFBA9BFF),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading chat history',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Colors.red.shade300,
                        ),
                      ),
                    );
                  }

                  final sessions = snapshot.data ?? [];
                  final activeSessions =
                      sessions.where((s) => !s.isDeleted).toList()..sort(
                        (a, b) =>
                            b.lastMessageTime.compareTo(a.lastMessageTime),
                      );

                  if (activeSessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chat history yet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with your AI advisor',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewChatPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('New Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBA9BFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeSessions.length,
                    itemBuilder: (context, index) {
                      final session = activeSessions[index];
                      return _ChatSessionCard(
                        session: session,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatDetailPage(sessionId: session.id!),
                            ),
                          );
                        },
                        onDelete: () async {
                          final confirmed = await _showDeleteConfirmation(
                            context,
                            session.title,
                          );
                          if (confirmed == true && mounted) {
                            await chatRepository.deleteChatSession(session.id!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chat deleted'),
                                  backgroundColor: Color(0xFFBA9BFF),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewChatPage()),
          );
        },
        backgroundColor: const Color(0xFFBA9BFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Chat',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFB0B0B0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ChatSessionCard extends StatelessWidget {
  final ChatSessionEntity session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChatSessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(session.lastMessageTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA9BFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFFBA9BFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withOpacity(0.8),
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
