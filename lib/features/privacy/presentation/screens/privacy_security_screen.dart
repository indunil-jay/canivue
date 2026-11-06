import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';

/// Privacy & clinical telemetry security settings: data permissions, 2FA,
/// active logins, and GDPR data export.
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
    HapticFeedback.lightImpact();
    final confirmed = await AppFeedback.showLuxuryDialog(
      context,
      title: 'Delete Account',
      message: 'This permanently deletes your account, canine telemetry profiles, health records, and messages. This action cannot be reversed.',
      confirmText: 'Delete Account',
      cancelText: 'Cancel',
      icon: Icons.warning_rounded,
      accentColor: const Color(0xFFF43F5E),
      iconGradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]),
    );
    if (confirmed == true && mounted) {
      AppFeedback.showToast(
        context,
        title: 'Deletion Requested',
        message: 'Account deletion is pending administrator verification.',
        type: ToastType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF181A20),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy & Security',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            _sectionLabel('Telehealth Data Sharing', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  _switchTile(
                    title: 'Share vitals with licensed veterinarians',
                    subtitle: 'Continuous collar telemetry and AI predictions are shared with consult clinicians.',
                    value: _shareWithVet,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _shareWithVet = v);
                    },
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  _switchTile(
                    title: 'Share anonymized telemetry for model research',
                    subtitle: 'Improves Canivue AI models. Identifying patient information is stripped.',
                    value: _shareAnonymizedResearch,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _shareAnonymizedResearch = v);
                    },
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  _switchTile(
                    title: 'Location telemetry for clinic discovery',
                    subtitle: 'Used to locate emergency veterinary clinics in your immediate vicinity.',
                    value: _locationServices,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _locationServices = v);
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Account Protection', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  _switchTile(
                    title: 'Two-Factor Authentication (2FA)',
                    subtitle: _twoFactorEnabled
                        ? 'Active — 6-digit verification code required on login.'
                        : 'Add multi-factor security code protection to your account.',
                    value: _twoFactorEnabled,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _twoFactorEnabled = v);
                      AppFeedback.showToast(
                        context,
                        title: v ? '2FA Enabled 🛡️' : '2FA Disabled',
                        message: v
                            ? 'Verification codes are now required during sign-in.'
                            : 'Two-factor authentication has been turned off.',
                        type: v ? ToastType.success : ToastType.warning,
                      );
                    },
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ListTile(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AppFeedback.showToast(
                        context,
                        title: 'Data Export Initiated 📦',
                        message: 'We will email a download package within 24 hours.',
                        type: ToastType.info,
                      );
                    },
                    leading: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.download_rounded, color: Color(0xFF0F766E), size: 18),
                    ),
                    title: Text(
                      'Export Patient Telemetry',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Download an archive of canine medical records, vitals, and logs.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Active Logged-in Devices', isDark),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    for (int i = 0; i < _sessions.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ListTile(
                        leading: Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFF7F5F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.devices_rounded, color: isDark ? Colors.white70 : const Color(0xFF57534E), size: 18),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _sessions[i].device,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_sessions[i].isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Current Device',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${_sessions[i].location} · ${_sessions[i].lastActive}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        trailing: _sessions[i].isCurrent
                            ? null
                            : TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  AppFeedback.showToast(
                                    context,
                                    title: 'Session Revoked',
                                    message: '${_sessions[i].device} was signed out.',
                                    type: ToastType.info,
                                  );
                                },
                                child: Text(
                                  'Revoke',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFF43F5E),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Danger Zone: Delete Account
            OutlinedButton.icon(
              onPressed: _confirmDeleteAccount,
              icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFF43F5E), size: 18),
              label: Text(
                'Delete Canivue Account',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF43F5E),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFF43F5E).withValues(alpha: 0.4), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF10B981),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          height: 1.35,
        ),
      ),
    );
  }
}
