import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/devices/presentation/screens/device_management_screen.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

/// Compact wearable/smart-collar connection status for the dashboard (brief
/// §14) — tapping opens the full device management screen (pairing,
/// battery, sync history, troubleshooting).
class DeviceStatusChip extends StatelessWidget {
  const DeviceStatusChip({super.key, required this.device, required this.dogId, required this.dogName});

  final DeviceStatus device;
  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (icon, color, label) = switch (device.state) {
      DeviceConnectionState.connected => (
          Icons.bluetooth_connected_rounded,
          isDark ? AppColors.successOnDark : AppColors.success,
          'Connected${device.batteryPercent != null ? ' · ${device.batteryPercent}% battery' : ''}',
        ),
      DeviceConnectionState.disconnected => (
          Icons.bluetooth_disabled_rounded,
          isDark ? AppColors.warningOnDark : AppColors.warning,
          'Disconnected — tap to troubleshoot',
        ),
      DeviceConnectionState.notPaired => (
          Icons.bluetooth_searching_rounded,
          isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          'No smart collar paired',
        ),
    };

    final syncLabel = device.lastSyncedAt != null ? 'Last synced ${DateFormat('h:mm a').format(device.lastSyncedAt!)}' : null;

    return InkWell(
      borderRadius: AppRadius.pillRadius,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DeviceManagementScreen(dogId: dogId, dogName: dogName)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.14 : 0.08),
          borderRadius: AppRadius.pillRadius,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                syncLabel == null ? label : '$label · $syncLabel',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
