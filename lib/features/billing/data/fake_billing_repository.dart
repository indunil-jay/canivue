import 'package:canivue/features/billing/domain/billing_repository.dart';
import 'package:canivue/features/billing/domain/subscription.dart';

class FakeBillingRepository implements BillingRepository {
  static const _plans = [
    SubscriptionPlan(id: 'free', name: 'Free', priceMonthly: 0, features: ['1 dog profile', '5 AI analyses / month', 'Community access']),
    SubscriptionPlan(
      id: 'premium',
      name: 'Premium',
      priceMonthly: 12.99,
      features: ['Up to 3 dogs', 'Unlimited AI analyses', '2 smart collar devices', '2 vet consultations / month', 'Priority support'],
    ),
    SubscriptionPlan(
      id: 'pro',
      name: 'Pro',
      priceMonthly: 24.99,
      features: ['Unlimited dogs', 'Unlimited AI analyses', 'Unlimited devices', 'Unlimited vet consultations', 'Dedicated care coordinator'],
    ),
  ];

  String _currentPlanId = 'premium';

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _plans;
  }

  @override
  Future<CurrentSubscription> fetchCurrentSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _buildSubscription();
  }

  @override
  Future<CurrentSubscription> changePlan(String planId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _currentPlanId = planId;
    return _buildSubscription();
  }

  CurrentSubscription _buildSubscription() {
    final now = DateTime.now();
    return CurrentSubscription(
      planId: _currentPlanId,
      renewsAt: now.add(const Duration(days: 18)),
      usage: const [
        UsageLimit(label: 'AI Analyses', used: 14, limit: -1),
        UsageLimit(label: 'Connected Devices', used: 1, limit: 2),
        UsageLimit(label: 'Vet Consultations', used: 1, limit: 2),
      ],
      invoices: [
        Invoice(id: 'inv-1', date: now.subtract(const Duration(days: 12)), amount: 12.99, status: InvoiceStatus.paid, description: 'Premium Plan — Monthly'),
        Invoice(id: 'inv-2', date: now.subtract(const Duration(days: 42)), amount: 12.99, status: InvoiceStatus.paid, description: 'Premium Plan — Monthly'),
        Invoice(id: 'inv-3', date: now.subtract(const Duration(days: 72)), amount: 12.99, status: InvoiceStatus.paid, description: 'Premium Plan — Monthly'),
      ],
    );
  }
}
