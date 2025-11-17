import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_back_button.dart';
import 'chat_session_page.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final TextEditingController _controller = TextEditingController(
    text: 'Help me set a monthly savings goal',
  );

  void _startChat(String initialPrompt) {
    final prompt = initialPrompt.trim();
    if (prompt.isEmpty) return; // no empty chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSessionPage(initialPrompt: prompt),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Chat',
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
            const SizedBox(height: 40),
            // Center AI icon (SVG, same as AI welcome section)
            Center(
              child: SizedBox(
                width: 66,
                height: 68,
                child: SvgPicture.asset(
                  'assets/images/ai_icon.svg',
                  width: 66,
                  height: 68,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Suggestion cards scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Column(
                  children: [
                    _PromptSuggestionCard(
                      text: 'Help me set a monthly savings  goal',
                      onTap: () =>
                          _startChat('Help me set a monthly savings goal'),
                    ),
                    const SizedBox(height: 8),
                    _PromptSuggestionCard(
                      text:
                          'Can you recommend investment strategies \nfor long-term growth?',
                      onTap: () => _startChat(
                        'Can you recommend investment strategies for long-term growth?',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PromptSuggestionCard(
                      text:
                          'What’s the best way to save for a major \npurchase?',
                      onTap: () => _startChat(
                        'What’s the best way to save for a major purchase?',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Bottom fixed input + send button
            Padding(
              padding: const EdgeInsets.fromLTRB(33, 0, 33, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD6D6D6),
                          height: 1.366,
                        ),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF949494),
                            height: 1.366,
                          ),
                        ),
                        onSubmitted: (_) => _startChat(_controller.text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _startChat(_controller.text),
                    child: Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA9BFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptSuggestionCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PromptSuggestionCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 61,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 15),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD6D6D6),
            height: 1.366,
          ),
        ),
      ),
    );
  }
}
