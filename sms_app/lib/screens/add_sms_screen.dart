// lib/screens/add_sms_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

/// Screen that allows users to manually paste
/// a bank SMS message and convert it into a transaction.
///
/// Parsing logic remains inside the provider/service layer.
/// This screen is responsible only for collecting input
/// and triggering state updates.
class AddSmsScreen extends ConsumerStatefulWidget {
  const AddSmsScreen({super.key});

  @override
  ConsumerState<AddSmsScreen> createState() =>
      _AddSmsScreenState();
}

class _AddSmsScreenState
    extends ConsumerState<AddSmsScreen> {

  /// Controller used to read SMS input text.
  final _controller = TextEditingController();

  /// Controls validation error display.
  bool _hasError = false;

  /// Optional category selected by the user.
  ///
  /// If null, the parser's auto-categorization logic is used.
  TransactionCategory? _selectedCategory;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Attempts to parse the entered SMS message.
  ///
  /// Workflow:
  /// 1. Read user input
  /// 2. Send SMS to Riverpod notifier
  /// 3. Check if parsing succeeded
  /// 4. Apply custom category if selected
  /// 5. Return to previous screen
  void _submit() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    // Used to verify whether a new transaction
    // was successfully added.
    final before =
        ref.read(transactionsProvider).length;

    ref
        .read(transactionsProvider.notifier)
        .addFromSms(text);

    final after =
        ref.read(transactionsProvider).length;

    if (after > before) {

      // Override auto-detected category if the
      // user selected a specific category.
      if (_selectedCategory != null) {
        final newTransaction =
            ref.read(transactionsProvider).first;

        ref
            .read(
              transactionsProvider.notifier,
            )
            .updateCategory(
              newTransaction.id,
              _selectedCategory!,
            );
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction added successfully!',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } else {

      // Display validation error if parsing fails.
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Light background for cleaner appearance.
      backgroundColor:
          const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: const BackButton(
          color: Color(0xFF1A237E),
        ),

        title: const Text(
          'Add SMS Message',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A237E),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            /// Information banner explaining
            /// how the feature works.
            Container(
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade100,
                ),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Paste a bank SMS message to parse and add as a transaction.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// SMS input field.
            ///
            /// User pastes a bank SMS message here.
            TextField(
              controller: _controller,
              maxLines: 8,

              onChanged: (_) {
                if (_hasError) {
                  setState(
                    () => _hasError = false,
                  );
                }
              },

              decoration: InputDecoration(
                hintText:
                    'e.g. LKR 1,500.00 debited from AC **1234 via POS at PIZZA HUT',

                filled: true,
                fillColor: Colors.white,

                errorText: _hasError
                    ? 'Could not parse this message. Check format and try again.'
                    : null,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Optional category selector.
            ///
            /// Allows users to override
            /// automatic categorization.
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child:
                  DropdownButton<TransactionCategory?>(
                isExpanded: true,
                underline: const SizedBox(),

                value: _selectedCategory,

                hint: const Text(
                  'Category (optional - will auto-detect)',
                ),

                items: [

                  // Default auto-detection option.
                  const DropdownMenuItem<
                      TransactionCategory?>(
                    value: null,
                    child: Text(
                      'Auto-detect from merchant',
                    ),
                  ),

                  // Dynamically build category list.
                  ...TransactionCategory.values
                      .where(
                        (cat) =>
                            cat !=
                            TransactionCategory
                                .income,
                      )
                      .map(
                        (category) =>
                            DropdownMenuItem<
                                TransactionCategory?>(
                          value: category,

                          child: Row(
                            children: [
                              Text(
                                category.emoji,
                              ),
                              const SizedBox(
                                  width: 8),
                              Text(
                                category.label,
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                onChanged: (value) {
                  setState(
                    () =>
                        _selectedCategory =
                            value,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// Submit button.
            ///
            /// Triggers SMS parsing and
            /// transaction creation.
            ElevatedButton(
              onPressed: _submit,

              child: const Text(
                'Parse & Add Transaction',
              ),
            ),
          ],
        ),
      ),
    );
  }
}