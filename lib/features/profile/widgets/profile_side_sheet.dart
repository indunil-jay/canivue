import 'package:flutter/material.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/screens/signin_screen.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/profile/screens/personal_information_screen.dart';

class ProfileSideSheet extends StatefulWidget {
  const ProfileSideSheet({
    super.key,
    required this.userEmail,
    this.userName,
  });

  final String userEmail;
  final String? userName;

  @override
  State<ProfileSideSheet> createState() => _ProfileSideSheetState();
}

class _ProfileSideSheetState extends State<ProfileSideSheet> {
  bool _notificationsEnabled = true;
  bool _aiInsightsEnabled = true;

  String get _displayName {
    if (widget.userName != null && widget.userName!.trim().isNotEmpty) {
      return widget.userName!;
    }
    final prefix = widget.userEmail.split('@').first;
    if (prefix.isNotEmpty) {
      return prefix[0].toUpperCase() + prefix.substring(1);
    }
    return 'Pet Parent';
  }

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
      Navigator.of(context).pop(); // Close drawer
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  void _navigateToPersonalInfo() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonalInformationScreen(
          userEmail: widget.userEmail,
          userName: widget.userName,
        ),
      ),
    );
  }

  void _navigateToPets() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PetListScreen(),
      ),
    );
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width > 500 ? 400 : width * 0.85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile & Settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    InkWell(
                      onTap: _navigateToPersonalInfo,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit_rounded, size: 12, color: AppTheme.primaryBlue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.userEmail,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: const Text(
                                      '⭐ Premium Pet Parent',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: My Registered Pets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('MY PETS', theme),
                        TextButton(
                          onPressed: _navigateToPets,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPetTile(
                      name: 'Buddy',
                      breed: 'Golden Retriever • 3 yrs',
                      icon: Icons.pets_rounded,
                      color: Colors.amber,
                      theme: theme,
                      onTap: _navigateToPets,
                    ),
                    _buildPetTile(
                      name: 'Luna',
                      breed: 'German Shepherd • 1.5 yrs',
                      icon: Icons.pets_rounded,
                      color: Colors.orange,
                      theme: theme,
                      onTap: _navigateToPets,
                    ),
                    InkWell(
                      onTap: _navigateToPets,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Add Another Pet',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Account & Health Records
                    _buildSectionHeader('ACCOUNT & RECORDS', theme),
                    const SizedBox(height: 8),
                    _buildNavTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Edit contact & address details',
                      onTap: _navigateToPersonalInfo,
                      theme: theme,
                    ),
                    _buildNavTile(
                      icon: Icons.medical_services_outlined,
                      title: 'Medical & Vet Records',
                      subtitle: 'Vaccinations & prescriptions',
                      onTap: () => _showActionSnackBar('Opening Medical Records'),
                      theme: theme,
                    ),
                    _buildNavTile(
                      icon: Icons.payment_rounded,
                      title: 'Membership & Billing',
                      subtitle: 'Canivue Premium Plan',
                      onTap: () => _showActionSnackBar('Opening Membership & Billing'),
                      theme: theme,
                    ),
                    const SizedBox(height: 24),

                    // Section 3: App Preferences & Health AI
                    _buildSectionHeader('PREFERENCES & AI', theme),
                    const SizedBox(height: 8),
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      title: 'Care Notifications',
                      subtitle: 'Medication & vaccine reminders',
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                      theme: theme,
                    ),
                    _buildSwitchTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'AI Health Insights',
                      subtitle: 'Automated weekly wellness digests',
                      value: _aiInsightsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _aiInsightsEnabled = val;
                        });
                      },
                      theme: theme,
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Support & Security
                    _buildSectionHeader('SUPPORT & LEGAL', theme),
                    const SizedBox(height: 8),
                    _buildNavTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Help Center & 24/7 Vet Chat',
                      subtitle: 'Talk with certified veterinarians',
                      onTap: () => _showActionSnackBar('Connecting to Support...'),
                      theme: theme,
                    ),
                    _buildNavTile(
                      icon: Icons.security_rounded,
                      title: 'Privacy & Security',
                      subtitle: 'Manage permissions & encryption',
                      onTap: () => _showActionSnackBar('Opening Privacy Settings'),
                      theme: theme,
                    ),
                    const SizedBox(height: 20),

                    // Log Out Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout_rounded, color: Colors.red),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildPetTile({
    required String name,
    required String breed,
    required IconData icon,
    required MaterialColor color,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    breed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        secondary: Icon(icon, color: theme.colorScheme.primary, size: 22),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
