import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';

/// Privacy & security settings (brief §29) — data-sharing controls, 2FA,
/// session management and account data controls. Because this is a
/// healthcare-adjacent app, every toggle here states plainly what it shares
/// and with whom.
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _shareWithVet = true;
  bool _shareAnonymizedResearch = false;
  bool _locationServices = true;
  bool _twoFactorEnabled = false;

  final _sessions = const [
    (device: 'Chrome on Windows', location: 'San Francisco, CA', lastActive: 'Active now', isCurrent: true),
    (device: 'Canivue iOS App', location: 'San Francisco, CA', lastActive: '2 hours ago', isCurrent: false),
    (device: 'Safari on macOS', location: 'Oakland, CA', lastActive: '5 days ago', isCurrent: false),
  ];

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await AppFeedback.showLuxuryDialog(
      context,
      title: 'Delete Account',
      message: 'This permanently deletes your account, dogs, health records and messages. This cannot be undone.',
      confirmText: 'Delete Account',
      cancelText: 'Cancel',
      icon: Icons.warning_rounded,
      accentColor: const Color(0xFFF43F5E),
      iconGradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]),
    );
    if (confirmed == true && mounted) {
      AppFeedback.showToast(context, title: 'Deletion requested', message: 'Account deletion isn\'t available in this preview build.', type: ToastType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Data Sharing', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          _switchTile(
            title: 'Share health data with veterinarian',
            subtitle: 'Vitals, AI predictions and records are visible to vets you consult with.',
            value: _shareWithVet,
            onChanged: (v) => setState(() => _shareWithVet = v),
          ),
          _switchTile(
            title: 'Share anonymized data for research',
            subtitle: 'Helps improve Canivue\'s AI models. Never includes identifying information.',
            value: _shareAnonymizedResearch,
            onChanged: (v) => setState(() => _shareAnonymizedResearch = v),
          ),
          _switchTile(
            title: 'Location services',
            subtitle: 'Used to find nearby veterinarians and clinics.',
            value: _locationServices,
            onChanged: (v) => setState(() => _locationServices = v),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Security', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          _switchTile(
            title: 'Two-Factor Authentication',
            subtitle: _twoFactorEnabled ? 'Enabled — a code is required at sign-in.' : 'Add an extra layer of protection to your account.',
            value: _twoFactorEnabled,
            onChanged: (v) {
              setState(() => _twoFactorEnabled = v);
              AppFeedback.showToast(
                context,
                title: v ? 'Two-Factor Authentication Enabled' : 'Two-Factor Authentication Disabled',
                message: v ? 'You\'ll be asked for a verification code at your next sign-in.' : 'Your account now relies on password only.',
                type: v ? ToastType.success : ToastType.warning,
              );
            },
          ),
          _navTile(
            icon: Icons.download_rounded,
            title: 'Export My Data',
            subtitle: 'Download a copy of your dogs\' health data and records.',
            onTap: () => AppFeedback.showToast(context, title: 'Export requested', message: 'We\'ll email you a download link within 24 hours.', type: ToastType.info),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Sessions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: AppRadius.xlRadius,
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _sessions.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ListTile(
                    leading: Icon(Icons.devices_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    title: Row(
                      children: [
                        Flexible(child: Text(_sessions[i].device, overflow: TextOverflow.ellipsis)),
                        if (_sessions[i].isCurrent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: AppRadius.pillRadius),
                            child: Text('This device', style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.successOnDark : AppColors.success, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text('${_sessions[i].location} · ${_sessions[i].lastActive}'),
                    trailing: _sessions[i].isCurrent
                        ? null
                        : TextButton(
                            onPressed: () => AppFeedback.showToast(context, title: 'Signed out', message: '${_sessions[i].device} has been signed out.', type: ToastType.info),
                            child: const Text('Log out'),
                          ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmDeleteAccount,
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              label: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade200), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ),
    );
  }

  Widget _navTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
