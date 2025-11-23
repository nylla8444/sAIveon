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
  LlmProvider? _provider;
  late final FinancialDataService _financialDataService;
  String _financialContext = 'Loading your financial data in the background...';
  int? _currentSessionId;
  bool _isDataLoaded = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    // Don't initialize provider until data loads
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to connectivity changes
    final connectivityService = ServiceProvider.of(context).connectivityService;
    connectivityService.addListener(_onConnectivityChanged);
    _isOnline = connectivityService.isOnline;

    // Load financial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFinancialData();
    });
  }

  @override
  void dispose() {
    final connectivityService = ServiceProvider.of(context).connectivityService;
    connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    final connectivityService = ServiceProvider.of(context).connectivityService;
    setState(() {
      _isOnline = connectivityService.isOnline;
    });
  }

  Future<void> _loadFinancialData() async {
    if (!mounted) return;

    print('💰 [NewChatPage] Starting financial data load...');

    setState(() {
      _isDataLoaded = false;
    });

    final database = ServiceProvider.of(context).database;
    final currencyService = ServiceProvider.of(context).currencyService;
    _financialDataService = FinancialDataService(database, currencyService);

    try {
      print('📊 [NewChatPage] Fetching financial summary from database...');
      final data = await _financialDataService.getFinancialSummary();
      print(
        '✅ [NewChatPage] Financial data loaded successfully (${data.length} characters)',
      );

      if (mounted) {
        setState(() {
          _financialContext = data;
          _isDataLoaded = true;
        });
        print('🤖 [NewChatPage] Initializing AI provider with fresh data...');
        _initializeProvider();
        print('✅ [NewChatPage] AI provider ready');
      }
    } catch (e, stackTrace) {
      print('❌ [NewChatPage] Error loading financial data: $e');
      print('📋 [NewChatPage] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _financialContext = 'Unable to load financial data: $e';
          _isDataLoaded = true; // Mark as loaded even on error
        });
      }
    }
  }

  void _initializeProvider() {
    print('🔧 [NewChatPage] Initializing provider...');
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _provider = _GeminiLlmProvider(
      apiKey,
      () => _financialContext,
      onFirstMessage: _createChatSession,
      onMessage: _saveMessage,
    );
    print('✅ [NewChatPage] Provider initialized');
  }

  Future<void> _createChatSession(String firstMessage) async {
    if (!mounted) return;

    print('💬 [NewChatPage] Creating new chat session...');
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
    print('✅ [NewChatPage] Created chat session #$_currentSessionId: "$title"');
  }

  Future<void> _saveMessage(String content, bool isUser) async {
    if (_currentSessionId == null || !mounted) return;

    print(
      '💾 [NewChatPage] Saving ${isUser ? "USER" : "AI"} message (session #$_currentSessionId)',
    );
    final chatRepository = ServiceProvider.of(context).chatRepository;

    final message = ChatMessageEntity(
      sessionId: _currentSessionId!,
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    await chatRepository.addMessage(message);
    print('✅ [NewChatPage] Message saved');

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
                  // Data loading indicator and offline status
                  if (!_isOnline)
                    const Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: Color(0xFFFF6B6B),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    )
                  else if (!_isDataLoaded)
                    Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFBA9BFF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Loading data...',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: Color(0xFFBA9BFF),
                          ),
                        ),
                      ],
                    )
                  else
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Data loaded',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 8),
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
            if (!_isOnline)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI chat requires an internet connection.\nPlease check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_provider == null)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFBA9BFF)),
                      SizedBox(height: 16),
                      Text(
                        'Loading financial data...',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Color(0xFF949494),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
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
                    provider: _provider!,
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
  _GeminiLlmProvider(
    this._apiKey,
    this._getFinancialContext, {
    this.onFirstMessage,
    this.onMessage,
  });

  final String _apiKey;
  final String Function() _getFinancialContext;
  final Future<void> Function(String)? onFirstMessage;
  final Future<void> Function(String, bool)? onMessage;
  final List<ChatMessage> _history = [];
  bool _isFirstMessage = true;

  GenerativeModel _buildModel() {
    final systemPrompt =
        '''You are an expert financial advisor and personal finance assistant. 

You have access to the user's complete financial data including:
- Bank accounts and balances
- Transaction history
- Budget allocations and spending
- Scheduled payments
- Financial trends and insights

IMPORTANT GUIDELINES:
1. ALWAYS use the EXACT numbers from the financial data provided
2. NEVER make up or guess financial amounts - only use real data
3. If you don't see specific data, say "I don't see that information in your records"
4. Be specific and reference their real numbers when giving recommendations
5. Alert them to overspending, budget issues, or unusual patterns
6. Suggest concrete actions based on their spending habits
7. Help them set realistic financial goals based on their income/expenses
8. Explain financial concepts clearly and avoid jargon
9. Be encouraging and supportive, especially about financial challenges
10. Protect their privacy - never share or expose their data externally

Current Financial Data:
${_getFinancialContext()}

CRITICAL: Always refer to the financial data above for accurate information. Do not hallucinate or estimate values.''';

    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemPrompt),
    );
  }

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
    final model = _buildModel();
    final content = Content.text(prompt);
    final response = model.generateContentStream([content]);

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

    // Build model with fresh financial data
    final model = _buildModel();

    // Build full conversation history for Gemini (without system prompt)
    final conversationHistory = <Content>[];

    // Add all previous user/AI exchanges (max 10 pairs to save tokens)
    final maxHistory = 10;
    final startIdx = _history.length > maxHistory * 2
        ? _history.length - (maxHistory * 2)
        : 0;

    for (int i = startIdx; i < _history.length - 2; i += 2) {
      if (i + 1 < _history.length - 2) {
        final userText = _history[i].text ?? '';
        final aiText = _history[i + 1].text ?? '';
        if (userText.isNotEmpty && aiText.isNotEmpty) {
          conversationHistory.add(Content.text(userText));
          conversationHistory.add(Content.model([TextPart(aiText)]));
        }
      }
    }

    // Add current prompt
    conversationHistory.add(Content.text(prompt));

    // Send entire conversation to Gemini with fresh context
    final response = model.generateContentStream(conversationHistory);
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
}
