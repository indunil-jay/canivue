import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

/// Veterinarian marketplace card (brief §16): photo, verification, specialty,
/// experience, rating, consultation count, response time, fee, availability.
class VetCard extends StatelessWidget {
  const VetCard({super.key, required this.vet, required this.onTap});

  final Veterinarian vet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: Center(child: Text(vet.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(vet.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      if (vet.verified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 16, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                      ],
                    ],
                  ),
                  Text(
                    '${vet.specialty} · ${vet.experienceYears} yrs experience',
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _metaChip(context, Icons.star_rounded, '${vet.rating} (${vet.reviewCount})', const Color(0xFFF59E0B)),
                      _metaChip(context, Icons.forum_rounded, '${vet.consultationCount} consults', null),
                      _metaChip(context, Icons.bolt_rounded, '~${vet.responseTimeMinutes} min', null),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${vet.consultationFeeUsd.toStringAsFixed(0)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (vet.availableToday ? AppColors.success : AppColors.lightMutedText).withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    vet.availableToday ? 'Today' : 'Later',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: vet.availableToday ? (isDark ? AppColors.successOnDark : AppColors.success) : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String label, Color? color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = color ?? (isDark ? AppColors.darkMutedText : AppColors.lightMutedText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: tint),
        const SizedBox(width: 3),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ],
    );
  }
}
