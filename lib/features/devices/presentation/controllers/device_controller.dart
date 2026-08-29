import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/devices/data/fake_device_repository.dart';
import 'package:canivue/features/devices/domain/device_repository.dart';
import 'package:canivue/features/devices/domain/smart_collar.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) => FakeDeviceRepository());

class DeviceController extends FamilyAsyncNotifier<SmartCollar, String> {
  late final String _dogId;

  @override
  Future<SmartCollar> build(String dogId) {
    _dogId = dogId;
    return ref.watch(deviceRepositoryProvider).fetchDevice(dogId);
  }

  Future<void> pair() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(deviceRepositoryProvider).pairDevice(_dogId));
  }

  Future<void> disconnect() async {
    state = await AsyncValue.guard(() => ref.read(deviceRepositoryProvider).disconnectDevice(_dogId));
  }

  Future<void> rename(String newName) async {
    state = await AsyncValue.guard(() => ref.read(deviceRepositoryProvider).renameDevice(_dogId, newName));
  }

  Future<void> syncNow() async {
    state = await AsyncValue.guard(() => ref.read(deviceRepositoryProvider).syncNow(_dogId));
  }
}

final deviceControllerProvider = AsyncNotifierProvider.family<DeviceController, SmartCollar, String>(DeviceController.new);
