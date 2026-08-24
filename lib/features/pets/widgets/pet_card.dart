import 'dart:io';
import 'package:flutter/material.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
  });

  final Pet pet;
  final VoidCallback onTap;

  Widget _buildAvatar() {
    if (pet.imagePath != null && File(pet.imagePath!).existsSync()) {
      return Image.file(
        File(pet.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackEmoji(),
      );
    }
    if (pet.assetImagePath != null) {
      return Image.asset(
        pet.assetImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackEmoji(),
      );
    }
    return _buildFallbackEmoji();
  }

  Widget _buildFallbackEmoji() {
    return Center(
      child: Text(
        pet.avatarEmoji,
        style: const TextStyle(fontSize: 34),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isMale = pet.gender.toLowerCase() == 'male';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
            color: AppTheme.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with gradient border / background
                    Container(
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        gradient: AppTheme.aquaGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                    // Hero Animated Avatar with Gradient Glow Frame
                    Hero(
                      tag: 'pet-avatar-${pet.id}',
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          gradient: AppTheme.aquaGradient,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ],
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildAvatar(),
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
                          : Center(
                              child: Text(
                                pet.avatarEmoji,
                                style: const TextStyle(fontSize: 34),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),

                    // Name & Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pet.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isMale ? const Color(0xFF0066FF) : Colors.pink).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isMale ? Icons.male_rounded : Icons.female_rounded,
                                      size: 14,
                                      color: isMale ? AppTheme.oceanBlue : Colors.pink.shade700,
                                    ),
                                    const SizedBox(width: 3),
                                    const SizedBox(width: 4),
                                    Text(
                                      pet.gender,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isMale ? AppTheme.oceanBlue : Colors.pink.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const SizedBox(height: 3),
                          Text(
                            pet.breed,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Badges Row
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.cake_outlined,
                                label: pet.ageFormatted,
                                theme: theme,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pet.ageFormatted,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.monitor_weight_outlined,
                                label: '${pet.weightKg} kg',
                                theme: theme,
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${pet.weightKg.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const SizedBox(height: 10),

                // Bottom status line
                // Card Footer with Health Status & Chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: Colors.green.shade600,
                        Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Vaccines Up to Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                        Text(
                          'View Profile',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppTheme.primaryBlue,
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ],
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.oceanBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.oceanBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
