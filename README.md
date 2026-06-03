#  SMS Finance Tracker - Flutter MVP


##  Project Overview

This is a complete Flutter MVP that reads bank SMS/OTP messages, automatically extracts financial transaction details, and categorizes them into a personal finance tracker.

-  Clean code architecture (logic separated from UI)
-  Riverpod state management (reactive, no setState)
-  Robust SMS parsing with regex patterns
-  Smart auto-categorization by merchant keywords
-  Full CRUD operations on transactions
-  Category filtering and financial summaries
-  Material 3 modern UI design

##  Project Structure

```
Flutter-App/
└── sms_app/                    # Main Flutter application
    ├── README.md              # Detailed project documentation
    ├── pubspec.yaml           # Dependencies configuration
    ├── analysis_options.yaml   # Lint rules
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── models/            # Data models
    │   ├── services/          # Business logic (SMS parser)
    │   ├── providers/         # Riverpod state management
    │   ├── screens/           # UI pages
    │   └── widgets/           # Reusable components
    ├── test/                  # Unit tests
    ├── ios/                   # iOS configuration
    ├── android/               # Android configuration
    ├── web/                   # Web configuration
    └── windows/               # Windows configuration
```

##  Quick Start

### Prerequisites
- Flutter 3.0+
- Dart 3.0+

### Installation

1. **Navigate to project**
   ```bash
   cd Flutter-App/sms_app
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Clean Build (If Issues Occur)
```bash
flutter clean
dart cache clean
flutter pub get
flutter run
```

##  Documentation

See [sms_app/README.md](sms_app/README.md) for:
- Detailed features
- Architecture explanation
- Complete API documentation
- SMS parsing examples
- Testing guide
- FAQ

##  Quick Demo

The app includes 10 sample SMS transactions loaded at startup:

1. **View Dashboard** - See all transactions with summary
2. **Add SMS** - Tap ➕ and paste: `LKR 1,692.00 debited from AC **1114 via POS at KEELLS SUPER - KOTTAWA 10402483\n25/03/2026 17:46:49`
3. **View Details** - Tap any transaction to see full parsed data
4. **Change Category** - Update category on details screen (list updates automatically!)
5. **Filter** - Filter by category using chips in filter bar



##  Key Features

### SMS Parsing Engine
- Extracts amount, merchant, date, type, account reference
- Handles multiple currency formats (LKR, Rs, USD, EUR, GBP)
- 5 merchant extraction patterns (handles various SMS formats)
- Graceful error handling for invalid messages

### Auto-Categorization
- 9 expense categories + income
- Keyword-based merchant matching (case-insensitive)
- Examples:
  - "KEELLS SUPER" →  Groceries
  - "PIZZA HUT" →  Food
  - "KOTTAWA INTERCHANGE" →  Transport

### State Management
- Riverpod for reactive state
- No manual setState() calls
- Derived providers for totals and filtering
- Multi-screen reactivity (single state change updates all screens)

### UI/UX
- Material 3 design
- Dark blue theme (#1A237E)
- Smooth animations
- Helpful error messages
- SnackBar confirmations

##  Architecture Highlights

### Separation of Concerns
```
✅ Pure Logic (no Flutter imports):
   - models/transaction.dart
   - services/sms_parser.dart

✅ State Layer (Riverpod):
   - providers/transactions_provider.dart

✅ UI Layer (Flutter widgets):
   - screens/ (pages)
   - widgets/ (components)
```


##  Sample SMS Messages

Try these for testing:

**Valid (Should Parse):**
```
LKR 150.00 debited from AC **1111 via POS at KOTTAWA INTERCHANGE 10500302
28/03/2026 14:19:13

LKR 850.00 debited from AC **1111 via POS at KFC COLOMBO 7 10200134
02/04/2026 13:05:22

LKR 3,450.00 credited to AC **1111 via ONLINE TRANSFER
01/04/2026 09:15:00
```

**Invalid (Should Show Error):**
```
hello world
LKR 500 (missing debit/credit keyword)
debited from AC **1234 (missing amount)
```




