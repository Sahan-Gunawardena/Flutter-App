// lib/models/transaction.dart

/// Represents whether a transaction is money going out
/// (expense) or money coming in (income).
enum TransactionType {
  expense,
  income,
}

/// Categories used for automatic and manual transaction classification.
///
/// Auto-categorization is performed during SMS parsing,
/// but users can update the category later from the details screen.
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

/// Extension that provides UI-friendly values for each category.
///
/// Keeping display labels and icons here prevents business logic
/// from being mixed into UI widgets.
extension TransactionCategoryLabel on TransactionCategory {

  /// Human-readable category name displayed in the UI.
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

  /// Emoji used as a lightweight visual indicator
  /// for transaction categories.
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

/// Core domain model representing a parsed financial transaction.
///
/// Instances of this model are created by the SMS parser after
/// extracting information from bank SMS messages.
///
/// This model remains immutable to make state management with
/// Riverpod predictable and easier to maintain.
class Transaction {
  /// Unique identifier for the transaction.
  final String id;

  /// Transaction amount extracted from the SMS.
  final double amount;

  /// Expense or Income.
  final TransactionType type;

  /// Merchant or transaction description.
  final String merchant;

  /// Date and time parsed from the SMS message.
  final DateTime dateTime;

  /// Current category assigned to the transaction.
  ///
  /// Can be auto-generated or manually updated by the user.
  final TransactionCategory category;

  /// Masked account reference (e.g. **1114).
  final String accountRef;

  /// Original SMS message retained for debugging
  /// and displaying raw transaction information.
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

  /// Creates a modified copy of the transaction while
  /// preserving immutability.
  ///
  /// This is mainly used when updating categories through Riverpod.
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