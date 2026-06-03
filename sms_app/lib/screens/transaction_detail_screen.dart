// lib/screens/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

/// Displays complete information about a selected transaction.
///
/// This screen demonstrates:
/// - Navigation from the transaction list
/// - Viewing parsed transaction data
/// - Updating categories using Riverpod
/// - Automatic UI refresh when state changes
///
/// Instead of receiving a transaction object directly,
/// the screen reads data from the shared Riverpod state.
/// This ensures that updates remain synchronized across screens.
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the transaction provider so the screen
    // automatically rebuilds whenever transaction data changes.
    final all = ref.watch(transactionsProvider);

    final transaction = all.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => throw StateError('Transaction not found'),
    );

    // Determine transaction type for styling.
    // Expenses are shown in red, income in green.
    final isExpense =
        transaction.type == TransactionType.expense;

    final amountColor =
        isExpense
            ? const Color(0xFFE53935)
            : const Color(0xFF43A047);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: const BackButton(
          color: Color(0xFF1A237E),
        ),

        title: const Text(
          'Transaction Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A237E),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Summary card showing key transaction information:
            // - Category icon
            // - Merchant name
            // - Amount
            // - Expense/Income status
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color: Colors.grey.shade100,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Text(
                    transaction.category.emoji,
                    style: const TextStyle(
                      fontSize: 48,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    transaction.merchant,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${isExpense ? '- ' : '+ '}LKR ${NumberFormat('#,##0.00').format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.w800,
                      color: amountColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: isExpense
                          ? const Color(
                              0xFFFCE4EC,
                            )
                          : const Color(
                              0xFFE8F5E9,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),

                    child: Text(
                      isExpense
                          ? 'EXPENSE'
                          : 'INCOME',

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color: amountColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detailed information extracted
            // from the SMS message.
            _DetailSection(
              title: 'Transaction Info',

              rows: [
                _DetailRow(
                  icon:
                      Icons.calendar_today_outlined,
                  label: 'Date',
                  value: DateFormat(
                    'EEEE, d MMMM yyyy',
                  ).format(
                    transaction.dateTime,
                  ),
                ),

                _DetailRow(
                  icon:
                      Icons.access_time_outlined,
                  label: 'Time',
                  value: DateFormat(
                    'HH:mm:ss',
                  ).format(
                    transaction.dateTime,
                  ),
                ),

                _DetailRow(
                  icon:
                      Icons.credit_card_outlined,
                  label: 'Account',
                  value:
                      transaction.accountRef,
                ),

                _DetailRow(
                  icon:
                      Icons.category_outlined,
                  label: 'Category',
                  value:
                      '${transaction.category.emoji} ${transaction.category.label}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Displays the original SMS message.
            //
            // Useful for:
            // - Verifying parser accuracy
            // - Debugging
            // - Demonstrating extraction logic
            _DetailSection(
              title: 'Raw SMS',
              rows: const [],

              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color:
                        Colors.grey.shade200,
                  ),
                ),

                child: Text(
                  transaction.rawMessage,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color:
                        Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Allows users to manually update
            // the category assigned by the parser.
            //
            // Changes are stored in Riverpod state
            // and immediately reflected across screens.
            _CategoryUpdateSection(
              transaction: transaction,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable widget responsible for
/// updating transaction categories.
///
/// Uses Riverpod to modify shared state,
/// ensuring updates are reflected instantly
/// on all listening screens.
class _CategoryUpdateSection
    extends ConsumerWidget {

  const _CategoryUpdateSection({
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Change Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children:
                TransactionCategory.values
                    .map((cat) {
              final isSelected =
                  cat == transaction.category;

              return GestureDetector(
                onTap: () {
                  if (isSelected) return;

                  // Update category through
                  // Riverpod notifier.
                  ref
                      .read(
                        transactionsProvider
                            .notifier,
                      )
                      .updateCategory(
                        transaction.id,
                        cat,
                      );

                  // Provide immediate feedback
                  // after successful update.
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Category updated to ${cat.label}',
                      ),
                      duration:
                          const Duration(
                        seconds: 2,
                      ),
                      behavior:
                          SnackBarBehavior
                              .floating,
                    ),
                  );
                },

                child: AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(
                            0xFF1A237E,
                          )
                        : Colors
                            .grey.shade100,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    border: Border.all(
                      color: isSelected
                          ? const Color(
                              0xFF1A237E,
                            )
                          : Colors.grey
                              .shade200,
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      Text(
                        cat.emoji,
                        style:
                            const TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey
                                  .shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Generic section widget used throughout
/// the details screen.
///
/// Helps maintain a consistent layout and
/// reduces duplicated UI code.
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.rows,
    this.child,
  });

  final String title;
  final List<_DetailRow> rows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          if (child != null) ...[
            child!,
          ],

          ...rows,
        ],
      ),
    );
  }
}

/// Reusable row widget used for displaying
/// label-value pairs.
///
/// Examples:
/// Date → 25 March 2026
/// Account → **1114
/// Category → Fuel
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade400,
          ),

          const SizedBox(width: 10),

          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color:
                  Colors.grey.shade500,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}