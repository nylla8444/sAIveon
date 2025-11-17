import '../../domain/entities/bank_entity.dart';
import '../../domain/repositories/bank_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/bank_mapper.dart';

class BankRepositoryImpl implements IBankRepository {
  final AppDatabase _database;

  BankRepositoryImpl(this._database);

  @override
  Stream<List<BankEntity>> watchAllBanks() {
    return _database.watchAllBanks().map(BankMapper.toDomainList);
  }

  @override
  Future<List<BankEntity>> getAllBanks() async {
    final banks = await _database.getAllBanks();
    return BankMapper.toDomainList(banks);
  }

  @override
  Future<BankEntity?> getBankById(int id) async {
    final bank = await _database.getBankById(id);
    return bank != null ? BankMapper.toDomain(bank) : null;
  }

  @override
  Future<int> addBank(BankEntity bank) async {
    final companion = BankMapper.toCompanion(bank);
    return await _database.insertBank(companion);
  }

  @override
  Future<void> updateBank(BankEntity bank) async {
    final companion = BankMapper.toCompanion(bank);
    await _database.updateBank(companion);
  }

  @override
  Future<void> deleteBank(int id) async {
    await _database.softDeleteBank(id);
  }
}
