// lib/services/sample_sms_data.dart

/// Provides the hardcoded sample SMS messages used for demo / testing.
/// In a real app this would be replaced by a platform SMS-reading plugin.
class SampleSmsData {
  SampleSmsData._();

  static const List<String> messages = [
    // ── Provided sample messages ──────────────────────────────────────────────
    '''LKR 150.00 debited from AC **1111 via POS at KOTTAWA INTERCHANGE 10500302
28/03/2026 14:19:13
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 1,692.00 debited from AC **1114 via POS at KEELLS SUPER - KOTTAWA 10402483
25/03/2026 17:46:49
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 5,970.00 debited from AC **1114 via POS at P AND B FUEL MART 10000759
25/03/2026 18:58:40
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    // ── Additional demo messages ──────────────────────────────────────────────
    '''LKR 3,450.00 credited to AC **1111 via ONLINE TRANSFER
01/04/2026 09:15:00
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 850.00 debited from AC **1111 via POS at KFC COLOMBO 7 10200134
02/04/2026 13:05:22
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 2,200.00 debited from AC **1114 via POS at LAUGFS FUEL STATION 10300411
03/04/2026 08:30:00
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 15,000.00 credited to AC **1111 via SALARY CREDIT
05/04/2026 00:01:00
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 450.00 debited from AC **1111 via POS at EXCEL WORLD CINEMA 10100099
06/04/2026 19:45:10
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 1,100.00 debited from AC **1114 via POS at CARGILLS FOOD CITY 10500211
07/04/2026 12:10:33
To Inq Call 0112303050
Get protected - Do not Share OTP''',

    '''LKR 3,750.00 debited from AC **1111 via POS at DARAZ ONLINE SHOPPING 10600001
08/04/2026 16:22:07
To Inq Call 0112303050
Get protected - Do not Share OTP''',
  ];
}
