// lib/services/sms_parser.dart

import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

/// Pure parsing logic — no Flutter/UI imports.
/// Responsible for converting raw SMS text into [Transaction] objects.
class SmsParser {
  static const _uuid = Uuid();

  /// Attempts to parse [message] into a [Transaction].
  /// Returns null if the message is not a recognisable transaction SMS.
  static Transaction? parse(String message) {
    final normalized = message.trim();

    final amount = _extractAmount(normalized);
    if (amount == null) return null;

    final type = _extractType(normalized);
    if (type == null) return null;

    final merchant = _extractMerchant(normalized);
    final accountRef = _extractAccountRef(normalized);
    final dateTime = _extractDateTime(normalized) ?? DateTime.now();
    final category = _categorize(merchant, type);

    return Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      merchant: merchant,
      dateTime: dateTime,
      category: category,
      accountRef: accountRef,
      rawMessage: message,
    );
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  /// Extracts numeric amount, handling comma-formatted numbers.
  /// Supports patterns like: LKR 1,692.00 / Rs. 500 / USD 20.50
  static double? _extractAmount(String msg) {
    final pattern = RegExp(
      r'(?:LKR|Rs\.?|USD|EUR|GBP)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(msg);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(',', '');
    return double.tryParse(raw);
  }

  /// Determines whether the transaction is a debit (expense) or credit (income).
  static TransactionType? _extractType(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('debit') || lower.contains('debited')) {
      return TransactionType.expense;
    }
    if (lower.contains('credit') || lower.contains('credited')) {
      return TransactionType.income;
    }
    return null;
  }

  /// Extracts merchant / description from common SMS patterns.
  /// Handles:
  ///   • "via POS at MERCHANT_NAME <code>"
  ///   • "via MERCHANT_NAME"
  ///   • "at MERCHANT_NAME"
  ///   • "to MERCHANT_NAME"
  static String _extractMerchant(String msg) {
    // Pattern 1: "via POS at MERCHANT 12345678"
    var posPattern = RegExp(
      r'via\s+POS\s+at\s+([A-Za-z0-9 &\-\.]+?)(?:\s+\d{4,}|\n|$)',
      caseSensitive: false,
    );
    var match = posPattern.firstMatch(msg);
    if (match != null) return _cleanMerchant(match.group(1)!);

    // Pattern 2: "via MERCHANT_NAME" (for transfers, etc.)
    var viaPattern = RegExp(
      r'via\s+([A-Za-z0-9 &\-\.]+?)(?:\n|$)',
      caseSensitive: false,
    );
    match = viaPattern.firstMatch(msg);
    if (match != null) {
      final merchant = _cleanMerchant(match.group(1)!);
      // Avoid generic terms like "POS", "ONLINE TRANSFER"
      if (merchant.length > 3 && !merchant.toUpperCase().contains('ONLINE')) {
        return merchant;
      }
    }

    // Pattern 3: "at MERCHANT"
    var atPattern = RegExp(
      r'\bat\s+([A-Za-z0-9 &\-\.]+?)(?:\s*\n|\s+\d{4,}|$)',
      caseSensitive: false,
    );
    match = atPattern.firstMatch(msg);
    if (match != null) return _cleanMerchant(match.group(1)!);

    // Pattern 4: "to MERCHANT"
    var toPattern = RegExp(
      r'\bto\s+([A-Za-z0-9 &\-\.]+?)(?:\s*\n|\s+\d{4,}|$)',
      caseSensitive: false,
    );
    match = toPattern.firstMatch(msg);
    if (match != null) return _cleanMerchant(match.group(1)!);

    // Fallback: Try to extract anything after "debited/credited from/to"
    var fallbackPattern = RegExp(
      r'(?:debited|credited).{0,50}?(?:at|to|via)\s+([A-Za-z0-9 &\-\.]+)',
      caseSensitive: false,
    );
    match = fallbackPattern.firstMatch(msg);
    if (match != null) return _cleanMerchant(match.group(1)!);

    return 'Unknown Merchant';
  }

  static String _cleanMerchant(String raw) {
    var cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    // Remove trailing numbers/codes
    cleaned = cleaned.replaceAll(RegExp(r'\s+\d+$'), '');
    return cleaned;
  }

  /// Extracts masked account reference, e.g. **1111 → AC **1111
  static String _extractAccountRef(String msg) {
    final pattern = RegExp(r'AC\s*(\*+\d+)', caseSensitive: false);
    final match = pattern.firstMatch(msg);
    return match != null ? 'AC ${match.group(1)}' : 'N/A';
  }

  /// Parses date/time in the format dd/MM/yyyy HH:mm:ss
  static DateTime? _extractDateTime(String msg) {
    final pattern = RegExp(
      r'(\d{2}/\d{2}/\d{4})\s+(\d{2}:\d{2}:\d{2})',
    );
    final match = pattern.firstMatch(msg);
    if (match == null) return null;

    final dateParts = match.group(1)!.split('/');
    final timeParts = match.group(2)!.split(':');

    return DateTime(
      int.parse(dateParts[2]), // year
      int.parse(dateParts[1]), // month
      int.parse(dateParts[0]), // day
      int.parse(timeParts[0]), // hour
      int.parse(timeParts[1]), // minute
      int.parse(timeParts[2]), // second
    );
  }

  /// Rule-based auto-categorisation from merchant name keywords.
  static TransactionCategory _categorize(
    String merchant,
    TransactionType type,
  ) {
    if (type == TransactionType.income) return TransactionCategory.income;

    final lower = merchant.toLowerCase();

    if (_matchesAny(lower, ['interchange', 'highway', 'toll', 'bus', 'train',
        'taxi', 'uber', 'pickme', 'transport', 'transit'])) {
      return TransactionCategory.transport;
    }
    if (_matchesAny(lower, ['super', 'supermarket', 'grocery', 'keells',
        'cargills', 'spar', 'arpico', 'laugfs', 'market', 'fresh'])) {
      return TransactionCategory.groceries;
    }
    if (_matchesAny(lower, ['fuel', 'petrol', 'gas', 'filling', 'ceypetco',
        'ioc', 'fuel mart', 'station', 'energy'])) {
      return TransactionCategory.fuel;
    }
    if (_matchesAny(lower, ['restaurant', 'cafe', 'kfc', 'mcd', 'pizza',
        'burger', 'dine', 'food', 'eat', 'kitchen', 'bakery'])) {
      return TransactionCategory.food;
    }
    if (_matchesAny(lower, ['pharmacy', 'hospital', 'clinic', 'medical',
        'health', 'doctor', 'lab', 'dispensary'])) {
      return TransactionCategory.health;
    }
    if (_matchesAny(lower, ['cinema', 'movie', 'theatre', 'concert',
        'entertainment', 'game', 'sport'])) {
      return TransactionCategory.entertainment;
    }
    if (_matchesAny(lower, ['water', 'electricity', 'electric', 'leco',
        'nwsdb', 'dialog', 'mobitel', 'hutch', 'airtel', 'internet',
        'broadband', 'utility'])) {
      return TransactionCategory.utilities;
    }
    if (_matchesAny(lower, ['mall', 'shop', 'store', 'boutique', 'fashion',
        'clothing', 'amazon', 'daraz'])) {
      return TransactionCategory.shopping;
    }

    return TransactionCategory.other;
  }

  static bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw));
}
