import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer }

enum WalletType { cash, bank, ewallet }

class WalletModel {
  final String id;
  final String userId;
  final String name;
  final WalletType type;
  final double balance;
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: _walletTypeFromString(json['type'] as String?),
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.name,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static WalletType _walletTypeFromString(String? value) {
    switch (value) {
      case 'cash':
        return WalletType.cash;
      case 'bank':
        return WalletType.bank;
      case 'ewallet':
        return WalletType.ewallet;
      default:
        return WalletType.cash;
    }
  }
}

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final IconData? icon;
  final Color? color;
  final TransactionType type;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: _transactionTypeFromString(json['type'] as String?),
      icon: null,
      color: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.name,
    };
  }
}

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String? note;
  final String? categoryId;
  final String walletId;
  final String? toWalletId;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.walletId,
    required this.date,
    this.note,
    this.categoryId,
    this.toWalletId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _transactionTypeFromString(json['type'] as String?),
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0,
      note: json['note'] as String?,
      categoryId: json['category_id'] as String?,
      walletId: json['wallet_id'] as String,
      toWalletId: json['to_wallet_id'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'amount': amount,
      'note': note,
      'category_id': categoryId,
      'wallet_id': walletId,
      'to_wallet_id': toWalletId,
      'date': date.toIso8601String(),
    };
  }
}

TransactionType _transactionTypeFromString(String? value) {
  switch (value) {
    case 'income':
      return TransactionType.income;
    case 'expense':
      return TransactionType.expense;
    case 'transfer':
      return TransactionType.transfer;
    default:
      return TransactionType.expense;
  }
}


