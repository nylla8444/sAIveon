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

  @override
  void initState() {
    super.initState();
    // Don't initialize provider here - wait for financial data
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessionAndFinancialData();
    });
  }

  Future<void> _loadSessionAndFinancialData() async {
    if (!mounted) return;

    print('\n🔵 === ChatDetailPage: Loading Session ${widget.sessionId} ===');

    final database = ServiceProvider.of(context).database;
    final chatRepository = ServiceProvider.of(context).chatRepository;
    _financialDataService = FinancialDataService(database);

    try {
      // Load session info
      print('🔵 Loading session info...');
      final sessions = await chatRepository.watchAllChatSessions().first;
      final session = sessions.firstWhere((s) => s.id == widget.sessionId);
      print('✅ Session loaded: "${session.title}"');

      // Load financial data
      print('🔵 Loading financial data...');
      final data = await _financialDataService.getFinancialSummary();
      print('✅ Financial data loaded');

      // Load previous messages
      print('🔵 Loading previous messages for session ${widget.sessionId}...');
      final messages = await chatRepository
          .watchMessagesBySession(widget.sessionId)
          .first;

      print('📊 Total messages found: ${messages.length}');
      print(
        '📊 Non-deleted messages: ${messages.where((m) => !m.isDeleted).length}',
      );

      if (mounted) {
        setState(() {
          _session = session;
          _financialContext = data;
          _isLoading = false;
        });

        // Reinitialize provider with actual data
        print('🔵 Reinitializing provider...');
        _initializeProvider();

        // Restore chat history
        final chatMessages = messages.where((m) => !m.isDeleted).map((m) {
          if (m.isUser) {
            print(
              '  👤 User: ${m.content.substring(0, m.content.length > 50 ? 50 : m.content.length)}...',
            );
            return ChatMessage.user(m.content, const []);
          } else {
            print(
              '  🤖 AI: ${m.content.substring(0, m.content.length > 50 ? 50 : m.content.length)}...',
            );
            final llmMsg = ChatMessage.llm();
            llmMsg.append(m.content);
            return llmMsg;
          }
        }).toList();

        print(
          '📝 Restoring ${chatMessages.length} messages to chat history...',
        );
        if (chatMessages.isNotEmpty && _provider != null) {
          _provider!.history = chatMessages;
          print('✅ Chat history restored successfully!');
        } else if (chatMessages.isEmpty) {
          print('⚠️ No messages to restore - chat is empty');
        }
      }

      print('🟢 === Session Load Complete ===\n');
    } catch (e) {
      print('❌ Error loading session: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _financialContext = 'Unable to load financial data: $e';
          _isLoading = false;
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

    _provider = _GeminiLlmProvider(model, onMessage: _saveMessage);
  }

  Future<void> _saveMessage(String content, bool isUser) async {
    if (!mounted) return;

    print(
      '💾 Saving ${isUser ? 'USER' : 'AI'} message to session ${widget.sessionId}',
    );
    print(
      '   Content: ${content.substring(0, content.length > 100 ? 100 : content.length)}...',
    );

    final chatRepository = ServiceProvider.of(context).chatRepository;

    final message = ChatMessageEntity(
      sessionId: widget.sessionId,
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    await chatRepository.addMessage(message);
    print('✅ Message saved to database');

    // Update session's last message time
    if (_session != null) {
      await chatRepository.updateChatSession(
        _session!.copyWith(lastMessageTime: DateTime.now()),
      );
      print('✅ Session timestamp updated');
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
            if (_isLoading)
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
  _GeminiLlmProvider(this._model, {this.onMessage});

  final GenerativeModel _model;
  final Future<void> Function(String, bool)? onMessage;
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
    final content = Content.text(prompt);
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
    // Save user message
    if (onMessage != null) {
      await onMessage!(prompt, true);
    }

    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    final content = Content.text(prompt);
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
}
