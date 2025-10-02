import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simplified VDP Provider for basic CRUD operations
final vdpProvider = StateNotifierProvider<VDPNotifier, Map<String, dynamic>>((ref) {
  return VDPNotifier();
});

class VDPNotifier extends StateNotifier<Map<String, dynamic>> {
  VDPNotifier() : super({});

  Future<void> createVDP(String villageId, Map<String, dynamic> vdpData) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    state = {...state, villageId: vdpData};
  }

  Future<void> updateVDP(String villageId, Map<String, dynamic> vdpData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = {...state, villageId: vdpData};
  }

  Future<Map<String, dynamic>?> loadVDP(String villageId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return state[villageId];
  }

  void clearVDP() {
    state = {};
  }
}