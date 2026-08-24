import 'package:flutter/material.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/screens/signin_screen.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
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
  final List<Pet> _pets = List.of(Pet.samplePets);

  String get _displayName {
    if (widget.userName != null && widget.userName!.trim().isNotEmpty) {
      return widget.userName!;
    }
    final emailPrefix = widget.userEmail.split('@').first;
    if (emailPrefix.isNotEmpty) {
      return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
    }
    return 'Pet Parent';
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of Canivue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
  void _handleLogout() async {
    final confirmed = await AppFeedback.showLuxuryDialog(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of Canivue?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
      icon: Icons.logout_rounded,
      accentColor: const Color(0xFFF43F5E),
      iconGradient: const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  void _openProfileSideSheet() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _navigateToPets() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _navigateToHealthCheck() {
  void _navigateToHealthCheck({Pet? initialPet}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(pets: Pet.samplePets),
        builder: (_) => HealthCheckCaptureScreen(
          pets: _pets,
          initialPet: initialPet ?? _pets.first,
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

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ProfileSideSheet(
        userEmail: widget.userEmail,
        userName: widget.userName,
      ),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: InkWell(
          onTap: _openProfileSideSheet,
          borderRadius: BorderRadius.circular(12),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.aquaGradient,
                    gradient: AppTheme.heroGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Welcome to Canivue',
                      'Canine Health Intelligence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No new notifications.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              AppFeedback.showToast(
                context,
                title: 'All Caught Up! 🐾',
                message: 'All pet health trackers and vaccines are up to date.',
                type: ToastType.success,
              );
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 15,
              radius: 16,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
              child: const Icon(Icons.person_rounded, size: 18, color: AppTheme.primaryBlue),
            ),
            tooltip: 'Profile & Settings',
            onPressed: _openProfileSideSheet,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _currentIndex == 1 ? const PetListScreen() : _buildDashboardBody(theme, colorScheme),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 3) {
            _openProfileSideSheet();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'My Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search / Filter Banner
            // Search / Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search pets, records, symptoms...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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

            // Overview Blue Gradient Hero Banner
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
            // AI Multimodal Diagnostic Hero Banner
            InkWell(
              onTap: () => _navigateToHealthCheck(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
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
                                    color: AppTheme.cyanAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'AI Scanner Online',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          child: const Text(
                            '✨ Canine Health AI',
                          const SizedBox(height: 12),
                          const Text(
                            'Multimodal AI Health Detection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Multimodal AI Health Detection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          const SizedBox(height: 6),
                          Text(
                            'Fuse visual images, collar telemetry & symptom notes into real-time health scores.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.aquaGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Fuse photos, collar data & symptoms to forecast health risks early.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanAccent.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Pet Health Radar Carousel Slider Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pet Health Radar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ],
                ),
                TextButton(
                  onPressed: _navigateToPets,
                  child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pet Health Radar Slider
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _pets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final pet = _pets[index];
                  return _buildPetHealthRadarCard(pet, theme, colorScheme);
                },
              ),
            ),
            const SizedBox(height: 28),

            // Quick Actions Header
            Text(
              'Quick Services',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
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
              childAspectRatio: 1.25,
              children: [
                _buildServiceCard(
                  title: 'Health Check',
                  subtitle: 'AI Symptom Scan',
                  icon: Icons.health_and_safety_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF00B4D8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  gradient: AppTheme.primaryGradient,
                  theme: theme,
                  onTap: _navigateToHealthCheck,
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
                  theme: theme,
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
                  title: 'Pet Profiles',
                  subtitle: 'Medical History',
                  icon: Icons.badge_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  theme: theme,
                  onTap: _navigateToPets,
                ),
                _buildServiceCard(
                  title: 'Appointments',
                  subtitle: 'Vet Consultations',
                  icon: Icons.calendar_month_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  gradient: AppTheme.emeraldGradient,
                  theme: theme,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPetHealthRadarCard(Pet pet, ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _navigateToPetDetail(pet),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.06),
              blurRadius: 14,
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
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.aquaGradient,
                      borderRadius: BorderRadius.circular(16),
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
                        ? Image.asset(pet.assetImagePath!, fit: BoxFit.cover)
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pet.breed,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '98% Good',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFF43F5E)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Normal Activity',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
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
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Scan',
                          style: TextStyle(
                            fontSize: 11,
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
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.04),
              blurRadius: 12,
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
