import 'package:flutter/material.dart';

/// Chat data model for previous chats list
class ChatData {
  final String message;
  final VoidCallback? onTap;

  ChatData({required this.message, this.onTap});
}

/// Previous Chats section for AI page
/// Based on Figma node 2101-1568 (Group 332)
class PreviousChatsSection extends StatelessWidget {
  final List<ChatData> chats;

  const PreviousChatsSection({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title - "Previous Chats"
          const Text(
            'Previous Chats',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.366,
            ),
          ),

          const SizedBox(height: 13),

          // Chat list container
          Container(
            width: 275,
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (int i = 0; i < chats.length; i++) ...[
                  _buildChatItem(chats[i]),
                  if (i < chats.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: const Color(0xFFCDCDCD).withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatData chat) {
    return GestureDetector(
      onTap: chat.onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            // Chat icon (message bubble)
            const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFFD0D0D0),
              size: 17,
            ),

            const SizedBox(width: 14),

            // Chat message text
            Expanded(
              child: Text(
                chat.message,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD0D0D0),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
