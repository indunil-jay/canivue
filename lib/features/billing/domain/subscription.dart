/// Subscription & billing (brief §27).
class SubscriptionPlan {
  const SubscriptionPlan({required this.id, required this.name, required this.priceMonthly, required this.features});

  final String id;
  final String name;
  final double priceMonthly;
  final List<String> features;
}

class UsageLimit {
  const UsageLimit({required this.label, required this.used, required this.limit});

  final String label;
  final int used;

  /// -1 means unlimited.
  final int limit;

  bool get isUnlimited => limit < 0;
  double get fraction => isUnlimited ? 0 : (limit == 0 ? 0 : (used / limit).clamp(0, 1).toDouble());
}

enum InvoiceStatus { paid, pending, failed }

class Invoice {
  const Invoice({required this.id, required this.date, required this.amount, required this.status, required this.description});

  final String id;
  final DateTime date;
  final double amount;
  final InvoiceStatus status;
  final String description;
}

class CurrentSubscription {
  const CurrentSubscription({required this.planId, required this.renewsAt, required this.usage, required this.invoices});

  final String planId;
  final DateTime renewsAt;
  final List<UsageLimit> usage;
  final List<Invoice> invoices;
}
