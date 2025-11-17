import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final int? id;
  final String category;
  final double amount;
  final String iconPath;
  final int iconColor;
  final int? bankId;
  final String? description;
  final DateTime date;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ExpenseEntity({
    this.id,
    required this.category,
    required this.amount,
    required this.iconPath,
    required this.iconColor,
    this.bankId,
    this.description,
    required this.date,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  ExpenseEntity copyWith({
    int? id,
    String? category,
    double? amount,
    String? iconPath,
    int? iconColor,
    int? bankId,
    String? description,
    DateTime? date,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      iconPath: iconPath ?? this.iconPath,
      iconColor: iconColor ?? this.iconColor,
      bankId: bankId ?? this.bankId,
      description: description ?? this.description,
      date: date ?? this.date,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    amount,
    iconPath,
    iconColor,
    bankId,
    description,
    date,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
