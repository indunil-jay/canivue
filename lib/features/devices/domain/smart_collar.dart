/// Wearable / smart-collar management (brief §14).
enum CollarConnectionState { connected, disconnected, notPaired, pairing }

class SyncEvent {
  const SyncEvent({required this.timestamp, required this.recordsSynced});

  final DateTime timestamp;
  final int recordsSynced;
}

class SmartCollar {
  const SmartCollar({
    required this.dogId,
    required this.name,
    required this.state,
    this.batteryPercent,
    this.lastSyncedAt,
    this.firmwareVersion = '3.2.1',
    this.syncHistory = const [],
    this.grantedPermissions = const ['Activity & Motion', 'Heart Rate', 'Location'],
  });

  final String dogId;
  final String name;
  final CollarConnectionState state;
  final int? batteryPercent;
  final DateTime? lastSyncedAt;
  final String firmwareVersion;
  final List<SyncEvent> syncHistory;
  final List<String> grantedPermissions;

  SmartCollar copyWith({
    String? name,
    CollarConnectionState? state,
    int? batteryPercent,
    DateTime? lastSyncedAt,
    List<SyncEvent>? syncHistory,
    List<String>? grantedPermissions,
  }) {
    return SmartCollar(
      dogId: dogId,
      name: name ?? this.name,
      state: state ?? this.state,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      firmwareVersion: firmwareVersion,
      syncHistory: syncHistory ?? this.syncHistory,
      grantedPermissions: grantedPermissions ?? this.grantedPermissions,
    );
  }
}
