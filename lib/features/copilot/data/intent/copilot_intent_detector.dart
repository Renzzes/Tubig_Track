import '../../domain/entities/copilot_intent.dart';

/// Detects the business intent from a natural language question.
/// Supports English and Cebuano/Filipino variations.
/// Returns [CopilotIntent.unknown] if no intent matches.
class CopilotIntentDetector {
  // ── Extraction helpers ──────────────────────────────────────────────────

  /// Extracts a customer name from various question patterns.
  String? extractCustomerName(String question) {
    final patterns = [
      // "statement for Ivy", "account for Ivy", "statement of Ivy"
      RegExp(r'(?:statement|account|profile|history|summary)\s+(?:for|of|ni|para sa)\s+(.+)', caseSensitive: false),
      // "show statement for Ivy", "show customer summary for Ivy"
      RegExp(r'(?:show|tingnan|ipakita)\s+(?:customer\s+)?(?:statement|account|summary|profile|history)\s+(?:for|of|ni|para sa)\s+(.+)', caseSensitive: false),
      // "tell me about Ivy", "tell me about Charlie"
      RegExp(r'tell\s+me\s+about\s+(.+)', caseSensitive: false),
      // "how much does Ivy owe", "how much does Charlie owe"
      RegExp(r'how\s+much\s+(?:does|do)\s+(.+?)\s+owe', caseSensitive: false),
      // "how many bottles does Shierly have"
      RegExp(r'how\s+many\s+bottles\s+(?:does|do)\s+(.+?)\s+(?:have|hold|has)', caseSensitive: false),
      // "Ivy's balance", "Shierly's bottles"
      RegExp(r"(\w+)'s\s+(?:balance|bottles|statement|account|profile)", caseSensitive: false),
      // "show customer Ivy", "profile for Ivy"
      RegExp(r'(?:customer|profile|summary)\s+(?:for|of|ni)?\s*([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)', caseSensitive: false),
      // "magkano utang ni Ivy"
      RegExp(r'(?:utang|bayad)\s+ni\s+(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(question);
      if (match != null) {
        final raw = match.group(1)?.trim() ?? '';
        if (raw.isNotEmpty) return _capitalize(raw.split('?').first.trim());
      }
    }
    return null;
  }

  /// Extracts the inactivity threshold in days from a question.
  /// Returns 30 by default if no explicit number is found.
  int extractDays(String question) {
    final match = RegExp(r'\b(90|60|30)\b').firstMatch(question);
    if (match != null) return int.parse(match.group(1)!);
    if (question.contains('ninety') || question.contains('3 months')) return 90;
    if (question.contains('sixty') || question.contains('2 months')) return 60;
    return 30;
  }

  /// Returns 'year' if the question refers to this year, 'month' otherwise.
  String extractTimePeriod(String question) {
    final q = question.toLowerCase();
    if (q.contains('this year') ||
        q.contains('year') ||
        q.contains('annual') ||
        q.contains('taon')) {
      return 'year';
    }
    return 'month';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // ── Main intent detection ────────────────────────────────────────────────

  CopilotIntent detect(String question) {
    final q = question.toLowerCase().trim();

    // ── HEALTH CHECK — highest priority ──────────────────────────────────
    if (_matchesAny(q, [
      'health check',
      'business health',
      'status check',
      'overall status',
      'business status',
      'check my business',
    ])) {
      return CopilotIntent.getHealthCheck;
    }

    // ── CUSTOMER STATEMENT / PROFILE — before generic customer checks ────
    if (_matchesAny(q, [
      'statement for',
      'statement of',
      'account for',
      'account of',
      'statement ni',
      'account ni',
      'show statement',
      'customer statement',
    ])) {
      return CopilotIntent.getCustomerStatement;
    }

    // "tell me about [name]", "show summary for [name]", "customer profile"
    if (_matchesAny(q, [
      'tell me about',
      'show summary for',
      'customer summary for',
      'customer profile',
      'profile for',
      'show profile',
    ])) {
      return CopilotIntent.getCustomerProfile;
    }

    // "how much does [name] owe"
    if (RegExp(r'how\s+much\s+(?:does|do)\s+\w+\s+owe').hasMatch(q)) {
      return CopilotIntent.getSpecificCustomerBalance;
    }

    // "how many bottles does [name] have"
    if (RegExp(r'how\s+many\s+bottles\s+(?:does|do)\s+\w+').hasMatch(q)) {
      return CopilotIntent.getSpecificCustomerBottles;
    }

    // "[name]'s balance" / "[name]'s bottles"
    if (RegExp(r"\w+'s\s+balance").hasMatch(q)) {
      return CopilotIntent.getSpecificCustomerBalance;
    }
    if (RegExp(r"\w+'s\s+bottles").hasMatch(q)) {
      return CopilotIntent.getSpecificCustomerBottles;
    }

    // ── SAVINGS & PROFIT ─────────────────────────────────────────────────
    if (_matchesAny(q, [
      'compare savings',
      'savings vs last month',
      'savings last month',
      'savings compared',
      'savings increase',
      'savings decrease',
      'savings change',
    ])) {
      return CopilotIntent.getCompareSavings;
    }

    if (_matchesAny(q, [
      'best month',
      'my best performing month',
      'worst month',
      'my worst month',
      'best performing',
    ])) {
      return CopilotIntent.getBestMonth;
    }

    if (_matchesAny(q, [
      'highest revenue month',
      'which month highest revenue',
      'which month generated the highest revenue',
      'top month',
      'month with most revenue',
      'most revenue month',
      'highest profit month',
      'which month generated the highest profit',
    ])) {
      return CopilotIntent.getHighestRevenueMonth;
    }

    if (_matchesAny(q, [
      'profit this year',
      'profit year',
      'how much did i earn this year',
      'yearly profit',
      'annual profit',
      'kita this year',
      'kita ngayong taon',
    ])) {
      return CopilotIntent.getYearlyProfit;
    }

    if (_matchesAny(q, [
      'savings',
      'ipon',
      'pila savings',
      'unsay savings',
      'current savings',
      'business savings',
      'total savings',
      'savings ko',
    ])) {
      return CopilotIntent.getSavings;
    }

    if (_matchesAny(q, [
      'profit',
      'kita',
      'kinikita',
      'income',
      'earnings',
      'how much did i earn',
      'how much i earned',
      'how much profit',
      'pila ang kita',
      'unsay kita',
    ])) {
      return CopilotIntent.getProfit;
    }

    // ── OVERDUE / PAYMENTS ───────────────────────────────────────────────
    if (_matchesAny(q, [
      'overdue and bottles',
      'owes and holds',
      'has bottles and owes',
      'overdue payments and bottles',
      'unpaid and holds bottles',
      'bottles and unpaid',
      'still has bottles and',
      'naa bottles ug utang',
    ])) {
      return CopilotIntent.getCustomersWithBottlesAndOverdue;
    }

    if (_matchesAny(q, [
      'total collectible',
      'how much money is still',
      'total unpaid',
      'total amount owed',
      'how much is owed',
      'total receivable',
      'total money owed',
    ])) {
      return CopilotIntent.getTotalReceivables;
    }

    if (_matchesAny(q, [
      'overdue',
      'utang',
      'who owes',
      'owes me',
      'unpaid',
      'who has balance',
      'outstanding balance',
      'show unpaid',
      'show overdue',
      'all overdue',
      'may utang',
      'hindi pa bayad',
      'di pa bayad',
      "hasn't paid",
      'who has not paid',
    ])) {
      return CopilotIntent.getOverdueCustomers;
    }

    // ── TOP CUSTOMERS ────────────────────────────────────────────────────
    if (_matchesAny(q, [
      'top customers',
      'best customers',
      'top 5',
      'top 10',
      'pinaka',
      'frequent customers',
      'most orders',
    ])) {
      return CopilotIntent.getTopCustomers;
    }

    if (_matchesAny(q, [
      'most deliveries',
      'which customer had the most deliveries',
      'most frequent customer',
      'which customer most deliveries',
      'customer with most',
    ])) {
      return CopilotIntent.getCustomerMostDeliveries;
    }

    // ── INACTIVE CUSTOMERS ───────────────────────────────────────────────
    if (_matchesAny(q, [
      'not ordered',
      'inactive',
      'no orders',
      'di nag-order',
      'hindi nag-order',
      'walang order',
      'has not ordered',
      "haven't ordered",
      'not buying',
      'stopped ordering',
    ])) {
      return CopilotIntent.getInactiveCustomers;
    }

    // ── BOTTLE VERIFICATION ──────────────────────────────────────────────
    if (_matchesAny(q, [
      'who needs reconciliation',
      'which customers need reconciliation',
      'customers need reconciliation',
      'need reconciliation',
    ])) {
      return CopilotIntent.getCustomersNeedingReconciliation;
    }
    if (_matchesAny(q, [
      'need reconciliation',
      'needs reconciliation',
      'need bottle reconciliation',
      'not physically counted',
      'not verified in 30',
      'overdue reconciliation',
      'stale physical count',
    ])) {
      return CopilotIntent.getCustomersNeedingReconciliation;
    }
    if (_matchesAny(q, [
      'never verified',
      'never reconciled',
      'no physical count',
      'not verified customers',
      'customers never verified',
    ])) {
      return CopilotIntent.getNeverVerifiedCustomers;
    }

    if (_matchesAny(q, [
      'who has missing bottles',
      'customers with missing bottles',
      'missing bottles at customer',
      'customer missing bottles',
      'which customers have missing',
    ])) {
      return CopilotIntent.getCustomersWithMissingBottles;
    }

    if (_matchesAny(q, [
      'overdue balance',
      'overdue balances',
      'who has overdue balance',
      'customers with overdue',
    ])) {
      return CopilotIntent.getCustomersWithOverdueBalances;
    }

    if (_matchesAny(q, [
      'customer-owned bottles',
      'customer owned bottles',
      'how many customer-owned',
      'how many customer owned',
      'total customer-owned',
      'total customer owned bottles',
    ])) {
      return CopilotIntent.getTotalCustomerOwnedBottles;
    }

    if (_matchesAny(q, [
      'customer statement summary',
      'statement summary for',
      'generate customer statement',
      'account summary for',
    ])) {
      return CopilotIntent.getCustomerStatementSummary;
    }

    if (_matchesAny(q, [
      'customers needing follow-up',
      'need follow-up',
      'needs follow up',
      'who needs follow-up',
      'show customers needing follow-up',
    ])) {
      return CopilotIntent.getFollowUps;
    }

    // ── CUSTOMERS WITH DEPOSITS ──────────────────────────────────────────
    if (_matchesAny(q, [
      'which customers have deposits',
      'customers with deposits',
      'who has deposits',
      'customers with pundo',
      'who has pundo',
      'who has active deposit',
      'deposit holders',
    ])) {
      return CopilotIntent.getCustomersWithDeposits;
    }

    // ── REVENUE BY CUSTOMER ──────────────────────────────────────────────
    if (_matchesAny(q, [
      'highest revenue',
      'top earner',
      'most revenue',
      'revenue by customer',
      'which customer generates',
      'generates the most',
      'biggest customer',
      'most sales',
      'pinaka malaking customer',
    ])) {
      return CopilotIntent.getRevenueByCustomer;
    }

    // ── WALK-IN OPERATIONS ─────────────────────────────────────────────────
    if (_matchesAny(q, [
      'walk-in revenue',
      'walk in revenue',
      'earn from walk-in',
      'earned from walk-ins',
      'how much did i earn from walk',
      'walk-in earnings',
    ])) {
      return CopilotIntent.getWalkInRevenue;
    }
    if (_matchesAny(q, [
      'walk-in refill',
      'walk in refill',
      'how many walk-in refills',
      'how many refills this month',
      'customer refills this month',
    ])) {
      return CopilotIntent.getWalkInRefillsThisMonth;
    }
    if (_matchesAny(q, [
      'walk-in exchange',
      'walk in exchange',
      'how many exchanges this month',
      'bottle exchanges this month',
    ])) {
      return CopilotIntent.getWalkInExchangesThisMonth;
    }
    if (_matchesAny(q, [
      'walk-in vs delivery',
      'walk in vs delivery',
      'compare walk-ins',
      'compare walk-ins vs deliveries',
      'walk-ins versus deliveries',
    ])) {
      return CopilotIntent.compareWalkInsVsDeliveries;
    }

    // ── BOTTLES & INVENTORY ──────────────────────────────────────────────
    if (_matchesAny(q, [
      'damaged bottles',
      'how many damaged',
      'broken bottles',
      'damaged',
      'bottles damaged',
    ])) {
      return CopilotIntent.getDamagedBottles;
    }

    if (_matchesAny(q, [
      'missing bottles',
      'nawala',
      'wala nga bottles',
      'lost bottles',
      'nawawalang bote',
      'bottles missing',
      'how many missing',
    ])) {
      return CopilotIntent.getMissingBottles;
    }

    if (_matchesAny(q, [
      'bottles purchased this month',
      'how many bottles bought',
      'monthly bottle purchases',
      'bottle purchases this month',
      'purchased bottles',
      'bought bottles this month',
      'how many bottles did i purchase',
    ])) {
      return CopilotIntent.getMonthlyBottlePurchases;
    }

    if (_matchesAny(q, [
      'inventory',
      'stock',
      'bottles available',
      'available bottles',
      'inventory status',
      'how many bottles',
      'bottle count',
      'stock status',
      'pila ang bote',
    ])) {
      return CopilotIntent.getInventoryStatus;
    }

    if (_matchesAny(q, [
      'who has bottles',
      'bottle balance',
      'most bottles',
      'who has the most bottles',
      'who holds',
      'bottles with customers',
      'customer bottles',
      'kinsa ang naa bottles',
      'not been collected',
      'uncollected',
    ])) {
      return CopilotIntent.getCustomerBottles;
    }

    // ── DELIVERIES ───────────────────────────────────────────────────────
    if (_matchesAny(q, [
      "today's deliveries",
      'deliveries today',
      'show today',
      'who has deliveries today',
      'pila delivery today',
      'deliveries for today',
    ])) {
      return CopilotIntent.getTodayDeliveries;
    }

    if (_matchesAny(q, [
      "tomorrow's deliveries",
      'deliveries tomorrow',
      'show tomorrow',
      'who has deliveries tomorrow',
      'bukas na delivery',
      'deliveries for tomorrow',
    ])) {
      return CopilotIntent.getTomorrowDeliveries;
    }

    if (_matchesAny(q, [
      'this week',
      'deliveries this week',
      'this week deliveries',
      'weekly deliveries',
      'how many this week',
      'scheduled this week',
    ])) {
      return CopilotIntent.getWeekDeliveries;
    }

    if (_matchesAny(q, [
      'upcoming deliveries',
      'scheduled deliveries',
      'future deliveries',
      'next deliveries',
      'show upcoming',
    ])) {
      return CopilotIntent.getUpcomingDeliveries;
    }

    if (_matchesAny(q, [
      'delivery summary',
      'deliveries this month',
      'how many deliveries',
      'total deliveries',
      'delivery count',
      'pila ang delivery',
      'completed deliveries',
    ])) {
      return CopilotIntent.getDeliverySummary;
    }

    // ── DEPOSITS ─────────────────────────────────────────────────────────
    if (_matchesAny(q, [
      'deposit',
      'deposito',
      'pundo',
      'customer deposit',
      'deposits held',
      'how much deposit',
      'how much money held',
      'who has the largest deposit',
    ])) {
      return CopilotIntent.getDepositStatus;
    }

    // ── EXPENSES ─────────────────────────────────────────────────────────
    if (_matchesAny(q, [
      'expenses',
      'gastos',
      'spent this month',
      'how much did i spend',
      'monthly expenses',
      'total expenses',
      'magkano ang gastos',
      'pila ang gastos',
      'spending',
      'ginastos',
    ])) {
      return CopilotIntent.getMonthlyExpenses;
    }

    // ── AUDIT ─────────────────────────────────────────────────────────────
    if (_matchesAny(q, [
      'audit',
      'last audit',
      'inventory audit',
      'when was the last audit',
      'how many adjustments',
      'inventory check',
    ])) {
      return CopilotIntent.getAuditStatus;
    }

    // ── FOLLOW-UPS ────────────────────────────────────────────────────────
    if (_matchesAny(q, [
      'follow up',
      'follow-up',
      'followup',
      'what should i do',
      'what to do today',
      'action items',
      'priority today',
      'dapat gawin',
      'mag follow up',
      'reminder',
    ])) {
      return CopilotIntent.getFollowUps;
    }

    // ── CUSTOMER BALANCE (generic) ────────────────────────────────────────
    if (_matchesAny(q, [
      'balance',
      'amount owed',
      'outstanding',
      'customer balance',
    ])) {
      return CopilotIntent.getCustomerBalance;
    }

    return CopilotIntent.unknown;
  }

  bool _matchesAny(String q, List<String> keywords) {
    for (final kw in keywords) {
      if (q.contains(kw)) return true;
    }
    return false;
  }
}
