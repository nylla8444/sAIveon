import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/services/financial_data_service.dart';
import '../../domain/entities/chat_entity.dart';

class ChatDetailPage extends StatefulWidget {
  final int sessionId;
  const ChatDetailPage({super.key, required this.sessionId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  LlmProvider? _provider;
  late final FinancialDataService _financialDataService;
  String _financialContext = 'Loading your financial data in the background...';
  ChatSessionEntity? _session;
  bool _isLoading = true;
  bool _isDataLoaded = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    // Don't initialize provider here - wait for financial data
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to connectivity changes
    final connectivityService = ServiceProvider.of(context).connectivityService;
    connectivityService.addListener(_onConnectivityChanged);
    _isOnline = connectivityService.isOnline;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessionAndFinancialData();
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

  Future<void> _loadSessionAndFinancialData() async {
    if (!mounted) return;

    print('💰 [ChatDetail] Starting session load for #${widget.sessionId}...');

    setState(() {
      _isDataLoaded = false;
    });

    final database = ServiceProvider.of(context).database;
    final chatRepository = ServiceProvider.of(context).chatRepository;
    _financialDataService = FinancialDataService(database);

    try {
      // Load session info
      print('📋 [ChatDetail] Loading session info...');
      final sessions = await chatRepository.watchAllChatSessions().first;
      final session = sessions.firstWhere((s) => s.id == widget.sessionId);
      print('✅ [ChatDetail] Session loaded: "${session.title}"');

      // Load financial data
      print('💰 [ChatDetail] Loading financial data...');
      final data = await _financialDataService.getFinancialSummary();
      print('✅ [ChatDetail] Financial data loaded (${data.length} characters)');

      // Load previous messages
      print('💬 [ChatDetail] Loading previous messages...');
      final messages = await chatRepository
          .watchMessagesBySession(widget.sessionId)
          .first;

      final activeMessages = messages.where((m) => !m.isDeleted).length;
      print(
        '📊 [ChatDetail] Found $activeMessages active messages (${messages.length} total)',
      );

      if (mounted) {
        setState(() {
          _session = session;
          _financialContext = data;
          _isLoading = false;
          _isDataLoaded = true;
        });

        // Reinitialize provider with actual data
        print('🤖 [ChatDetail] Initializing AI provider...');
        _initializeProvider();
        print('✅ [ChatDetail] AI provider ready');

        // Restore chat history
        final chatMessages = messages.where((m) => !m.isDeleted).map((m) {
          if (m.isUser) {
            return ChatMessage.user(m.content, const []);
          } else {
            final llmMsg = ChatMessage.llm();
            llmMsg.append(m.content);
            return llmMsg;
          }
        }).toList();

        print(
          '📝 [ChatDetail] Restoring ${chatMessages.length} messages to UI...',
        );
        if (chatMessages.isNotEmpty && _provider != null) {
          _provider!.history = chatMessages;
          print('✅ [ChatDetail] Chat history restored');
        } else if (chatMessages.isEmpty) {
          print('ℹ️ [ChatDetail] No messages to restore - new chat');
        }
      }

      print('✅ [ChatDetail] Session load complete\n');
    } catch (e, stackTrace) {
      print('❌ [ChatDetail] Error loading session: $e');
      print('📋 [ChatDetail] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _financialContext = 'Unable to load financial data: $e';
          _isLoading = false;
          _isDataLoaded = true; // Mark as loaded even on error
        });
      }
    }
  }

  void _initializeProvider() {
    print('🔧 [ChatDetail] Initializing provider...');
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _provider = _GeminiLlmProvider(
      apiKey,
      () => _financialContext,
      onMessage: _saveMessage,
    );
    print('✅ [ChatDetail] Provider initialized');
  }

  Future<void> _saveMessage(String content, bool isUser) async {
    if (!mounted) return;

    print(
      '💾 [ChatDetail] Saving ${isUser ? "USER" : "AI"} message (session #${widget.sessionId})',
    );
    final chatRepository = ServiceProvider.of(context).chatRepository;

    final message = ChatMessageEntity(
      sessionId: widget.sessionId,
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    await chatRepository.addMessage(message);
    print('✅ [ChatDetail] Message saved');

    // Update session's last message time
    if (_session != null) {
      await chatRepository.updateChatSession(
        _session!.copyWith(lastMessageTime: DateTime.now()),
      );
      print('✅ [ChatDetail] Session timestamp updated');
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
                  Expanded(
                    child: Text(
                      _session?.title ?? 'Loading...',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                  else if (!_isLoading && !_isDataLoaded)
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
                  else if (!_isLoading && _isDataLoaded)
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
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFFBA9BFF),
                      size: 24,
                    ),
                    onPressed: _loadSessionAndFinancialData,
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
            else if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFBA9BFF)),
                ),
              )
            else if (_provider != null)
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
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0x1AFFFFFF),
                            width: 1,
                          ),
                        ),
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
  _GeminiLlmProvider(this._apiKey, this._getFinancialContext, {this.onMessage});

  final String _apiKey;
  final String Function() _getFinancialContext;
  final Future<void> Function(String, bool)? onMessage;
  final List<ChatMessage> _history = [];

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
    // Save user message
    if (onMessage != null) {
      await onMessage!(prompt, true);
    }

    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    // Build model with fresh financial data
    final model = _buildModel();

    // Build full conversation history (max 10 pairs)
    final conversationHistory = <Content>[];
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

    // Send with fresh system context
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
