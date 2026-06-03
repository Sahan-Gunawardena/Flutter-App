#  SMS Finance Tracker

A Flutter MVP application that reads bank SMS messages, extracts transaction details automatically, and categorizes them. Built with **clean architecture** principles, **Riverpod** for state management, and **regex-based parsing** for robust SMS handling.


##  Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- Android Studio / Xcode (for emulator/device)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Flutter-App/sms_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Troubleshooting

If you get disk space errors:
```bash
flutter clean
dart cache clean
flutter pub get
flutter run
```

##  Project Structure

```
lib/
├── main.dart                           # App entry point, ProviderScope
│
├── models/
│   └── transaction.dart                # Transaction, TransactionType, TransactionCategory
│                                        # Enums with label and emoji extensions
│
├── services/
│   ├── sms_parser.dart                # Pure parsing logic (no Flutter imports)
│   │                                   # - 5 merchant extraction patterns
│   │                                   # - Auto-categorization by keywords
│   │                                   # - Regex-based extraction
│   └── sample_sms_data.dart           # 10 sample SMS for demo
│
├── providers/
│   └── transactions_provider.dart      # Riverpod state management
│                                        # - TransactionsNotifier (add, update, remove)
│                                        # - Derived providers (totals, filtering)
│
├── screens/
│   ├── transaction_list_screen.dart    # Main dashboard
│   │                                   # - Summary header
│   │                                   # - Category filter bar
│   │                                   # - Transaction list
│   ├── add_sms_screen.dart            # Add new SMS screen
│   │                                   # - SMS input field
│   │                                   # - Category dropdown
│   │                                   # - Error handling
│   └── transaction_detail_screen.dart  # Transaction details + category update
│
└── widgets/
    ├── transaction_card.dart           # List item component
    ├── summary_header.dart             # Balance header component
    └── category_filter_bar.dart        # Category filter chips
```

##  How to Use

### 1. View Transaction List (Default)
- App loads with 10 sample SMS transactions
- Transactions sorted by date (newest first)
- View balance, income, expenses in header

### 2. Add New SMS
1. Tap **➕** button in app bar
2. Paste bank SMS message:
   ```
   LKR 1,692.00 debited from AC **1114 via POS at KEELLS SUPER - KOTTAWA 10402483
   25/03/2026 17:46:49
   ```
3. **(Optional)** Select category from dropdown (auto-detected if not selected)
4. Tap **"Parse & Add Transaction"**
5. Transaction appears in list immediately

### 3. View Transaction Details
1. Tap any transaction card in the list
2. See complete parsed information:
   - Amount with currency
   - Date and time
   - Account reference
   - Category (with emoji)
   - Raw SMS message

### 4. Change Category
1. Open transaction details
2. Scroll to **"Change Category"** section
3. Tap a category chip to select
4. List screen updates automatically (reactivity!)
5. SnackBar shows confirmation

### 5. Filter by Category
1. Tap category chips in **Category Filter Bar** (top)
2. " All" - show all transactions
3. Category chips - show only that category
4. Transaction count updates automatically

## 🔍 SMS Parsing Example

### Input
```
LKR 1,692.00 debited from AC **1114 via POS at KEELLS SUPER - KOTTAWA 10402483
25/03/2026 17:46:49
To Inq Call 0112303050
Get protected - Do not Share OTP
```


### How It Works

1. **Amount Extraction** 
   - Pattern: `(?:LKR|Rs\.?|USD|EUR|GBP)\s*([\d,]+(?:\.\d{1,2})?)`
   - Handles comma formatting: 1,692.00 → 1692.0

2. **Type Detection** 
   - "debited/debit" → Expense
   - "credited/credit" → Income

3. **Merchant Extraction** 
   - **Pattern 1**: `via POS at MERCHANT 12345678`
   - **Pattern 2**: `via MERCHANT_NAME`
   - **Pattern 3**: `at MERCHANT`
   - **Pattern 4**: `to MERCHANT`
   - **Pattern 5**: Fallback fuzzy matching

4. **Auto-Categorization** 
   - Keyword matching on merchant name (case-insensitive)
   - Examples:
     - "KEELLS" → groceries
     - "KOTTAWA INTERCHANGE" → transport
     - "PIZZA HUT" → food

##  Sample SMS Messages (Built-in)

The app includes 10 sample transactions for demo:

```
1. LKR 150.00 debited @ KOTTAWA INTERCHANGE →  Transport
2. LKR 1,692.00 debited @ KEELLS SUPER →  Groceries
3. LKR 5,970.00 debited @ P AND B FUEL MART →  Fuel
4. LKR 3,450.00 credited via ONLINE TRANSFER →  Income
5. LKR 850.00 debited @ KFC COLOMBO 7 →  Food
6. LKR 2,200.00 debited @ LAUGFS FUEL STATION →  Fuel
7. LKR 15,000.00 credited via SALARY CREDIT →  Income
8. LKR 450.00 debited @ EXCEL WORLD CINEMA →  Entertainment
9. LKR 1,100.00 debited @ CARGILLS FOOD CITY →  Groceries
10. LKR 3,750.00 debited @ DARAZ ONLINE SHOPPING →  Shopping
```

##  Testing

### Valid SMS Examples to Test
```
LKR 500 debited from AC **1111 via POS at Pizza Hut 123456 28/03/2026 15:30:00
LKR 2000 credited via Salary Transfer 01/04/2026 09:00:00
Rs. 1000 debited at Supermarket 25/03/2026 10:15:45
USD 50 debited to Online Store 20/04/2026 14:22:10
```

### Invalid SMS Examples (Should Show Error)
```
Hello world (no amount, no type)
LKR 500 (no debit/credit keyword)
debited from AC **1234 (no amount)
```

### Test Category Override
1. Add SMS with one category
2. Open details
3. Tap different category
4. Go back to list
5. Verify category updated (reactive!)
