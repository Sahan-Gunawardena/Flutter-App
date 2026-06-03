// lib/providers/transactions_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/sms_parser.dart';
import '../services/sample_sms_data.dart';

// ─── State Notifier ──────────────────────────────────────────────────────────

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super([]) {
    _loadSampleData();
  }

  /// Parse all sample messages on startup.
  void _loadSampleData() {
    final parsed = SampleSmsData.messages
        .map(SmsParser.parse)
        .whereType<Transaction>()
        .toList();

    // Sort newest first
    parsed.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    state = parsed;
  }

  /// Parse and add a new SMS message to the list.
  void addFromSms(String rawMessage) {
    final transaction = SmsParser.parse(rawMessage);
    if (transaction == null) return;

    final updated = [transaction, ...state];
    updated.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    state = updated;
  }

  /// Update the category of a transaction identified by [id].
  void updateCategory(String id, TransactionCategory newCategory) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(category: newCategory) else t,
    ];
  }

  /// Remove a transaction by [id].
  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

/// The primary transactions list provider.
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>(
  (ref) => TransactionsNotifier(),
);

/// Derived: total expense amount across all transactions.
final totalExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Derived: total income amount across all transactions.
final totalIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Derived: transactions filtered by category (null = all).
final filteredTransactionsProvider =
    Provider.family<List<Transaction>, TransactionCategory?>((ref, category) {
  final all = ref.watch(transactionsProvider);
  if (category == null) return all;
  return all.where((t) => t.category == category).toList();
});

/// Selected category filter (null = show all).
final selectedCategoryFilterProvider =
    StateProvider<TransactionCategory?>((ref) => null);

/// Transactions after applying the selected filter.
final visibleTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(selectedCategoryFilterProvider);
  return ref.watch(filteredTransactionsProvider(filter));
});
