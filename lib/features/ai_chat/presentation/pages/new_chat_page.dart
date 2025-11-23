import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/services/financial_data_service.dart';
import '../../domain/entities/chat_entity.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  late final LlmProvider _provider;
  late final FinancialDataService _financialDataService;
  String _financialContext = 'Loading your financial data in the background...';
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load financial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFinancialData();
    });
  }

  Future<void> _loadFinancialData() async {
    if (!mounted) return;

    final database = ServiceProvider.of(context).database;
    _financialDataService = FinancialDataService(database);

    try {
      final data = await _financialDataService.getFinancialSummary();
      if (mounted) {
        setState(() {
          _financialContext = data;
        });
        // Reinitialize provider with actual data
        _initializeProvider();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _financialContext = 'Unable to load financial data: $e';
        });
      }
    }
  }

  void _initializeProvider() {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    final systemPrompt =
        '''You are an expert financial advisor and personal finance assistant. 

You have access to the user's complete financial data including:
- Bank accounts and balances
- Transaction history
- Budget allocations and spending
- Scheduled payments
- Financial trends and insights

IMPORTANT GUIDELINES:
1. Analyze the user's actual financial data to provide personalized advice
2. Be specific and reference their real numbers when giving recommendations
3. Alert them to overspending, budget issues, or unusual patterns
4. Suggest concrete actions based on their spending habits
5. Help them set realistic financial goals based on their income/expenses
6. Explain financial concepts clearly and avoid jargon
7. Be encouraging and supportive, especially about financial challenges
8. Protect their privacy - never share or expose their data externally

Current Financial Data:
$_financialContext

Use this data to provide informed, personalized financial guidance.''';

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    _provider = _GeminiLlmProvider(
      model,
      onFirstMessage: _createChatSession,
      onMessage: _saveMessage,
    );
  }

  Future<void> _createChatSession(String firstMessage) async {
    if (!mounted) return;

    final chatRepository = ServiceProvider.of(context).chatRepository;

    // Create session with first message as title (truncated)
    final title = firstMessage.length > 50
        ? '${firstMessage.substring(0, 47)}...'
        : firstMessage;

    final session = ChatSessionEntity(
      title: title,
      lastMessageTime: DateTime.now(),
    );

    _currentSessionId = await chatRepository.addChatSession(session);
    print(
      '✅ Created chat session with ID: $_currentSessionId and title: $title',
    );
  }

  Future<void> _saveMessage(String content, bool isUser) async {
    if (_currentSessionId == null || !mounted) return;

    final chatRepository = ServiceProvider.of(context).chatRepository;

    final message = ChatMessageEntity(
      sessionId: _currentSessionId!,
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    await chatRepository.addMessage(message);
    print(
      '✅ Saved ${isUser ? 'user' : 'AI'} message to session $_currentSessionId',
    );

    // Update session's last message time
    final sessions = await chatRepository.watchAllChatSessions().first;
    final currentSession = sessions.firstWhere(
      (s) => s.id == _currentSessionId,
    );
    await chatRepository.updateChatSession(
      currentSession.copyWith(lastMessageTime: DateTime.now()),
    );
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
                    'AI Financial Advisor',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Refresh button to reload financial data
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFFBA9BFF),
                      size: 24,
                    ),
                    onPressed: _loadFinancialData,
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
  _GeminiLlmProvider(this._model, {this.onFirstMessage, this.onMessage});

  final GenerativeModel _model;
  final Future<void> Function(String)? onFirstMessage;
  final Future<void> Function(String, bool)? onMessage;
  late final ChatSession _chat = _model.startChat();
  final List<ChatMessage> _history = [];
  bool _isFirstMessage = true;

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
    // Create session on first message
    if (_isFirstMessage && onFirstMessage != null) {
      await onFirstMessage!(prompt);
      _isFirstMessage = false;
    }

    // Save user message
    if (onMessage != null) {
      await onMessage!(prompt, true);
    }

    // Add user message to history
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    // Send message to Gemini
    final content = _buildContent(prompt, attachments);
    final response = _chat.sendMessageStream(content);

    final buffer = StringBuffer();
    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null) {
        llmMessage.append(text);
        buffer.write(text);
        yield text;
      }
    }

    // Save AI response message
    if (onMessage != null && buffer.isNotEmpty) {
      await onMessage!(buffer.toString(), false);
    }

    notifyListeners();
  }

  Content _buildContent(String prompt, Iterable<Attachment> attachments) {
    return Content.text(prompt);
  }
}
