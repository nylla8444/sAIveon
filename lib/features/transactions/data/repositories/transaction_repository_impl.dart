import 'package:drift/drift.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/transaction_mapper.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  @override
  Stream<List<TransactionEntity>> watchAllTransactions() {
    return _database.watchAllTransactions().map(TransactionMapper.toDomainList);
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByBank(int bankId) async {
    final transactions = await _database.getTransactionsByBank(bankId);
    return TransactionMapper.toDomainList(transactions);
  }

  @override
  Future<int> addTransaction(TransactionEntity transaction) async {
    // Validate sufficient funds for 'send' transactions
    if (transaction.type == 'send' && transaction.bankId != null) {
      final bank = await _database.getBankById(transaction.bankId!);
      if (bank != null && bank.balance < transaction.amount) {
        // Note: Error messages use hardcoded $ as they are internal system messages
        throw Exception(
          'Insufficient funds. Available: \$${bank.balance.toStringAsFixed(2)}, Required: \$${transaction.amount.toStringAsFixed(2)}',
        );
      }
    }

    // Validate transfer has both source and destination banks
    if (transaction.type == 'transfer') {
      if (transaction.bankId == null || transaction.toBankId == null) {
        throw Exception('Transfer requires both source and destination banks');
      }
      if (transaction.bankId == transaction.toBankId) {
        throw Exception('Cannot transfer to the same bank');
      }
      final sourceBank = await _database.getBankById(transaction.bankId!);
      if (sourceBank != null && sourceBank.balance < transaction.amount) {
        // Note: Error messages use hardcoded $ as they are internal system messages
        throw Exception(
          'Insufficient funds in source bank. Available: \$${sourceBank.balance.toStringAsFixed(2)}, Required: \$${transaction.amount.toStringAsFixed(2)}',
        );
      }
    }

    final companion = TransactionMapper.toCompanion(transaction);
    final id = await _database.insertTransaction(companion);
    // Apply balance effect
    await _applyBalanceEffect(transaction.copyWith(id: id), revert: false);
    return id;
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    if (transaction.id != null) {
      final existing = await _database.getTransactionById(transaction.id!);
      if (existing != null) {
        // Revert old effect
        await _applyBalanceEffect(
          TransactionMapper.toDomain(existing),
          revert: true,
        );
      }
    }
    final companion = TransactionMapper.toCompanion(transaction);
    await _database.updateTransaction(companion);
    await _applyBalanceEffect(transaction, revert: false);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final existing = await _database.getTransactionById(id);
    if (existing != null) {
      await _applyBalanceEffect(
        TransactionMapper.toDomain(existing),
        revert: true,
      );
    }
    await _database.softDeleteTransaction(id);
  }

  Future<void> _applyBalanceEffect(
    TransactionEntity tx, {
    required bool revert,
  }) async {
    if (tx.type == 'transfer') {
      // Handle transfer between two banks
      if (tx.bankId == null || tx.toBankId == null) return;

      final sourceBank = await _database.getBankById(tx.bankId!);
      final destBank = await _database.getBankById(tx.toBankId!);

      if (sourceBank == null || destBank == null) return;

      // Amount to subtract from source (positive delta)
      // Amount to add to destination (positive delta)
      final delta = revert ? -tx.amount : tx.amount;

      // Update source bank (decrease balance)
      final newSourceBalance = sourceBank.balance - delta;
      await _database.updateBank(
        BanksCompanion(
          id: Value(sourceBank.id),
          name: Value(sourceBank.name),
          accountNumber: Value(sourceBank.accountNumber),
          balance: Value(newSourceBalance < 0 ? 0 : newSourceBalance),
          color: Value(sourceBank.color),
          logoPath: Value(sourceBank.logoPath),
          serverId: Value(sourceBank.serverId),
          createdAt: Value(sourceBank.createdAt),
          updatedAt: Value(DateTime.now()),
          isDeleted: Value(sourceBank.isDeleted),
        ),
      );

      // Update destination bank (increase balance)
      final newDestBalance = destBank.balance + delta;
      await _database.updateBank(
        BanksCompanion(
          id: Value(destBank.id),
          name: Value(destBank.name),
          accountNumber: Value(destBank.accountNumber),
          balance: Value(newDestBalance < 0 ? 0 : newDestBalance),
          color: Value(destBank.color),
          logoPath: Value(destBank.logoPath),
          serverId: Value(destBank.serverId),
          createdAt: Value(destBank.createdAt),
          updatedAt: Value(DateTime.now()),
          isDeleted: Value(destBank.isDeleted),
        ),
      );
      return;
    }

    // Handle send/receive for single bank
    if (tx.bankId == null) return;
    final bank = await _database.getBankById(tx.bankId!);
    if (bank == null) return;

    double delta = 0;
    switch (tx.type) {
      case 'receive':
        delta = tx.amount; // increase
        break;
      case 'send':
        delta = -tx.amount; // decrease
        break;
      default:
        delta = 0;
    }
    if (revert) delta = -delta;

    final newBalance = bank.balance + delta;
    await _database.updateBank(
      BanksCompanion(
        id: Value(bank.id),
        name: Value(bank.name),
        accountNumber: Value(bank.accountNumber),
        balance: Value(newBalance < 0 ? 0 : newBalance),
        color: Value(bank.color),
        logoPath: Value(bank.logoPath),
        serverId: Value(bank.serverId),
        createdAt: Value(bank.createdAt),
        updatedAt: Value(DateTime.now()),
        isDeleted: Value(bank.isDeleted),
      ),
    );
  }
}
