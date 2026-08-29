import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/billing/data/fake_billing_repository.dart';
import 'package:canivue/features/billing/domain/billing_repository.dart';
import 'package:canivue/features/billing/domain/subscription.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) => FakeBillingRepository());

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) {
  return ref.watch(billingRepositoryProvider).fetchPlans();
});

class CurrentSubscriptionController extends AsyncNotifier<CurrentSubscription> {
  @override
  Future<CurrentSubscription> build() {
    return ref.watch(billingRepositoryProvider).fetchCurrentSubscription();
  }

  Future<void> changePlan(String planId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(billingRepositoryProvider).changePlan(planId));
  }
}

final currentSubscriptionControllerProvider = AsyncNotifierProvider<CurrentSubscriptionController, CurrentSubscription>(
  CurrentSubscriptionController.new,
);
