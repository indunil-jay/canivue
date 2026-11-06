import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/pets/screens/add_edit_pet_screen.dart';
import 'package:canivue/features/billing/presentation/screens/subscription_screen.dart';
import 'package:canivue/features/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:canivue/features/predictions/presentation/screens/prediction_history_screen.dart';
import 'package:canivue/features/privacy/presentation/screens/privacy_security_screen.dart';
import 'package:canivue/features/profile/screens/personal_information_screen.dart';
import 'package:canivue/features/vets/presentation/screens/appointments_screen.dart';

/// The "Profile" tab of the owner shell — account, dogs shortcut, records,
/// billing, preferences and sign-out.
///
/// Designed with the warm, high-end pet sanctuary aesthetic.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _aiInsightsEnabled = true;

  void _handleLogout() async {
    HapticFeedback.lightImpact();
    final confirmed = await AppFeedback.showLuxuryDialog(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of Canive?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
      icon: Icons.logout_rounded,
      accentColor: const Color(0xFFF43F5E),
      iconGradient: const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(authControllerProvider.notifier).signOut();
      if (mounted) context.go('/sign-in');
    }
  }

  void _navigateToPersonalInfo(String email, String name) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonalInformationScreen(userEmail: email, userName: name),
      ),
    );
  }

  void _onAddNewPet() async {
    HapticFeedback.lightImpact();
    final newPet = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(builder: (_) => const AddEditPetScreen()),
    );
    if (newPet != null) {
      await ref.read(dogsProvider.notifier).addDog(newPet);
    }
  }

  void _navigateToPets() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetListScreen()));
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider);
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Pet Parent';
    final email = user?.email ?? 'guest@canive.com';
    final pets = ref.watch(dogsProvider).value ?? const [];
    final activeDog = ref.watch(activeDogProvider).value;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Warm Pet Parent Hero Card
                InkWell(
                  onTap: () => _navigateToPersonalInfo(email, displayName),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF242A38), Color(0xFF1E2430), Color(0xFF161A24)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF181A20), Color(0xFF232730)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFFED25E),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFED25E),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF181A20),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                email,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFED25E).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFED25E).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  '⭐ Premium Pet Parent',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFED25E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 2. My Dogs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('MY DOGS', isDark),
                    GestureDetector(
                      onTap: _navigateToPets,
                      child: Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final pet in pets.take(2))
                  _buildPetTile(
                    pet: pet,
                    name: pet.name,
                    breed: '${pet.breed} • ${pet.ageFormatted}',
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PetDetailScreen(pet: pet),
                        ),
                      );
                    },
                  ),
                InkWell(
                  onTap: _onAddNewPet,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x1AFFFFFF) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0x28FFFFFF) : const Color(0xFFECE6DC),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Another Dog',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Account & Records Group
                _buildSectionHeader('ACCOUNT & RECORDS', isDark),
                const SizedBox(height: 10),
                _buildNavTile(
                  icon: Icons.person_outline_rounded,
                  iconBg: const Color(0xFFFFF3D6),
                  iconColor: const Color(0xFFD97706),
                  title: 'Personal Information',
                  subtitle: 'Edit contact & address details',
                  onTap: () => _navigateToPersonalInfo(email, displayName),
                  isDark: isDark,
                ),
                _buildNavTile(
                  icon: Icons.event_available_rounded,
                  iconBg: const Color(0xFFDDF4EC),
                  iconColor: const Color(0xFF0D9488),
                  title: 'My Appointments',
                  subtitle: 'Upcoming & past veterinary visits',
                  onTap: () {
                    if (activeDog == null) {
                      _showActionSnackBar('Add a dog to see appointments');
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppointmentsScreen(
                          dogId: activeDog.id,
                          dogName: activeDog.name,
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                _buildNavTile(
                  icon: Icons.medical_services_outlined,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Medical & Vet Records',
                  subtitle: 'Vaccinations & prescriptions',
                  onTap: () {
                    if (activeDog == null) {
                      _showActionSnackBar('Add a dog to see medical records');
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordsScreen(
                          dogId: activeDog.id,
                          dogName: activeDog.name,
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                _buildNavTile(
                  icon: Icons.auto_awesome_rounded,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'AI Engine Analyzed & History',
                  subtitle: 'Multimodal predictions & progression risk logs',
                  onTap: () {
                    final targetDog = activeDog ?? (pets.isNotEmpty ? pets.first : null);
                    if (targetDog == null) {
                      _showActionSnackBar('Add a dog to view AI analysis history');
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PredictionHistoryScreen(
                          dogId: targetDog.id,
                          dogName: targetDog.name,
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                _buildNavTile(
                  icon: Icons.health_and_safety_rounded,
                  iconBg: const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                  title: 'Membership & Billing',
                  subtitle: 'Canive Protection & Insurance Plans',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  ),
                  isDark: isDark,
                ),
                const SizedBox(height: 28),

                // 4. Preferences & AI Settings
                _buildSectionHeader('PREFERENCES & AI', isDark),
                const SizedBox(height: 10),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppTheme.themeModeNotifier,
                  builder: (context, mode, _) {
                    final isModeDark = mode == ThemeMode.dark;
                    return _buildSwitchTile(
                      icon: isModeDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: 'Dark Mode',
                      subtitle: isModeDark ? 'Obsidian charcoal theme active' : 'Warm cream sanctuary active',
                      value: isModeDark,
                      onChanged: (val) {
                        AppTheme.toggleTheme();
                        AppFeedback.showToast(
                          context,
                          title: val ? 'Dark Mode Active 🌙' : 'Sanctuary Light Active ☀️',
                          message: val ? 'Switched to obsidian theme.' : 'Switched to warm cream theme.',
                          type: ToastType.info,
                        );
                      },
                      isDark: isDark,
                    );
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  title: 'Care Notifications',
                  subtitle: 'Medication & vaccine reminders',
                  value: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                  isDark: isDark,
                ),
                _buildSwitchTile(
                  icon: Icons.auto_awesome_rounded,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'AI Health Insights',
                  subtitle: 'Automated weekly wellness digests',
                  value: _aiInsightsEnabled,
                  onChanged: (val) => setState(() => _aiInsightsEnabled = val),
                  isDark: isDark,
                ),
                const SizedBox(height: 28),

                // 5. Support & Security
                _buildSectionHeader('SUPPORT & LEGAL', isDark),
                const SizedBox(height: 10),
                _buildNavTile(
                  icon: Icons.support_agent_rounded,
                  iconBg: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  title: 'Help Center & 24/7 Vet Chat',
                  subtitle: 'Talk with certified veterinarians',
                  onTap: () => _showActionSnackBar('Connecting to certified support...'),
                  isDark: isDark,
                ),
                _buildNavTile(
                  icon: Icons.security_rounded,
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  title: 'Privacy & Security',
                  subtitle: 'Manage permissions & encryption',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                  ),
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // 6. Log Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                    label: Text(
                      'Log Out',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1.1,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildPetTile({
    required Pet pet,
    required String name,
    required String breed,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B202C) : Colors.white,
          borderRadius: BorderRadius.circular(18),
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
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark ? const Color(0xFF242A38) : const Color(0xFFFFF3D6),
              ),
              clipBehavior: Clip.antiAlias,
              child: pet.assetImagePath != null
                  ? Image.asset(
                      pet.assetImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                    )
                  : Center(
                      child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 22)),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF181A20),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    breed,
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B202C) : Colors.white,
          borderRadius: BorderRadius.circular(18),
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
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242A38) : iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF181A20),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B202C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242A38) : iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF181A20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
