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
        throw Exception(
          'Insufficient funds. Available: \$${bank.balance.toStringAsFixed(2)}, Required: \$${transaction.amount.toStringAsFixed(2)}',
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
    if (tx.bankId == null) return; // No associated bank
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
      case 'transfer':
        delta = 0; // no change (single-bank model)
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
