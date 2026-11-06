import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/vets/domain/vet_repository.dart';
import 'package:canivue/features/vets/presentation/controllers/vet_controller.dart';
import 'package:canivue/features/vets/presentation/screens/vet_profile_screen.dart';
import 'package:canivue/features/vets/presentation/widgets/vet_card.dart';

/// Veterinarian discovery marketplace — search/filter with specialty chips
/// and direct access to doctor profiles.
class VetDiscoveryScreen extends ConsumerWidget {
  const VetDiscoveryScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  static const _specialties = ['Internal Medicine', 'Orthopedics', 'Dermatology', 'General Practice', 'Nutrition'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(vetSearchResultsProvider);
    final filters = ref.watch(vetSearchFiltersProvider);
    final searchQuery = ref.watch(vetSearchQueryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Editorial Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : const Color(0xFF181A20),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0x4414B8A6) : const Color(0xFFBFE7DC),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🩺', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'TRUSTED CLINICIANS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find a Veterinarian',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => ref.read(vetSearchQueryProvider.notifier).state = value,
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by doctor name or specialty...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(vetSearchQueryProvider.notifier).state = '';
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE5E7EB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: isDark ? Colors.white : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3. Specialty Filter Pills
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _filterChip(
                      label: '⚡ Available Today',
                      selected: filters.availableTodayOnly,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(vetSearchFiltersProvider.notifier).state = VetSearchFilters(
                          specialty: filters.specialty,
                          availableTodayOnly: !filters.availableTodayOnly,
                          consultationType: filters.consultationType,
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    for (final specialty in _specialties) ...[
                      _filterChip(
                        label: specialty,
                        selected: filters.specialty == specialty,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(vetSearchFiltersProvider.notifier).state = VetSearchFilters(
                            specialty: filters.specialty == specialty ? null : specialty,
                            availableTodayOnly: filters.availableTodayOnly,
                            consultationType: filters.consultationType,
                          );
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Results List
              Expanded(
                child: resultsAsync.when(
                  loading: () => ListView(
                    padding: const EdgeInsets.all(20),
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: SkeletonBox(height: 110, borderRadius: BorderRadius.all(Radius.circular(24))),
                      ),
                    ),
                  ),
                  error: (_, _) => ErrorState(
                    message: "We couldn't load veterinarians.",
                    onRetry: () => ref.invalidate(vetSearchResultsProvider),
                  ),
                  data: (vets) {
                    if (vets.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No veterinarians found',
                        message: 'Try a different search term or clear your specialty filters.',
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: vets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final vet = vets[index];
                        return VetCard(
                          vet: vet,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VetProfileScreen(
                                  vetId: vet.id,
                                  dogId: dogId,
                                  dogName: dogName,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? Colors.white : const Color(0xFF181A20))
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? (isDark ? Colors.white : const Color(0xFF181A20))
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? (isDark ? const Color(0xFF181A20) : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
