import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/expense_mapper.dart';

class ExpenseRepositoryImpl implements IExpenseRepository {
  final AppDatabase _database;

  ExpenseRepositoryImpl(this._database);

  @override
  Stream<List<ExpenseEntity>> watchAllExpenses() {
    return _database.watchAllExpenses().map(ExpenseMapper.toDomainList);
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByBank(int bankId) async {
    final expenses = await _database.getExpensesByBank(bankId);
    return ExpenseMapper.toDomainList(expenses);
  }

  @override
  Future<int> addExpense(ExpenseEntity expense) async {
    final companion = ExpenseMapper.toCompanion(expense);
    return await _database.insertExpense(companion);
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final companion = ExpenseMapper.toCompanion(expense);
    await _database.updateExpense(companion);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _database.softDeleteExpense(id);
  }
}
