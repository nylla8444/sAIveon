import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/config/env.dart';

class ChatSessionPage extends StatefulWidget {
  final String initialPrompt;
  const ChatSessionPage({super.key, required this.initialPrompt});

  @override
  State<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends State<ChatSessionPage> {
  late final LlmProvider _provider;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() {
    // Get the Gemini API key from environment
    final apiKey = Env.geminiApiKey;

    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    // Create Gemini model with API key
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

    // Create an echo provider as a workaround since flutter_ai_toolkit 0.10.0
    // doesn't have direct Gemini support - we'll implement a custom provider
    _provider = _GeminiLlmProvider(model);

    // If there's an initial prompt, send it
    if (widget.initialPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _provider.sendMessageStream(widget.initialPrompt);
      });
    }
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
            Expanded(child: LlmChatView(provider: _provider)),
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
    final parts = <Part>[TextPart(prompt)];

    // Add attachments if any (simplified for now, full implementation would handle different types)
    // For now, just use text prompt

    return Content.multi(parts);
  }
}
