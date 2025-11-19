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
  Future<BudgetEntity> getOrCreateMonthlyBudget(int month, int year) async {
    final budgets = await _database.getBudgetsByMonthYear(month, year);

    // Look for the monthly overall budget (special category)
    final monthlyBudget = budgets
        .where((b) => b.category == 'Monthly Overall')
        .firstOrNull;

    if (monthlyBudget != null) {
      return BudgetMapper.toDomain(monthlyBudget);
    }

    // Create default monthly budget if it doesn't exist
    final newBudget = BudgetEntity(
      category: 'Monthly Overall',
      budgetAmount: 5000.0, // Default limit
      spentAmount: 0.0,
      month: month,
      year: year,
      iconColor: 0xFFA882FF,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await addBudget(newBudget);
    return newBudget.copyWith(id: id);
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
