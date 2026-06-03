// lib/screens/transaction_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transactions_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/summary_header.dart';
import '../widgets/category_filter_bar.dart';
import 'transaction_detail_screen.dart';
import 'add_sms_screen.dart';

/// Main dashboard screen of the application.
///
/// Responsibilities:
/// - Display all parsed transactions
/// - Display summary statistics
/// - Apply category filtering
/// - Navigate to transaction details
/// - Allow adding new SMS transactions
///
/// Business logic is handled by Riverpod providers,
/// while this screen focuses purely on presentation.
class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Listen to filtered transactions.
    //
    // This provider automatically updates whenever:
    // - Transactions are added
    // - Categories are changed
    // - Filters are applied
    final transactions =
        ref.watch(visibleTransactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Finance Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1A237E),
          ),
        ),

        actions: [

          // Allows users to manually add
          // and parse a new SMS message.
          IconButton(
            icon: const Icon(
              Icons.add_comment_outlined,
              color: Color(0xFF1A237E),
            ),

            tooltip: 'Add SMS',

            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AddSmsScreen(),
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 12),

          // Displays calculated totals
          // such as income and expenses.
          //
          // Values are derived from Riverpod
          // providers and update automatically.
          const SummaryHeader(),

          const SizedBox(height: 16),

          // Allows users to filter transactions
          // by category.
          const CategoryFilterBar(),

          const SizedBox(height: 12),

          // Displays number of currently
          // visible transactions.
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Text(
              '${transactions.length} transaction${transactions.length != 1 ? 's' : ''}',

              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade500,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: transactions.isEmpty

                // Display empty state when
                // no transactions match
                // the current filter.
                ? const _EmptyState()

                // Main transaction list.
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      bottom: 80,
                    ),

                    itemCount:
                        transactions.length,

                    itemBuilder:
                        (context, index) {

                      final t =
                          transactions[index];

                      return TransactionCard(

                        // Transaction card
                        // receives data only.
                        transaction: t,

                        // Navigate to details screen
                        // when a transaction is tapped.
                        onTap: () =>
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(
                              transactionId:
                                  t.id,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Reusable empty state shown when
/// no transactions are available.
///
/// This may happen when:
/// - No data exists
/// - A filter returns no results
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 12),

          Text(
            'No transactions found',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}