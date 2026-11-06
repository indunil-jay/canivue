import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/devices/domain/smart_collar.dart';
import 'package:canivue/features/devices/presentation/controllers/device_controller.dart';

/// Smart-collar telemetry hardware hub: real-time BLE pairing, battery & sync
/// history, sensor permissions, and telemetry diagnostics.
class DeviceManagementScreen extends ConsumerWidget {
  const DeviceManagementScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceControllerProvider(dogId));
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
          '$dogName\'s Collar',
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
        child: deviceAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SkeletonBox(height: 140, borderRadius: BorderRadius.all(Radius.circular(24))),
                SizedBox(height: 16),
                SkeletonBox(height: 200, borderRadius: BorderRadius.all(Radius.circular(24))),
              ],
            ),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load this device.",
            onRetry: () => ref.invalidate(deviceControllerProvider(dogId)),
          ),
          data: (device) => _DeviceBody(dogId: dogId, dogName: dogName, device: device),
        ),
      ),
    );
  }
}

class _DeviceBody extends ConsumerWidget {
  const _DeviceBody({required this.dogId, required this.dogName, required this.device});

  final String dogId;
  final String dogName;
  final SmartCollar device;

  Future<void> _startPairing(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => const _PairingSheet(),
    );
    await ref.read(deviceControllerProvider(dogId).notifier).pair();
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: device.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Rename Collar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && context.mounted) {
      await ref.read(deviceControllerProvider(dogId).notifier).rename(newName);
    }
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppFeedback.showLuxuryDialog(
      context,
      title: 'Disconnect Collar',
      message: 'You can reconnect ${device.name} at any time.',
      confirmText: 'Disconnect',
      cancelText: 'Cancel',
      icon: Icons.bluetooth_disabled_rounded,
      accentColor: const Color(0xFFF43F5E),
      iconGradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]),
    );
    if (confirmed == true) {
      await ref.read(deviceControllerProvider(dogId).notifier).disconnect();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (device.state == CollarConnectionState.notPaired) {
      return _NotPairedView(dogName: dogName, onPair: () => _startPairing(context, ref));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connected = device.state == CollarConnectionState.connected;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(deviceControllerProvider(dogId).notifier).syncNow(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // Device Status Hero Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: connected
                  ? const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: connected ? null : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(28),
              border: connected ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: (connected ? AppColors.primary : Colors.black).withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: connected ? 0.22 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        connected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded,
                        color: connected ? Colors.white : (isDark ? AppColors.warningOnDark : AppColors.warning),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _rename(context, ref),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                device.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: connected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: connected ? Colors.white70 : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: connected ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    connected ? '● Active Telemetry Connected' : '○ Collar Offline',
                    style: GoogleFonts.plusJakartaSans(
                      color: connected ? Colors.white : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                if (device.batteryPercent != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.battery_5_bar_rounded, size: 16, color: connected ? Colors.white70 : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      const SizedBox(width: 6),
                      Text(
                        'Battery ${device.batteryPercent}% · Good for ~5 days',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: connected ? Colors.white70 : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
                if (device.lastSyncedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last synchronized ${DateFormat('MMM d · h:mm a').format(device.lastSyncedAt!)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: connected ? Colors.white60 : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (connected)
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(deviceControllerProvider(dogId).notifier).syncNow();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: Text(
                      'Sync Now',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(deviceControllerProvider(dogId).notifier).pair();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reconnect Collar'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sync History
          _sectionLabel('Collar Sync Records', isDark),
          const SizedBox(height: 8),
          if (device.syncHistory.isEmpty)
            Text('No sync history recorded yet.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))
          else
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
                    for (int i = 0; i < device.syncHistory.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ListTile(
                        leading: Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.sync_rounded, color: Color(0xFF0F766E), size: 18),
                        ),
                        title: Text(
                          DateFormat('MMM d, yyyy · h:mm a').format(device.syncHistory[i].timestamp),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${device.syncHistory[i].recordsSynced} biometric points transferred',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Granted Permissions
          _sectionLabel('Hardware Permissions', isDark),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: device.grantedPermissions
                .map(
                  (permission) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x2210B981) : AppColors.pastelMintSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Text(
                          permission,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),

          if (connected) ...[
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => _disconnect(context, ref),
              icon: const Icon(Icons.bluetooth_disabled_rounded, color: Color(0xFFF43F5E), size: 18),
              label: Text(
                'Disconnect Collar',
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
        ],
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
}

class _NotPairedView extends StatelessWidget {
  const _NotPairedView({required this.dogName, required this.onPair});
  final String dogName;
  final VoidCallback onPair;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sensors_rounded, size: 40, color: Color(0xFF0F766E)),
            ),
            const SizedBox(height: 18),
            Text(
              'No Collar Connected',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pair Canive Smart Collar with $dogName to begin real-time activity, sleep and heart rate telemetry monitoring.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPair,
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              icon: const Icon(Icons.bluetooth_searching_rounded, size: 18),
              label: Text(
                'Pair Smart Collar',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairingSheet extends StatelessWidget {
  const _PairingSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0F766E)),
          const SizedBox(height: 18),
          Text(
            'Searching for nearby Canive collar…',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Hold the pairing button on the collar until the indicator pulses green.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
