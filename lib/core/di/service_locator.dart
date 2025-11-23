import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../sync/sync_service.dart';
import '../services/scheduled_payment_notification_service.dart';
import '../services/connectivity_service.dart';
import '../services/currency_service.dart';
import '../../features/banks/data/repositories/bank_repository_impl.dart';
import '../../features/banks/domain/repositories/bank_repository.dart';
import '../../features/banks/domain/entities/bank_entity.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/scheduled_payments/data/repositories/scheduled_payment_repository_impl.dart';
import '../../features/scheduled_payments/domain/repositories/scheduled_payment_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/ai_chat/data/repositories/chat_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/chat_repository.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Core services
  late final AppDatabase _database;
  late final ApiClient _apiClient;
  late final SyncService _syncService;
  late final ConnectivityService _connectivityService;
  late final CurrencyService _currencyService;
  late final ScheduledPaymentNotificationService
  _scheduledPaymentNotificationService;

  // Repositories
  late final IBankRepository _bankRepository;
  late final IExpenseRepository _expenseRepository;
  late final ITransactionRepository _transactionRepository;
  late final IBudgetRepository _budgetRepository;
  late final IScheduledPaymentRepository _scheduledPaymentRepository;
  late final INotificationRepository _notificationRepository;
  late final IChatRepository _chatRepository;

  bool _isInitialized = false;

  /// Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('  → Initializing database...');
    _database = AppDatabase();
    print('  ✓ Database initialized');

    print('  → Initializing connectivity service...');
    _connectivityService = ConnectivityService();
    print('  ✓ Connectivity service initialized');

    print('  → Initializing currency service...');
    _currencyService = CurrencyService();
    await _currencyService.initialize();
    print('  ✓ Currency service initialized');

    print('  → Initializing API client...');
    _apiClient = ApiClient();
    print('  ✓ API client initialized');

    print('  → Initializing sync service...');
    _syncService = SyncService(_database, _apiClient);
    await _syncService.initialize();
    print('  ✓ Sync service initialized');

    print('  → Initializing repositories...');
    _bankRepository = BankRepositoryImpl(_database);
    _expenseRepository = ExpenseRepositoryImpl(_database);
    _transactionRepository = TransactionRepositoryImpl(_database);
    _budgetRepository = BudgetRepositoryImpl(_database);
    _scheduledPaymentRepository = ScheduledPaymentRepositoryImpl(_database);
    _notificationRepository = NotificationRepositoryImpl(_database);
    _chatRepository = ChatRepositoryImpl(_database);
    print('  ✓ All repositories initialized');

    print('  → Initializing scheduled payment notification service...');
    _scheduledPaymentNotificationService = ScheduledPaymentNotificationService(
      _scheduledPaymentRepository,
      _notificationRepository,
    );
    _scheduledPaymentNotificationService.initialize();
    print('  ✓ Scheduled payment notification service initialized');

    // Debug verification & optional seeding
    await _runDebugVerification();

    _isInitialized = true;
  }

  Future<void> _runDebugVerification() async {
    try {
      final existingBanks = await _bankRepository.getAllBanks();
      print('  [DB] Bank count before seed: ${existingBanks.length}');
      if (existingBanks.isEmpty) {
        print('  [DB] Seeding sample bank...');
        await _bankRepository.addBank(
          BankEntity(
            id: null,
            name: 'Sample Bank',
            accountNumber: '0000-1234',
            balance: 1500.00,
            color: '#A882FF',
            logoPath: null,
            serverId: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
          ),
        );
        final afterSeed = await _bankRepository.getAllBanks();
        print('  [DB] Bank count after seed: ${afterSeed.length}');
      }
    } catch (e) {
      print('  [DB] Verification error: $e');
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    _scheduledPaymentNotificationService.dispose();
    _syncService.dispose();
    _connectivityService.dispose();
    await _database.close();
  }

  // Getters for services
  AppDatabase get database => _database;
  ApiClient get apiClient => _apiClient;
  SyncService get syncService => _syncService;
  ConnectivityService get connectivityService => _connectivityService;
  CurrencyService get currencyService => _currencyService;

  // Getters for repositories
  IBankRepository get bankRepository => _bankRepository;
  IExpenseRepository get expenseRepository => _expenseRepository;
  ITransactionRepository get transactionRepository => _transactionRepository;
  IBudgetRepository get budgetRepository => _budgetRepository;
  IScheduledPaymentRepository get scheduledPaymentRepository =>
      _scheduledPaymentRepository;
  INotificationRepository get notificationRepository => _notificationRepository;
  IChatRepository get chatRepository => _chatRepository;
}

/// InheritedWidget to provide ServiceLocator throughout the widget tree
class ServiceProvider extends InheritedWidget {
  final ServiceLocator serviceLocator;

  const ServiceProvider({
    Key? key,
    required this.serviceLocator,
    required Widget child,
  }) : super(key: key, child: child);

  static ServiceLocator of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ServiceProvider>();
    assert(provider != null, 'No ServiceProvider found in context');
    return provider!.serviceLocator;
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) => false;
}
