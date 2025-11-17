import '../entities/transaction_entity.dart';

abstract class ITransactionRepository {
  /// Watch all transactions as a stream
  Stream<List<TransactionEntity>> watchAllTransactions();

  /// Get transactions by bank ID
  Future<List<TransactionEntity>> getTransactionsByBank(int bankId);

  /// Add a new transaction
  Future<int> addTransaction(TransactionEntity transaction);

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionEntity transaction);

  /// Delete a transaction (soft delete)
  Future<void> deleteTransaction(int id);
}
