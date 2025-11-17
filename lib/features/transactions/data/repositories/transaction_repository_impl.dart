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
    final companion = TransactionMapper.toCompanion(transaction);
    return await _database.insertTransaction(companion);
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final companion = TransactionMapper.toCompanion(transaction);
    await _database.updateTransaction(companion);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _database.softDeleteTransaction(id);
  }
}
