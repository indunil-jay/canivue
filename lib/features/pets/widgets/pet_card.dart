import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
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
        color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.85) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                    // Avatar with gradient border / shadow
                    Hero(
                      tag: 'pet-avatar-${pet.id}',
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          gradient: AppTheme.aquaGradient,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.25),
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
                                    pet.avatarEmoji,
                                    style: const TextStyle(fontSize: 34),
                                  ),
                                ),
                              )
                            : pet.assetImagePath != null
                                ? Image.asset(
                                    pet.assetImagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(
                                        pet.avatarEmoji,
                                        style: const TextStyle(fontSize: 34),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      pet.avatarEmoji,
                                      style: const TextStyle(fontSize: 34),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name, Breed & Chips
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pet.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: (isMale ? const Color(0xFF0066FF) : const Color(0xFFEC4899)).withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (isMale ? const Color(0xFF0066FF) : const Color(0xFFEC4899)).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isMale ? Icons.male_rounded : Icons.female_rounded,
                                      size: 13,
                                      color: isMale ? (isDark ? AppTheme.cyanAccent : const Color(0xFF0066FF)) : const Color(0xFFEC4899),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      pet.gender,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isMale ? (isDark ? AppTheme.cyanAccent : const Color(0xFF0066FF)) : const Color(0xFFEC4899),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            pet.breed,
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Age & Weight Badges
                          Row(
                            children: [
                              _buildMiniPill(Icons.cake_outlined, '${pet.ageYears} yrs', isDark),
                              const SizedBox(width: 8),
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
                      size: 54,
                      strokeWidth: 5,
                      glow: false,
                      valueText: '96',
                      unitText: '%',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
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
                            height: 7,
                            width: 7,
                            decoration: const BoxDecoration(
                              color: AppTheme.emeraldAccent,
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
                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'AI Check',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
