import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

/// Veterinarian marketplace card: photo/initials, verification, specialty,
/// experience, rating, consultation count, response time, fee, availability.
class VetCard extends StatelessWidget {
  const VetCard({super.key, required this.vet, required this.onTap});

  final Veterinarian vet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Initials Avatar
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      vet.initials,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              vet.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vet.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${vet.specialty} · ${vet.experienceYears}y exp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _metaChip(context, Icons.star_rounded, '${vet.rating} (${vet.reviewCount})', const Color(0xFFF59E0B), isDark),
                          _metaChip(context, Icons.forum_rounded, '${vet.consultationCount} consults', null, isDark),
                          _metaChip(context, Icons.bolt_rounded, '~${vet.responseTimeMinutes}m', null, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${vet.consultationFeeUsd.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (vet.availableToday ? const Color(0xFF10B981) : const Color(0xFF64748B))
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vet.availableToday ? 'Today' : 'Later',
                        style: GoogleFonts.plusJakartaSans(
                          color: vet.availableToday
                              ? const Color(0xFF10B981)
                              : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String label, Color? color, bool isDark) {
    final tint = color ?? (isDark ? AppColors.darkMutedText : AppColors.lightMutedText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: tint),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: tint,
          ),
        ),
      ],
    );
  }
}
