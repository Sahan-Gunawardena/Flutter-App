// lib/screens/add_sms_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

class AddSmsScreen extends ConsumerStatefulWidget {
  const AddSmsScreen({super.key});

  @override
  ConsumerState<AddSmsScreen> createState() => _AddSmsScreenState();
}

class _AddSmsScreenState extends ConsumerState<AddSmsScreen> {
  final _controller = TextEditingController();
  bool _hasError = false;
  TransactionCategory? _selectedCategory;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final before =
        ref.read(transactionsProvider).length;
    ref.read(transactionsProvider.notifier).addFromSms(text);
    final after = ref.read(transactionsProvider).length;

    if (after > before) {
      // If user selected a category, update it
      if (_selectedCategory != null) {
        final newTransaction = ref.read(transactionsProvider).first;
        ref
            .read(transactionsProvider.notifier)
            .updateCategory(newTransaction.id, _selectedCategory!);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A237E)),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paste a bank SMS message to parse and add as a transaction.',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              onChanged: (_) {
                if (_hasError) setState(() => _hasError = false);
              },
              decoration: InputDecoration(
                hintText:
                    'e.g. LKR 1,500.00 debited from AC **1234 via POS at PIZZA HUT ...',
                hintStyle:
                    TextStyle(fontSize: 13, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                errorText: _hasError
                    ? 'Could not parse this message. Check format and try again.'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButton<TransactionCategory?>(
                isExpanded: true,
                underline: const SizedBox(),
                value: _selectedCategory,
                hint: const Text(
                  'Category (optional - will auto-detect)',
                  style: TextStyle(color: Color(0xFF1A237E), fontSize: 14),
                ),
                items: [
                  const DropdownMenuItem<TransactionCategory?>(
                    value: null,
                    child: Text('Auto-detect from merchant'),
                  ),
                  ...TransactionCategory.values
                      .where((cat) => cat != TransactionCategory.income)
                      .map(
                        (category) => DropdownMenuItem<TransactionCategory?>(
                          value: category,
                          child: Row(
                            children: [
                              Text(category.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(category.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Parse & Add Transaction',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
