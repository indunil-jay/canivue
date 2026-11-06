import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/luxury_biometric_ring.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
    this.onScanTap,
  });

  final Pet pet;
  final VoidCallback onTap;
  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMale = pet.gender.toLowerCase() == 'male';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            blurRadius: 18,
            offset: const Offset(0, 5),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with warm sanctuary border / shadow
                    Hero(
                      tag: 'pet-avatar-${pet.id}',
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: pet.imagePath != null && File(pet.imagePath!).existsSync()
                            ? Image.file(
                                File(pet.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    pet.species.toLowerCase() == 'cat' ? '🐱' : '🐶',
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  pet.species.toLowerCase() == 'cat' ? '🐱' : '🐶',
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Center Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  pet.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isMale
                                      ? (isDark ? const Color(0x330284C7) : const Color(0xFFEAF4FB))
                                      : (isDark ? const Color(0x33F43F5E) : const Color(0xFFFDF2F0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isMale ? '♂' : '♀',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isMale ? const Color(0xFF0284C7) : const Color(0xFFF43F5E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            pet.breed,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Mini Info Pills
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildMiniPill(Icons.cake_outlined, '${pet.ageYears}y ${pet.ageMonths}m', isDark),
                              _buildMiniPill(Icons.monitor_weight_outlined, '${pet.weightKg.toStringAsFixed(1)} kg', isDark),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right Side Vitality Ring
                    const SizedBox(width: 8),
                    const LuxuryBiometricRing(
                      percentage: 96,
                      size: 52,
                      strokeWidth: 5,
                      accentColor: Color(0xFF10B981),
                      valueText: '96',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                const SizedBox(height: 12),

                // Footer Row: Telemetry status & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Smart Collar Online • 8,450 steps',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onScanTap ?? onTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'AI Scan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
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

  Widget _buildMiniPill(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
