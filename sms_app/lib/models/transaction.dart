// lib/models/transaction.dart

enum TransactionType { expense, income }

enum TransactionCategory {
  transport,
  groceries,
  fuel,
  food,
  shopping,
  utilities,
  health,
  entertainment,
  other,
  income,
}

extension TransactionCategoryLabel on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.fuel:
        return 'Fuel';
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.other:
        return 'Other';
      case TransactionCategory.income:
        return 'Income';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.transport:
        return '🚌';
      case TransactionCategory.groceries:
        return '🛒';
      case TransactionCategory.fuel:
        return '⛽';
      case TransactionCategory.food:
        return '🍽️';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.health:
        return '🏥';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.other:
        return '📦';
      case TransactionCategory.income:
        return '💰';
    }
  }
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String merchant;
  final DateTime dateTime;
  final TransactionCategory category;
  final String accountRef;
  final String rawMessage;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.merchant,
    required this.dateTime,
    required this.category,
    required this.accountRef,
    required this.rawMessage,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? merchant,
    DateTime? dateTime,
    TransactionCategory? category,
    String? accountRef,
    String? rawMessage,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      merchant: merchant ?? this.merchant,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      accountRef: accountRef ?? this.accountRef,
      rawMessage: rawMessage ?? this.rawMessage,
    );
  }
}
