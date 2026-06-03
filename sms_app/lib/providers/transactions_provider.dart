// lib/providers/transactions_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/sms_parser.dart';
import '../services/sample_sms_data.dart';

/// Manages the application's transaction state.
///
/// This notifier is responsible for:
/// - Loading initial SMS data
/// - Parsing new SMS messages
/// - Updating transaction categories
/// - Removing transactions
///
/// Business logic is kept here instead of UI widgets
/// to maintain a clean architecture.
class TransactionsNotifier extends StateNotifier<List<Transaction>> {

  TransactionsNotifier() : super([]) {
    _loadSampleData();
  }

  /// Loads sample SMS messages when the app starts.
  ///
  /// Each SMS is parsed into a Transaction object,
  /// then sorted so the newest transactions appear first.
  void _loadSampleData() {
    final parsed = SampleSmsData.messages
        .map(SmsParser.parse)
        .whereType<Transaction>()
        .toList();

    // Display latest transactions first.
    parsed.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    state = parsed;
  }

  /// Parses a newly received SMS and adds it
  /// to the transaction list.
  ///
  /// Invalid messages are ignored.
  void addFromSms(String rawMessage) {
    final transaction = SmsParser.parse(rawMessage);

    if (transaction == null) return;

    final updated = [transaction, ...state];

    // Keep list ordered by newest transaction.
    updated.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    state = updated;
  }

  /// Updates the category of a specific transaction.
  ///
  /// Uses copyWith() to preserve immutability,
  /// which works well with Riverpod state updates.
  void updateCategory(
    String id,
    TransactionCategory newCategory,
  ) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(category: newCategory)
        else
          t,
    ];
  }

  /// Removes a transaction from the state.
  void remove(String id) {
    state = state
        .where((t) => t.id != id)
        .toList();
  }
}

/// Primary Riverpod provider that exposes
/// the transaction list throughout the app.
///
/// UI screens subscribe to this provider
/// and automatically rebuild when state changes.
final transactionsProvider =
    StateNotifierProvider<
        TransactionsNotifier,
        List<Transaction>>(
  (ref) => TransactionsNotifier(),
);

/// Calculates total expenses dynamically.
///
/// This is a derived provider, meaning
/// the value is automatically recalculated
/// whenever the transaction list changes.
final totalExpenseProvider =
    Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where(
        (t) => t.type ==
            TransactionType.expense,
      )
      .fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
});

/// Calculates total income dynamically.
final totalIncomeProvider =
    Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where(
        (t) => t.type ==
            TransactionType.income,
      )
      .fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
});

/// Returns transactions filtered by category.
///
/// If category is null, all transactions
/// are returned.
final filteredTransactionsProvider =
    Provider.family<
        List<Transaction>,
        TransactionCategory?>(
  (ref, category) {
    final all =
        ref.watch(transactionsProvider);

    if (category == null) {
      return all;
    }

    return all
        .where(
          (t) =>
              t.category == category,
        )
        .toList();
  },
);

/// Stores the currently selected filter
/// from the UI.
///
/// Null means "show all categories".
final selectedCategoryFilterProvider =
    StateProvider<TransactionCategory?>(
  (ref) => null,
);

/// Final list displayed on screen.
///
/// Combines:
/// - Current transactions
/// - Selected category filter
///
/// This keeps filtering logic out of UI widgets.
final visibleTransactionsProvider =
    Provider<List<Transaction>>((ref) {
  final filter = ref.watch(
    selectedCategoryFilterProvider,
  );

  return ref.watch(
    filteredTransactionsProvider(
      filter,
    ),
  );
});