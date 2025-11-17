import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/index.dart';

class ChatMessage {
  final String role; // 'user' or 'ai'
  final String text;
  ChatMessage(this.role, this.text);
}

class ChatSessionPage extends StatefulWidget {
  final String initialPrompt;
  const ChatSessionPage({super.key, required this.initialPrompt});

  @override
  State<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends State<ChatSessionPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt.isNotEmpty) {
      _addUserMessage(widget.initialPrompt);
      _simulateAIResponse(widget.initialPrompt);
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage('user', text));
    });
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(ChatMessage('ai', text));
    });
  }

  Future<void> _simulateAIResponse(String prompt) async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 900));
    _addAIMessage(_generateStubResponse(prompt));
    setState(() => _isGenerating = false);
  }

  String _generateStubResponse(String prompt) {
    // Simple canned logic depending on prompt keywords
    if (prompt.toLowerCase().contains('savings')) {
      return 'To reach your savings goal, divide the target by the months available. Automate transfers and track progress weekly.';
    } else if (prompt.toLowerCase().contains('investment')) {
      return 'Diversify across index funds, keep costs low, reinvest dividends, and review allocation annually.';
    } else if (prompt.toLowerCase().contains('purchase')) {
      return 'Create a dedicated sinking fund. Estimate total cost, set a deadline, and automate monthly contributions.';
    }
    return 'I\'d be glad to help. Could you share a bit more detail about your objective?';
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isGenerating) return;
    _controller.clear();
    _addUserMessage(text);
    _simulateAIResponse(text);
  }

  void _handleRegenerate() {
    if (_messages.isEmpty || _isGenerating) return;
    // Regenerate last AI answer based on previous user message.
    final lastUser = _messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => ChatMessage('user', widget.initialPrompt),
    );
    setState(() {
      // Remove last AI message if it is last
      if (_messages.isNotEmpty && _messages.last.role == 'ai') {
        _messages.removeLast();
      }
    });
    _simulateAIResponse(lastUser.text);
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
            const SizedBox(height: 20),
            // Messages list + top AI icon
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 33),
                itemCount: _messages.length + 1 + (_isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  // Top AI icon header
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
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
                    );
                  }
                  // Thinking indicator at the end
                  if (_isGenerating && index == _messages.length + 1) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Thinking...',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD6D6D6),
                          ),
                        ),
                      ),
                    );
                  }
                  final msg = _messages[index - 1];
                  final isUser = msg.role == 'user';
                  return _ChatBubble(text: msg.text, isUser: isUser);
                },
              ),
            ),
            // Regenerate button (above input)
            if (_messages.isNotEmpty && !_isGenerating)
              Padding(
                padding: const EdgeInsets.fromLTRB(33, 8, 33, 12),
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _handleRegenerate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Color(0xFFD6D6D6),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Regenerate',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD6D6D6),
                              height: 1.366,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Input bar
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
                        ),
                      ),
                      alignment: Alignment.center,
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
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleSend,
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

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isUser ? Colors.white : const Color(0xFFBA9BFF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isUser
                ? const Icon(Icons.person, size: 16, color: Colors.black)
                : SvgPicture.asset(
                    'assets/images/ai_icon.svg',
                    width: 16,
                    height: 16,
                  ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'AI Chat',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD6D6D6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD6D6D6),
                    height: 1.366,
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
