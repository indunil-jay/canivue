import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/billing/domain/subscription.dart';
import 'package:canivue/features/billing/presentation/controllers/billing_controller.dart';

/// Subscription & billing (brief §27) — current plan, usage, plan
/// comparison and billing history.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(currentSubscriptionControllerProvider);
    final plansAsync = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Membership & Billing')),
      body: subscriptionAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [SkeletonBox(height: 160), SizedBox(height: 16), SkeletonBox(height: 200)]),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load your subscription.", onRetry: () => ref.invalidate(currentSubscriptionControllerProvider)),
        data: (subscription) => plansAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(20), child: SkeletonBox(height: 160)),
          error: (_, _) => ErrorState(message: "We couldn't load plans.", onRetry: () => ref.invalidate(subscriptionPlansProvider)),
          data: (plans) => _BillingBody(subscription: subscription, plans: plans),
        ),
      ),
    );
  }
}

class _BillingBody extends ConsumerWidget {
  const _BillingBody({required this.subscription, required this.plans});

  final CurrentSubscription subscription;
  final List<SubscriptionPlan> plans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPlan = plans.firstWhere((p) => p.id == subscription.planId);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadius.xlRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Plan', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
              Text(currentPlan.name, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                currentPlan.priceMonthly == 0 ? 'Free forever' : '\$${currentPlan.priceMonthly.toStringAsFixed(2)} / month · renews ${DateFormat('MMM d, yyyy').format(subscription.renewsAt)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Usage This Month', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        for (final usage in subscription.usage) _UsageRow(usage: usage),
        const SizedBox(height: AppSpacing.xxl),
        Text('Compare Plans', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        for (final plan in plans)
          _PlanCard(
            plan: plan,
            isCurrent: plan.id == subscription.planId,
            onSelect: () async {
              await ref.read(currentSubscriptionControllerProvider.notifier).changePlan(plan.id);
              if (context.mounted) {
                AppFeedback.showToast(context, title: 'Plan updated', message: 'You are now on the ${plan.name} plan.', type: ToastType.success);
              }
            },
          ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Billing History', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < subscription.invoices.length; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _InvoiceTile(invoice: subscription.invoices[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.usage});

  final UsageLimit usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(usage.label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(usage.isUnlimited ? '${usage.used} used' : '${usage.used} / ${usage.limit}', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: AppRadius.xsRadius,
            child: LinearProgressIndicator(
              value: usage.isUnlimited ? null : usage.fraction,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
              valueColor: AlwaysStoppedAnimation(isDark ? AppColors.primaryOnDark : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isCurrent, required this.onSelect});

  final SubscriptionPlan plan;
  final bool isCurrent;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: isCurrent ? (isDark ? AppColors.primaryOnDark : AppColors.primary) : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: isCurrent ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(plan.priceMonthly == 0 ? 'Free' : '\$${plan.priceMonthly.toStringAsFixed(2)}/mo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 16, color: isDark ? AppColors.successOnDark : AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(child: Text(feature, style: theme.textTheme.bodySmall)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(onPressed: null, child: const Text('Current Plan'))
                : FilledButton(onPressed: onSelect, child: const Text('Switch Plan')),
          ),
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = switch (invoice.status) {
      InvoiceStatus.paid => isDark ? AppColors.successOnDark : AppColors.success,
      InvoiceStatus.pending => isDark ? AppColors.warningOnDark : AppColors.warning,
      InvoiceStatus.failed => isDark ? AppColors.errorOnDark : AppColors.error,
    };

    return ListTile(
      leading: Icon(Icons.receipt_long_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      title: Text(invoice.description),
      subtitle: Text(DateFormat('MMM d, yyyy').format(invoice.date)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('\$${invoice.amount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(invoice.status.name, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
