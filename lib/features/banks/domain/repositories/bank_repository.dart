import '../entities/bank_entity.dart';

abstract class IBankRepository {
  /// Watch all banks as a stream
  Stream<List<BankEntity>> watchAllBanks();

  /// Get all banks (one-time fetch)
  Future<List<BankEntity>> getAllBanks();

  /// Get bank by ID
  Future<BankEntity?> getBankById(int id);

  /// Add a new bank
  Future<int> addBank(BankEntity bank);

  /// Update an existing bank
  Future<void> updateBank(BankEntity bank);

  /// Delete a bank (soft delete)
  Future<void> deleteBank(int id);
}
