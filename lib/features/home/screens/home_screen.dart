import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/luxury_biometric_ring.dart';
import 'package:canivue/core/widgets/luxury_stat_card.dart';
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
          initialPet: initialPet,
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ProfileSideSheet(
        userEmail: widget.userEmail,
        userName: widget.userName,
      ),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_displayName 👋',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Canine Health Intelligence',
                    style: GoogleFonts.plusJakartaSans(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: const [
          NotificationBadgeButton(),
          SizedBox(width: 8),
        ],
      ),
      body: _currentIndex == 1 ? const PetListScreen() : _buildDashboardBody(theme, colorScheme, isDark),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1524).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home', isDark),
                _buildNavItem(1, Icons.pets_rounded, Icons.pets_outlined, 'My Pets', isDark),
                _buildNavItem(2, Icons.analytics_rounded, Icons.analytics_outlined, 'Telemetry', isDark),
                _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profile', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryBlue.withValues(alpha: 0.22) : const Color(0xFFEFF6FF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected
                  ? (isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue)
                  : (isDark ? Colors.white60 : const Color(0xFF94A3B8)),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBody(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search / Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.8) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: isDark ? Colors.white60 : const Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search pets, health telemetry, records...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Vitality Cockpit Hero Banner (Inspired by Carbit & AthletiQ)
            InkWell(
              onTap: () => _navigateToHealthCheck(),
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF0C2142), Color(0xFF091A36), Color(0xFF061126)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.4 : 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left Telemetry Descriptions & Status Pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 8,
                                  width: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.emeraldAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'GPS Synced • 72 bpm',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Canine Health Cockpit',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Multimodal AI fusing visual scans, bio-collar metrics & symptom signals.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Quick Run AI Check Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  'Launch AI Scanner',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Circular Biometric Vitality Ring Dial
                    const LuxuryBiometricRing(
                      percentage: 98,
                      size: 104,
                      strokeWidth: 9,
                      valueText: '98',
                      unitText: '%',
                      label: 'Vitality',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Telemetry Grid Row (Carbit / AthletiQ Style)
            Row(
              children: [
                Expanded(
                  child: LuxuryStatCard(
                    title: 'Active Steps',
                    value: '8,450',
                    unit: '/ 10k',
                    icon: Icons.directions_walk_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badgeText: '+12% wk',
                    progress: 0.84,
                    onTap: () {
                      AppFeedback.showToast(
                        context,
                        title: 'Daily Activity Telemetry 🏃',
                        message: 'Max reached 8,450 / 10,000 steps today. 84% of daily goal completed!',
                        type: ToastType.info,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: LuxuryStatCard(
                    title: 'Deep Rest',
                    value: '9.4',
                    unit: 'hrs',
                    icon: Icons.nightlight_round,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badgeText: 'Optimal',
                    badgeColor: const Color(0xFF10B981),
                    progress: 0.94,
                    onTap: () {
                      AppFeedback.showToast(
                        context,
                        title: 'Sleep Telemetry 🌙',
                        message: '9.4 hours of restful canine REM sleep tracked via smart collar.',
                        type: ToastType.success,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Pet Health Radar Header
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

            // Pet Health Radar Slider
            SizedBox(
              height: 175,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _pets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final pet = _pets[index];
                  return _buildPetHealthRadarCard(pet, theme, colorScheme, isDark);
                },
              ),
            ),
            const SizedBox(height: 28),

            // Quick Services Header
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

            // Quick Action Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.22,
              children: [
                _buildServiceCard(
                  title: 'Health Check',
                  subtitle: 'Multimodal AI Vision',
                  icon: Icons.health_and_safety_rounded,
                  gradient: AppTheme.primaryGradient,
                  isDark: isDark,
                  onTap: () => _navigateToHealthCheck(),
                ),
                _buildServiceCard(
                  title: 'Vaccinations',
                  subtitle: 'Schedule & Alerts',
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
                _buildServiceCard(
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
                _buildServiceCard(
                  title: 'Vet Bookings',
                  subtitle: 'Consultations',
                  icon: Icons.calendar_month_rounded,
                  gradient: AppTheme.emeraldGradient,
                  isDark: isDark,
                  onTap: () {
                    AppFeedback.showToast(
                      context,
                      title: 'Vet Booking 🗓️',
                      message: 'Connected to Dr. Sarah Jenkins (Bay Area Vet). Next checkup: Sept 15.',
                      type: ToastType.success,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHealthRadarCard(Pet pet, ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return InkWell(
      onTap: () => _navigateToPetDetail(pet),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 275,
        padding: const EdgeInsets.all(16),
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
                  tag: 'pet-avatar-${pet.id}',
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
                            errorBuilder: (_, _, _) => Center(
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

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.85) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
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
                fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}
