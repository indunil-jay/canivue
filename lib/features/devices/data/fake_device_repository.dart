import 'package:canivue/features/devices/domain/device_repository.dart';
import 'package:canivue/features/devices/domain/smart_collar.dart';

/// In-memory device state per dog, so pairing/renaming/disconnecting in the
/// UI actually sticks for the rest of the session instead of resetting on
/// every rebuild.
class FakeDeviceRepository implements DeviceRepository {
  final Map<String, SmartCollar> _devices = {};

  SmartCollar _initialFor(String dogId) {
    final variant = dogId.hashCode % 3;
    final now = DateTime.now();

    return switch (variant) {
      0 => SmartCollar(
          dogId: dogId,
          name: 'Canivue Smart Collar',
          state: CollarConnectionState.connected,
          batteryPercent: 78,
          lastSyncedAt: now.subtract(const Duration(minutes: 2)),
          syncHistory: [
            SyncEvent(timestamp: now.subtract(const Duration(minutes: 2)), recordsSynced: 142),
            SyncEvent(timestamp: now.subtract(const Duration(hours: 2)), recordsSynced: 118),
            SyncEvent(timestamp: now.subtract(const Duration(hours: 8)), recordsSynced: 96),
          ],
        ),
      1 => SmartCollar(
          dogId: dogId,
          name: 'Canivue Smart Collar',
          state: CollarConnectionState.disconnected,
          batteryPercent: 12,
          lastSyncedAt: now.subtract(const Duration(hours: 6)),
          syncHistory: [
            SyncEvent(timestamp: now.subtract(const Duration(hours: 6)), recordsSynced: 74),
          ],
        ),
      _ => SmartCollar(dogId: dogId, name: 'Canivue Smart Collar', state: CollarConnectionState.notPaired),
    };
  }

  Future<SmartCollar> _current(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 450));
    return _devices.putIfAbsent(dogId, () => _initialFor(dogId));
  }

  @override
  Future<SmartCollar> fetchDevice(String dogId) => _current(dogId);

  @override
  Future<SmartCollar> pairDevice(String dogId) async {
    await _current(dogId);
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now();
    final updated = SmartCollar(
      dogId: dogId,
      name: 'Canivue Smart Collar',
      state: CollarConnectionState.connected,
      batteryPercent: 100,
      lastSyncedAt: now,
      syncHistory: [SyncEvent(timestamp: now, recordsSynced: 0)],
    );
    _devices[dogId] = updated;
    return updated;
  }

  @override
  Future<SmartCollar> disconnectDevice(String dogId) async {
    final current = await _current(dogId);
    final updated = current.copyWith(state: CollarConnectionState.disconnected);
    _devices[dogId] = updated;
    return updated;
  }

  @override
  Future<SmartCollar> renameDevice(String dogId, String newName) async {
    final current = await _current(dogId);
    final updated = current.copyWith(name: newName);
    _devices[dogId] = updated;
    return updated;
  }

  @override
  Future<SmartCollar> syncNow(String dogId) async {
    final current = await _current(dogId);
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();
    final updated = current.copyWith(
      lastSyncedAt: now,
      syncHistory: [SyncEvent(timestamp: now, recordsSynced: 20 + (now.second)), ...current.syncHistory],
    );
    _devices[dogId] = updated;
    return updated;
  }
}
