import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/billing/domain/subscription.dart';
import 'package:canivue/features/billing/presentation/controllers/billing_controller.dart';

/// Subscription & Pet Protection screen directly inspired by Pawsure (Image 1).
///
/// Features:
/// - Category selector: [ All ] [ Full Protection ] [ Medical ] [ Wellness ] [ Travel ]
/// - High-contrast warm showcase protection cards (Warm Amber, Soft Mint, Pastel Indigo)
/// - Floating price badges and circular action pill buttons (↗)
/// - Active plan status & renewal countdown
/// - Monthly usage limits breakdown
/// - Complete plan comparison & instant switching
/// - Itemized billing history with receipts
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Full Protection', 'Medical', 'Wellness', 'Travel'];

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(currentSubscriptionControllerProvider);
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Protection',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF181A20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: isDark ? Colors.white : const Color(0xFF181A20)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search protection packages...'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AmbientPawBackdrop(
        showContainerLines: false,
        showPawWatermarks: true,
        showParticles: true,
        child: subscriptionAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SkeletonBox(height: 180),
                SizedBox(height: 16),
                SkeletonBox(height: 200),
                SizedBox(height: 16),
                SkeletonBox(height: 120),
              ],
            ),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load your protection details.",
            onRetry: () => ref.invalidate(currentSubscriptionControllerProvider),
          ),
          data: (subscription) => plansAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonBox(height: 200),
            ),
            error: (_, _) => ErrorState(
              message: "We couldn't load protection plans.",
              onRetry: () => ref.invalidate(subscriptionPlansProvider),
            ),
            data: (plans) => _BillingBody(
              subscription: subscription,
              plans: plans,
              selectedCategory: _categories[_selectedCategoryIndex],
              categories: _categories,
              selectedCategoryIndex: _selectedCategoryIndex,
              onSelectCategory: (idx) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategoryIndex = idx);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BillingBody extends ConsumerWidget {
  const _BillingBody({
    required this.subscription,
    required this.plans,
    required this.selectedCategory,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onSelectCategory,
  });

  final CurrentSubscription subscription;
  final List<SubscriptionPlan> plans;
  final String selectedCategory;
  final List<String> categories;
  final int selectedCategoryIndex;
  final ValueChanged<int> onSelectCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPlan = plans.firstWhere(
      (p) => p.id == subscription.planId,
      orElse: () => plans.first,
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      children: [
        // 1. Filter Category Pills (Pawsure style)
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = index == selectedCategoryIndex;
              return GestureDetector(
                onTap: () => onSelectCategory(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20))
                        : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFEAE5DC)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 2. Featured Showcase Card 1 (Warm Sunshine Amber — Keep Your Pet Safe)
        _ShowcaseProtectionCard(
          title: 'Keep\nYour Pet Safe',
          subtitle: 'Your furry friends deserve the best care with 24/7 AI diagnosis & vet access.',
          priceLabel: '\$65 monthly',
          backgroundColor: const Color(0xFFFED25E),
          textColor: const Color(0xFF181A20),
          imageAsset: 'assets/images/dogs/rocky.jpg',
          isDark: isDark,
          onTap: () async {
            final targetPlan = plans.firstWhere((p) => p.id == 'premium', orElse: () => plans.last);
            await ref.read(currentSubscriptionControllerProvider.notifier).changePlan(targetPlan.id);
            if (context.mounted) {
              AppFeedback.showToast(context, title: 'Protection Activated 🛡️', message: 'You are now protected on the ${targetPlan.name} plan.', type: ToastType.success);
            }
          },
        ),
        const SizedBox(height: 16),

        // 3. Featured Showcase Card 2 (Soft Mint — Guardian Protection)
        _ShowcaseProtectionCard(
          title: 'Your Pet\nSafe Plus',
          subtitle: 'Comprehensive illness & injury coverage designed to keep your pack happy.',
          priceLabel: '\$80 monthly',
          backgroundColor: const Color(0xFFD0ECC8),
          textColor: const Color(0xFF13361E),
          imageAsset: 'assets/images/dogs/luna.jpg',
          isDark: isDark,
          onTap: () async {
            final targetPlan = plans.firstWhere((p) => p.id == 'pro', orElse: () => plans.last);
            await ref.read(currentSubscriptionControllerProvider.notifier).changePlan(targetPlan.id);
            if (context.mounted) {
              AppFeedback.showToast(context, title: 'Pro Protection Activated 🌟', message: 'You have upgraded to the ${targetPlan.name} plan.', type: ToastType.success);
            }
          },
        ),
        const SizedBox(height: 28),

        // 4. Current Plan & Active Coverage Status Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B202C) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Active Protection',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFECE6DC)),
                    ),
                    child: Text(
                      currentPlan.priceMonthly == 0 ? 'FREE' : '\$${currentPlan.priceMonthly.toStringAsFixed(2)}/mo',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: isDark ? Colors.white : const Color(0xFF181A20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${currentPlan.name} Membership',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: isDark ? Colors.white : const Color(0xFF181A20),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentPlan.priceMonthly == 0
                    ? 'Free forever tier with basic coverage'
                    : 'Renews automatically on ${DateFormat('MMM d, yyyy').format(subscription.renewsAt)}',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1EDE6)),
              const SizedBox(height: 16),
              Text(
                'THIS MONTH\'S USAGE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              for (final usage in subscription.usage) _UsageRow(usage: usage, isDark: isDark),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 5. Compare All Plans Section
        _sectionHeader('Compare Protection Plans', isDark),
        const SizedBox(height: 12),
        for (final plan in plans)
          _PlanComparisonCard(
            plan: plan,
            isCurrent: plan.id == subscription.planId,
            isDark: isDark,
            onSelect: () async {
              await ref.read(currentSubscriptionControllerProvider.notifier).changePlan(plan.id);
              if (context.mounted) {
                AppFeedback.showToast(
                  context,
                  title: 'Plan Updated 🎉',
                  message: 'Switched to ${plan.name} plan.',
                  type: ToastType.success,
                );
              }
            },
          ),
        const SizedBox(height: 28),

        // 6. Billing & Invoice Receipts Section
        _sectionHeader('Billing History & Receipts', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B202C) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < subscription.invoices.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1EDE6),
                  ),
                _InvoiceTile(invoice: subscription.invoices[i], isDark: isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 16.5,
        color: isDark ? Colors.white : const Color(0xFF181A20),
        letterSpacing: -0.3,
      ),
    );
  }
}

/// Large punchy showcase protection card (Pawsure reference style)
class _ShowcaseProtectionCard extends StatelessWidget {
  const _ShowcaseProtectionCard({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.backgroundColor,
    required this.textColor,
    required this.imageAsset,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
  final Color backgroundColor;
  final Color textColor;
  final String imageAsset;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Right-aligned pet photo
            Positioned(
              right: -10,
              bottom: -15,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  imageAsset,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Left content column
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.15,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 175,
                    child: Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),

                  // Bottom frosted price badge and ↗ circular button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          priceLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF181A20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 38,
                        width: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_outward_rounded, size: 18, color: Color(0xFF181A20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.usage, required this.isDark});

  final UsageLimit usage;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                usage.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF181A20),
                ),
              ),
              Text(
                usage.isUnlimited ? '${usage.used} used · Unlimited' : '${usage.used} / ${usage.limit}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: usage.isUnlimited ? null : usage.fraction,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF242A38) : const Color(0xFFFAF7F2),
              valueColor: AlwaysStoppedAnimation(
                isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanComparisonCard extends StatelessWidget {
  const _PlanComparisonCard({
    required this.plan,
    required this.isCurrent,
    required this.isDark,
    required this.onSelect,
  });

  final SubscriptionPlan plan;
  final bool isCurrent;
  final bool isDark;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B202C) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFFFED25E)
              : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC)),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: isDark ? Colors.white : const Color(0xFF181A20),
                ),
              ),
              Text(
                plan.priceMonthly == 0 ? 'Free' : '\$${plan.priceMonthly.toStringAsFixed(2)}/mo',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isCurrent ? const Color(0xFFD97706) : (isDark ? Colors.white : const Color(0xFF181A20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Current Protection Active',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  )
                : FilledButton(
                    onPressed: onSelect,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20),
                      foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Switch to ${plan.name}',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.isDark});

  final Invoice invoice;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = switch (invoice.status) {
      InvoiceStatus.paid => (const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.12)),
      InvoiceStatus.pending => (const Color(0xFFF59E0B), const Color(0xFFF59E0B).withValues(alpha: 0.12)),
      InvoiceStatus.failed => (const Color(0xFFEF4444), const Color(0xFFEF4444).withValues(alpha: 0.12)),
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242A38) : const Color(0xFFFFF3D6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFD97706), size: 20),
      ),
      title: Text(
        invoice.description,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: isDark ? Colors.white : const Color(0xFF181A20),
        ),
      ),
      subtitle: Text(
        DateFormat('MMM d, yyyy').format(invoice.date),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${invoice.amount.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: isDark ? Colors.white : const Color(0xFF181A20),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              invoice.status.name.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 9.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
