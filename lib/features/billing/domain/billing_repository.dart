import 'package:canivue/features/billing/domain/subscription.dart';

abstract class BillingRepository {
  Future<List<SubscriptionPlan>> fetchPlans();

  Future<CurrentSubscription> fetchCurrentSubscription();

  Future<CurrentSubscription> changePlan(String planId);
}
