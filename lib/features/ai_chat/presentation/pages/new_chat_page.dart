import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/config/env.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  late final LlmProvider _provider;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are a helpful financial assistant for a personal finance app. '
        'Help users with budgeting, saving, investing, expense tracking, and financial planning. '
        'Provide practical, actionable advice tailored to their financial goals. '
        'Be concise, friendly, and supportive. When discussing specific amounts or strategies, '
        'ask clarifying questions if needed to give personalized recommendations.',
      ),
    );

    _provider = _GeminiLlmProvider(model);
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
            // AI Chat View
            Expanded(
              child: Theme(
                data: ThemeData.dark().copyWith(
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFFFFF),
                      height: 1.5,
                    ),
                    bodyMedium: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFFFFF),
                      height: 1.5,
                    ),
                  ),
                ),
                child: LlmChatView(
                  provider: _provider,
                  responseBuilder: (context, response) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GptMarkdown(
                        response,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                          height: 1.5,
                        ),
                      ),
                    );
                  },
                  style: LlmChatViewStyle(
                    backgroundColor: const Color(0xFF050505),
                    menuColor: const Color(0xFF101010),
                    progressIndicatorColor: const Color(0xFFBA9BFF),
                    userMessageStyle: UserMessageStyle(
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFFFFF),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xF86A4AAD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    llmMessageStyle: const LlmMessageStyle(
                      decoration: BoxDecoration(
                        color: Color(0xFF101010),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border.fromBorderSide(
                          BorderSide(color: Color(0x1AFFFFFF), width: 1),
                        ),
                      ),
                      iconColor: Color(0xFFBA9BFF),
                    ),
                    chatInputStyle: ChatInputStyle(
                      backgroundColor: const Color(0xFF101010),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFFFFF),
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF949494),
                      ),
                      hintText: 'Ask me anything...',
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    submitButtonStyle: ActionButtonStyle(
                      iconColor: const Color(0xFFBA9BFF),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Gemini provider implementation for flutter_ai_toolkit
class _GeminiLlmProvider extends LlmProvider with ChangeNotifier {
  _GeminiLlmProvider(this._model);

  final GenerativeModel _model;
  late final ChatSession _chat = _model.startChat();
  final List<ChatMessage> _history = [];

  @override
  Iterable<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> value) {
    _history.clear();
    _history.addAll(value);
    notifyListeners();
  }

  @override
  Stream<String> generateStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    final content = _buildContent(prompt, attachments);
    final response = _model.generateContentStream([content]);

    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null) {
        yield text;
      }
    }
  }

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    // Add user message to history
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    // Send message to Gemini
    final content = _buildContent(prompt, attachments);
    final response = _chat.sendMessageStream(content);

    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null) {
        llmMessage.append(text);
        yield text;
      }
    }

    notifyListeners();
  }

  Content _buildContent(String prompt, Iterable<Attachment> attachments) {
    return Content.text(prompt);
  }
}
