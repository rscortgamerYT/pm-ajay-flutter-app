import 'dart:async';
import '../../../features/adarsh_gram/data/models/village_model.dart';
import '../village_repository.dart';
import '../../data/demo_data_provider.dart';
import '../../services/realtime_service.dart';
import '../../storage/local_storage_service.dart';

/// Concrete implementation of VillageRepository for Adarsh Gram module
/// Currently uses demo data, will be replaced with actual API calls
class VillageRepositoryImpl implements VillageRepository {
  final RealtimeService _realtimeService;
  final LocalStorageService _localStorage;
  
  // In-memory cache for quick access
  List<VillageModel>? _cachedVillages;
  
  VillageRepositoryImpl({
    required RealtimeService realtimeService,
    required LocalStorageService localStorage,
  })  : _realtimeService = realtimeService,
        _localStorage = localStorage;

  /// Clear the cache (useful for testing or forced refresh)
  void clearCache() {
    _cachedVillages = null;
  }

  @override
  Future<List<VillageModel>> getVillages() async {
    // Try to get from cache first
    if (_cachedVillages != null) {
      return _cachedVillages!;
    }
    
    // Fallback to demo data (will be replaced with API call)
    final villages = DemoDataProvider.getDemoVillages();
    
    // Cache the result
    _cachedVillages = villages;
    
    return villages;
  }

  @override
  Future<VillageModel> getVillageById(String id) async {
    final villages = await getVillages();
    return villages.firstWhere(
      (v) => v.id == id,
      orElse: () => throw Exception('Village not found: $id'),
    );
  }

  @override
  Future<VillageModel> createVillage(VillageModel village) async {
    // TODO: Implement API call
    final villages = await getVillages();
    final updatedVillages = [...villages, village];
    
    // Update cache
    _cachedVillages = updatedVillages;
    
    return village;
  }

  @override
  Future<VillageModel> updateVillage(VillageModel village) async {
    final villages = await getVillages();
    final index = villages.indexWhere((v) => v.id == village.id);
    
    if (index == -1) {
      throw Exception('Village not found: ${village.id}');
    }
    
    final updatedVillages = [...villages];
    updatedVillages[index] = village;
    
    // Update cache
    _cachedVillages = updatedVillages;
    
    return village;
  }

  @override
  Future<void> deleteVillage(String id) async {
    final villages = await getVillages();
    final updatedVillages = villages.where((v) => v.id != id).toList();
    
    // Update cache
    _cachedVillages = updatedVillages;
  }

  @override
  Future<List<VillageModel>> getEligibleVillages() async {
    final villages = await getVillages();
    return villages
        .where((v) => v.eligibilityStatus == VillageEligibilityStatus.eligible || 
                     v.eligibilityStatus == VillageEligibilityStatus.selected)
        .toList();
  }

  @override
  Future<List<VillageModel>> getIneligibleVillages() async {
    final villages = await getVillages();
    return villages
        .where((v) => v.eligibilityStatus == VillageEligibilityStatus.ineligible)
        .toList();
  }

  @override
  Future<List<VillageModel>> getVillagesByDistrict(String district) async {
    final villages = await getVillages();
    return villages
        .where((v) => v.district.toLowerCase() == district.toLowerCase())
        .toList();
  }

  @override
  Future<List<VillageModel>> getVillagesByState(String state) async {
    final villages = await getVillages();
    return villages
        .where((v) => v.state.toLowerCase() == state.toLowerCase())
        .toList();
  }

  @override
  Future<List<VillageModel>> getVillagesByPriority() async {
    final villages = await getVillages();
    final villagesWithScore = villages.where((v) => v.priorityScore != null).toList();
    villagesWithScore.sort((a, b) => b.priorityScore!.compareTo(a.priorityScore!));
    return villagesWithScore;
  }

  @override
  Future<List<VillageModel>> getVillagesBySelectionStatus(bool isSelected) async {
    final villages = await getVillages();
    if (isSelected) {
      return villages
          .where((v) => v.eligibilityStatus == VillageEligibilityStatus.selected)
          .toList();
    } else {
      return villages
          .where((v) => v.eligibilityStatus != VillageEligibilityStatus.selected)
          .toList();
    }
  }

  @override
  Future<List<VillageModel>> getVillagesByScPopulationRange({
    required double minPercentage,
    required double maxPercentage,
  }) async {
    final villages = await getVillages();
    return villages
        .where((v) => 
            v.scPopulationPercentage >= minPercentage && 
            v.scPopulationPercentage <= maxPercentage)
        .toList();
  }

  @override
  Future<VillageModel> updateVillageSelection(String id, bool isSelected) async {
    final village = await getVillageById(id);
    
    final updatedVillage = village.copyWith(
      eligibilityStatus: isSelected 
          ? VillageEligibilityStatus.selected 
          : VillageEligibilityStatus.eligible,
      selectedDate: isSelected ? DateTime.now() : null,
    );
    
    return updateVillage(updatedVillage);
  }

  @override
  Future<VillageModel> updateVillagePrioritization(
    String id,
    VillagePrioritizationCriteria criteria,
  ) async {
    final village = await getVillageById(id);
    
    // Calculate priority score based on criteria
    // This is a simplified calculation - can be enhanced based on actual requirements
    final score = (village.scPopulationPercentage / 100 * criteria.scPopulationWeight) +
                  ((village.bplHouseholds / village.totalHouseholds) * criteria.bplHouseholdsWeight) +
                  (village.literacyRate / 100 * criteria.literacyRateWeight);
    
    final updatedVillage = village.copyWith(priorityScore: score);
    
    return updateVillage(updatedVillage);
  }

  @override
  Stream<VillageModel> watchVillage(String id) {
    // TODO: Implement real-time updates using RealtimeService
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getVillageById(id);
    }).asyncMap((future) => future);
  }

  @override
  Stream<List<VillageModel>> watchVillages() {
    // TODO: Implement real-time updates using RealtimeService
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getVillages();
    }).asyncMap((future) => future);
  }

  @override
  Stream<List<VillageModel>> watchEligibleVillages() {
    // TODO: Implement real-time updates using RealtimeService
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getEligibleVillages();
    }).asyncMap((future) => future);
  }
}