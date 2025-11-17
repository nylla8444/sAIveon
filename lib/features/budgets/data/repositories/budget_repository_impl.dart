import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/budget_mapper.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final AppDatabase _database;

  BudgetRepositoryImpl(this._database);

  @override
  Stream<List<BudgetEntity>> watchAllBudgets() {
    return _database.watchAllBudgets().map(BudgetMapper.toDomainList);
  }

  @override
  Future<List<BudgetEntity>> getBudgetsByMonthYear(int month, int year) async {
    final budgets = await _database.getBudgetsByMonthYear(month, year);
    return BudgetMapper.toDomainList(budgets);
  }

  @override
  Future<int> addBudget(BudgetEntity budget) async {
    final companion = BudgetMapper.toCompanion(budget);
    return await _database.insertBudget(companion);
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    final companion = BudgetMapper.toCompanion(budget);
    await _database.updateBudget(companion);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await _database.softDeleteBudget(id);
  }
}
