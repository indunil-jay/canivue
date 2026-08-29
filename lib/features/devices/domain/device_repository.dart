import 'package:canivue/features/devices/domain/smart_collar.dart';

abstract class DeviceRepository {
  Future<SmartCollar> fetchDevice(String dogId);

  /// Simulates a Bluetooth/QR pairing flow completing successfully.
  Future<SmartCollar> pairDevice(String dogId);

  Future<SmartCollar> disconnectDevice(String dogId);

  Future<SmartCollar> renameDevice(String dogId, String newName);

  Future<SmartCollar> syncNow(String dogId);
}
