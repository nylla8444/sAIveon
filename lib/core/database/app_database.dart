import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ============================================================================
// Table Definitions
// ============================================================================

class Banks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get accountNumber => text().withLength(min: 1, max: 50)();
  RealColumn get balance => real()();
  TextColumn get color => text().withLength(min: 1, max: 20)();
  TextColumn get logoPath => text().nullable()();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  RealColumn get amount => real()();
  TextColumn get iconPath => text()();
  IntColumn get iconColor => integer()();
  IntColumn get bankId => integer().nullable().references(Banks, #id)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type =>
      text().withLength(min: 1, max: 20)(); // 'send', 'receive', or 'transfer'
  RealColumn get amount => real()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get iconPath => text()();
  TextColumn get status => text().withLength(min: 1, max: 20)();
  IntColumn get statusColor => integer()();
  IntColumn get bankId =>
      integer().nullable().references(Banks, #id)(); // source bank
  IntColumn get toBankId => integer().nullable().references(
    Banks,
    #id,
  )(); // destination bank for transfers
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  RealColumn get budgetAmount => real()();
  RealColumn get spentAmount => real().withDefault(const Constant(0.0))();
  IntColumn get month => integer()(); // 1-12
  IntColumn get year => integer()();
  IntColumn get iconColor => integer()();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class ScheduledPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  TextColumn get frequency =>
      text().withLength(min: 1, max: 20)(); // 'weekly', 'monthly', etc.
  DateTimeColumn get nextPaymentDate => dateTime()();
  IntColumn get bankId => integer().nullable().references(Banks, #id)();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get message => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withLength(
    min: 1,
    max: 50,
  )(); // 'transaction', 'budget', 'payment', etc.
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  DateTimeColumn get lastMessageTime =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get content => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// Pending operations queue for offline changes
class PendingOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType =>
      text().withLength(min: 1, max: 50)(); // 'bank', 'expense', etc.
  IntColumn get entityLocalId => integer()();
  TextColumn get operation =>
      text().withLength(min: 1, max: 20)(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON serialized entity
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

// ============================================================================
// Database Class
// ============================================================================

@DriftDatabase(
  tables: [
    Banks,
    Expenses,
    Transactions,
    Budgets,
    ScheduledPayments,
    Notifications,
    ChatSessions,
    ChatMessages,
    PendingOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          // Add toBankId column to transactions table for transfer support
          await m.addColumn(transactions, transactions.toBankId);
        }
      },
    );
  }

  // ============================================================================
  // Query Methods - Banks
  // ============================================================================

  Stream<List<Bank>> watchAllBanks() {
    return (select(banks)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<List<Bank>> getAllBanks() {
    return (select(banks)..where((tbl) => tbl.isDeleted.equals(false))).get();
  }

  Future<Bank?> getBankById(int id) {
    return (select(banks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertBank(BanksCompanion bank) {
    return into(banks).insert(bank);
  }

  Future<bool> updateBank(BanksCompanion bank) {
    return update(banks).replace(bank);
  }

  Future<int> softDeleteBank(int id) {
    return (update(banks)..where((tbl) => tbl.id.equals(id))).write(
      BanksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Expenses
  // ============================================================================

  Stream<List<Expense>> watchAllExpenses() {
    return (select(
      expenses,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<List<Expense>> getExpensesByBank(int bankId) {
    return (select(expenses)..where(
          (tbl) => tbl.bankId.equals(bankId) & tbl.isDeleted.equals(false),
        ))
        .get();
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  Future<bool> updateExpense(ExpensesCompanion expense) {
    return update(expenses).replace(expense);
  }

  Future<int> softDeleteExpense(int id) {
    return (update(expenses)..where((tbl) => tbl.id.equals(id))).write(
      ExpensesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Transactions
  // ============================================================================

  Stream<List<Transaction>> watchAllTransactions() {
    return (select(
      transactions,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<List<Transaction>> getTransactionsByBank(int bankId) {
    return (select(transactions)..where(
          (tbl) => tbl.bankId.equals(bankId) & tbl.isDeleted.equals(false),
        ))
        .get();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) {
    return update(transactions).replace(transaction);
  }

  Future<int> softDeleteTransaction(int id) {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Transaction?> getTransactionById(int id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ============================================================================
  // Query Methods - Budgets
  // ============================================================================

  Stream<List<Budget>> watchAllBudgets() {
    return (select(
      budgets,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<List<Budget>> getBudgetsByMonthYear(int month, int year) {
    return (select(budgets)..where(
          (tbl) =>
              tbl.month.equals(month) &
              tbl.year.equals(year) &
              tbl.isDeleted.equals(false),
        ))
        .get();
  }

  Future<int> insertBudget(BudgetsCompanion budget) {
    return into(budgets).insert(budget);
  }

  Future<bool> updateBudget(BudgetsCompanion budget) {
    return update(budgets).replace(budget);
  }

  Future<int> softDeleteBudget(int id) {
    return (update(budgets)..where((tbl) => tbl.id.equals(id))).write(
      BudgetsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Scheduled Payments
  // ============================================================================

  Stream<List<ScheduledPayment>> watchAllScheduledPayments() {
    return (select(
      scheduledPayments,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<int> insertScheduledPayment(ScheduledPaymentsCompanion payment) {
    return into(scheduledPayments).insert(payment);
  }

  Future<bool> updateScheduledPayment(ScheduledPaymentsCompanion payment) {
    return update(scheduledPayments).replace(payment);
  }

  Future<int> softDeleteScheduledPayment(int id) {
    return (update(scheduledPayments)..where((tbl) => tbl.id.equals(id))).write(
      ScheduledPaymentsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Notifications
  // ============================================================================

  Stream<List<Notification>> watchAllNotifications() {
    return (select(
      notifications,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<int> insertNotification(NotificationsCompanion notification) {
    return into(notifications).insert(notification);
  }

  Future<int> markNotificationAsRead(int id) {
    return (update(notifications)..where((tbl) => tbl.id.equals(id))).write(
      NotificationsCompanion(
        isRead: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> softDeleteNotification(int id) {
    return (update(notifications)..where((tbl) => tbl.id.equals(id))).write(
      NotificationsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Chat Sessions
  // ============================================================================

  Stream<List<ChatSession>> watchAllChatSessions() {
    return (select(chatSessions)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageTime)]))
        .watch();
  }

  Future<int> insertChatSession(ChatSessionsCompanion session) {
    return into(chatSessions).insert(session);
  }

  Future<bool> updateChatSession(ChatSessionsCompanion session) {
    return update(chatSessions).replace(session);
  }

  Future<int> softDeleteChatSession(int id) {
    return (update(chatSessions)..where((tbl) => tbl.id.equals(id))).write(
      ChatSessionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Chat Messages
  // ============================================================================

  Stream<List<ChatMessage>> watchMessagesBySession(int sessionId) {
    return (select(chatMessages)
          ..where(
            (tbl) =>
                tbl.sessionId.equals(sessionId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .watch();
  }

  Future<int> insertChatMessage(ChatMessagesCompanion message) {
    return into(chatMessages).insert(message);
  }

  Future<int> softDeleteChatMessage(int id) {
    return (update(chatMessages)..where((tbl) => tbl.id.equals(id))).write(
      ChatMessagesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Query Methods - Pending Operations
  // ============================================================================

  Stream<List<PendingOperation>> watchPendingOperations() {
    return (select(
      pendingOperations,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
  }

  Future<List<PendingOperation>> getAllPendingOperations() {
    return (select(
      pendingOperations,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  Future<int> insertPendingOperation(PendingOperationsCompanion operation) {
    return into(pendingOperations).insert(operation);
  }

  Future<int> deletePendingOperation(int id) {
    return (delete(pendingOperations)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> incrementRetryCount(int id) {
    return customUpdate(
      'UPDATE pending_operations SET retry_count = retry_count + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {pendingOperations},
    );
  }
}

// ============================================================================
// Connection Setup
// ============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_app.db'));

    // On Android, ensure sqlite3 library is available for older devices
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return driftDatabase(
      name: file.path,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  });
}
