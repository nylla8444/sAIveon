import 'package:equatable/equatable.dart';

class ScheduledPaymentEntity extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final String frequency;
  final DateTime nextPaymentDate;
  final int? expenseId; // link to spending category
  final int? bankId;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ScheduledPaymentEntity({
    this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextPaymentDate,
    this.expenseId,
    this.bankId,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  ScheduledPaymentEntity copyWith({
    int? id,
    String? name,
    double? amount,
    String? frequency,
    DateTime? nextPaymentDate,
    int? expenseId,
    int? bankId,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ScheduledPaymentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      expenseId: expenseId ?? this.expenseId,
      bankId: bankId ?? this.bankId,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    frequency,
    nextPaymentDate,
    expenseId,
    bankId,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
