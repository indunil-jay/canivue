import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/aura_canvas_background.dart';
import 'package:canivue/core/widgets/floating_capsule_nav_bar.dart';
import 'package:canivue/core/widgets/luxury_biometric_ring.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/notifications/widgets/notification_badge_button.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/profile/widgets/profile_side_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.userEmail = 'user@example.com',
    this.userName,
  });

  final String userEmail;
  final String? userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final List<Pet> _pets = List.from(Pet.samplePets);
  int _selectedPetHeroIndex = 0;

  Pet get _selectedPet => _pets.isNotEmpty
      ? _pets[_selectedPetHeroIndex.clamp(0, _pets.length - 1)]
      : Pet.samplePets.first;

  String get _displayName {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return widget.userName!;
    }
    final emailPrefix = widget.userEmail.split('@').first;
    if (emailPrefix.isNotEmpty) {
      return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
    }
    return 'Pet Parent';
  }

  void _openProfileSideSheet() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _navigateToPets() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _navigateToHealthCheck({Pet? initialPet}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(
          pets: _pets,
          initialPet: initialPet ?? _selectedPet,
        ),
      ),
    );
  }

  void _navigateToPetDetail(Pet pet) async {
    final updatedPet = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(
        builder: (_) => PetDetailScreen(pet: pet),
      ),
    );

    if (updatedPet != null) {
      setState(() {
        final index = _pets.indexWhere((p) => p.id == updatedPet.id);
        if (index != -1) {
          _pets[index] = updatedPet;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      endDrawer: ProfileSideSheet(
        userEmail: widget.userEmail,
        userName: widget.userName,
      ),
      body: AuraCanvasBackground(
        child: SafeArea(
          bottom: false,
          child: _currentIndex == 1
              ? const PetListScreen()
              : _buildDashboardContent(theme, isDark),
        ),
      ),
      bottomNavigationBar: FloatingCapsuleNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            _openProfileSideSheet();
          } else if (index == 2) {
            _navigateToHealthCheck();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Executive Header
              _buildTopHeader(isDark),
              const SizedBox(height: 20),

              // Interactive 3D Pet Telemetry Showcase Hero Card
              _build3DPetTelemetryHero(isDark),
              const SizedBox(height: 26),

              // Quick Intelligence & Care Services Grid
              _buildQuickServicesSection(isDark),
              const SizedBox(height: 28),

              // Pet Health Radar Carousel
              _buildPetHealthRadarSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _openProfileSideSheet,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '👤',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_displayName 👋',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
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
                    Text(
                      '${_pets.length} Pets Active & Protected',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? AppTheme.cyanAccent : const Color(0xFF0284C7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Frosted Notification Badge Button
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const NotificationBadgeButton(),
        ),
      ],
    );
  }

  Widget _build3DPetTelemetryHero(bool isDark) {
    final pet = _selectedPet;
    final isMale = pet.gender.toLowerCase() == 'male';

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0C192E).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? const Color(0xFF0066FF).withValues(alpha: 0.3) : const Color(0xFFE0E7FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Pet Switcher Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_pets.length, (index) {
                  final p = _pets[index];
                  final isSelected = index == _selectedPetHeroIndex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPetHeroIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryGradient : null,
                        color: isSelected
                            ? null
                            : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.avatarEmoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            p.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),

          // Main Showcase Content: Avatar, Vitality Ring & Telemetry
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large 3D Pet Avatar with glowing border
                    Hero(
                      tag: 'pet-avatar-${pet.id}',
                      child: Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          gradient: AppTheme.aquaGradient,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: pet.imagePath != null && File(pet.imagePath!).existsSync()
                            ? Image.file(
                                File(pet.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 40)),
                                ),
                              )
                            : pet.assetImagePath != null
                                ? Image.asset(
                                    pet.assetImagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 40)),
                                    ),
                                  )
                                : Center(child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 40))),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Pet Info & Breed Badges
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isMale ? const Color(0xFF0066FF) : const Color(0xFFEC4899)).withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pet.gender,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: isMale ? (isDark ? AppTheme.cyanAccent : const Color(0xFF0066FF)) : const Color(0xFFEC4899),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${pet.breed} • ${pet.species}',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Live Micro-Telemetry Badges
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildMiniTelemetryBadge(Icons.favorite_rounded, '72 bpm', const Color(0xFFF43F5E), isDark),
                              _buildMiniTelemetryBadge(Icons.bluetooth_connected_rounded, 'Collar Synced', AppTheme.emeraldAccent, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Circular Vitality Ring Gauge
                    const SizedBox(width: 6),
                    const LuxuryBiometricRing(
                      percentage: 98,
                      size: 68,
                      strokeWidth: 6.5,
                      valueText: '98',
                      unitText: '%',
                      label: 'Vitality',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // High-Impact Action Button: Launch AI Scanner
                InkWell(
                  onTap: () => _navigateToHealthCheck(initialPet: pet),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFF0284C7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Launch AI Health Scanner',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTelemetryBadge(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServicesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Services',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: [
            _buildCommandCard(
              title: 'Health Check',
              subtitle: 'Multimodal AI Vision',
              icon: Icons.health_and_safety_rounded,
              gradient: AppTheme.primaryGradient,
              isDark: isDark,
              onTap: () => _navigateToHealthCheck(),
            ),
            _buildCommandCard(
              title: 'Vaccinations',
              subtitle: 'Passport & Schedule',
              icon: Icons.vaccines_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDark: isDark,
              onTap: () {
                AppFeedback.showToast(
                  context,
                  title: 'Vaccination Tracker 💉',
                  message: 'All core vaccinations (Rabies, DHPP) are up to date for your pets.',
                  type: ToastType.info,
                );
              },
            ),
            _buildCommandCard(
              title: 'Pet Telemetry',
              subtitle: 'Collar & Biometrics',
              icon: Icons.bluetooth_connected_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDark: isDark,
              onTap: _navigateToPets,
            ),
            _buildCommandCard(
              title: 'Vet Bookings',
              subtitle: 'Bay Area Veterinary',
              icon: Icons.calendar_month_rounded,
              gradient: AppTheme.emeraldGradient,
              isDark: isDark,
              onTap: () {
                AppFeedback.showToast(
                  context,
                  title: 'Vet Booking 🗓️',
                  message: 'Connected to Dr. Sarah Jenkins. Next checkup: Sept 15.',
                  type: ToastType.success,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHealthRadarSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pet Health Radar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: _navigateToPets,
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
              ),
              child: Text(
                'View All (${_pets.length})',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _pets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final pet = _pets[index];
              return _buildPetHealthRadarCard(pet, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetHealthRadarCard(Pet pet, bool isDark) {
    return InkWell(
      onTap: () => _navigateToPetDetail(pet),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 275,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'radar-avatar-${pet.id}',
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.aquaGradient,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: pet.assetImagePath != null
                        ? Image.asset(
                            pet.assetImagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 24)),
                            ),
                          )
                        : Center(child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 24))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pet.breed,
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Mini Biometric Ring
                const LuxuryBiometricRing(
                  percentage: 98,
                  size: 46,
                  strokeWidth: 4.5,
                  glow: false,
                  valueText: '98',
                ),
              ],
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFF43F5E)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Normal Activity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
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
                  onTap: () => _navigateToHealthCheck(initialPet: pet),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Scan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
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
    );
  }
}
