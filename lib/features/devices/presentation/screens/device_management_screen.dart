import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/devices/domain/smart_collar.dart';
import 'package:canivue/features/devices/presentation/controllers/device_controller.dart';

/// Wearable / smart-collar management (brief §14): pairing, connection &
/// battery status, sync history, permissions, rename and disconnect — with
/// real troubleshooting for the disconnected state rather than just a
/// spinner.
class DeviceManagementScreen extends ConsumerWidget {
  const DeviceManagementScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceControllerProvider(dogId));

    return Scaffold(
      appBar: AppBar(title: Text('$dogName\'s Device')),
      body: deviceAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [SkeletonBox(height: 140), SizedBox(height: 16), SkeletonBox(height: 200)]),
        ),
        error: (_, _) => ErrorState(
          message: "We couldn't load this device.",
          onRetry: () => ref.invalidate(deviceControllerProvider(dogId)),
        ),
        data: (device) => _DeviceBody(dogId: dogId, device: device),
      ),
    );
  }
}

class _DeviceBody extends ConsumerWidget {
  const _DeviceBody({required this.dogId, required this.device});

  final String dogId;
  final SmartCollar device;

  Future<void> _startPairing(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
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
        title: const Text('Rename Device'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save')),
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
      title: 'Disconnect Device',
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
      return _NotPairedView(onPair: () => _startPairing(context, ref));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final connected = device.state == CollarConnectionState.connected;

    return RefreshIndicator(
      onRefresh: () => ref.read(deviceControllerProvider(dogId).notifier).syncNow(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: connected ? AppColors.primaryGradient : null,
              color: connected ? null : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: AppRadius.xlRadius,
              border: connected ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      connected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded,
                      color: connected ? Colors.white : (isDark ? AppColors.warningOnDark : AppColors.warning),
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _rename(context, ref),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                device.name,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: connected ? Colors.white : null),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_rounded, size: 14, color: connected ? Colors.white70 : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  connected ? 'Connected' : 'Disconnected',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: connected ? Colors.white : (isDark ? AppColors.warningOnDark : AppColors.warning)),
                ),
                if (device.batteryPercent != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.battery_full_rounded, size: 16, color: connected ? Colors.white70 : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      const SizedBox(width: 4),
                      Text(
                        'Battery ${device.batteryPercent}%',
                        style: theme.textTheme.bodySmall?.copyWith(color: connected ? Colors.white70 : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ),
                    ],
                  ),
                ],
                if (device.lastSyncedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Last synchronized ${DateFormat('MMM d, h:mm a').format(device.lastSyncedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: connected ? Colors.white70 : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (connected)
                  FilledButton.icon(
                    onPressed: () => ref.read(deviceControllerProvider(dogId).notifier).syncNow(),
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const Text('Sync Now'),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Some health data may be unavailable while disconnected.', style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      _troubleshootTip(context, 'Make sure the collar is charged and within Bluetooth range.'),
                      _troubleshootTip(context, 'Toggle Bluetooth off and on, then reopen the Canivue app.'),
                      _troubleshootTip(context, 'If the light on the collar is off, hold the button for 3 seconds to wake it.'),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: () => ref.read(deviceControllerProvider(dogId).notifier).pair(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reconnect'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Sync History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          if (device.syncHistory.isEmpty)
            Text('No sync history yet.', style: theme.textTheme.bodySmall)
          else
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: AppRadius.xlRadius,
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < device.syncHistory.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ListTile(
                      leading: Icon(Icons.sync_rounded, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                      title: Text(DateFormat('MMM d, yyyy · h:mm a').format(device.syncHistory[i].timestamp)),
                      subtitle: Text('${device.syncHistory[i].recordsSynced} records synced'),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Permissions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: device.grantedPermissions
                .map((permission) => Chip(
                      avatar: Icon(Icons.check_circle_rounded, size: 16, color: isDark ? AppColors.successOnDark : AppColors.success),
                      label: Text(permission),
                    ))
                .toList(),
          ),
          if (connected) ...[
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _disconnect(context, ref),
                icon: const Icon(Icons.bluetooth_disabled_rounded, color: Colors.red),
                label: const Text('Disconnect Device', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade200)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _troubleshootTip(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _NotPairedView extends StatelessWidget {
  const _NotPairedView({required this.onPair});

  final VoidCallback onPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.bluetooth_searching_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('No smart collar paired', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pair a Canivue smart collar to start tracking heart rate, activity, sleep and more automatically.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(onPressed: onPair, icon: const Icon(Icons.add_rounded), label: const Text('Pair a New Device')),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const SizedBox(height: 48, width: 48, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: AppSpacing.xl),
          Text('Scanning for nearby devices…', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Text('Make sure the collar is powered on and within range.', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
