// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/transaction_list_screen.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod — wraps the entire widget tree.
    const ProviderScope(
      child: SmsFinanceApp(),
    ),
  );
}

class SmsFinanceApp extends StatelessWidget {
  const SmsFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A237E),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          surfaceTintColor: Colors.transparent,
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const TransactionListScreen(),
    );
  }
}
