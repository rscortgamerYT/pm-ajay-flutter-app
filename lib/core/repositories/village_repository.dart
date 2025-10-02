import '../../features/adarsh_gram/data/models/village_model.dart';

/// Abstract repository for village-related operations in Adarsh Gram module
/// This enables dependency injection and testability
abstract class VillageRepository {
  /// Fetches all villages
  Future<List<VillageModel>> getVillages();
  
  /// Fetches a single village by ID
  Future<VillageModel> getVillageById(String id);
  
  /// Creates a new village entry
  Future<VillageModel> createVillage(VillageModel village);
  
  /// Updates an existing village
  Future<VillageModel> updateVillage(VillageModel village);
  
  /// Deletes a village entry
  Future<void> deleteVillage(String id);
  
  /// Fetches eligible villages (≥50% SC population as per PM-AJAY guidelines)
  Future<List<VillageModel>> getEligibleVillages();
  
  /// Fetches ineligible villages (<50% SC population)
  Future<List<VillageModel>> getIneligibleVillages();
  
  /// Fetches villages by district
  Future<List<VillageModel>> getVillagesByDistrict(String district);
  
  /// Fetches villages by state
  Future<List<VillageModel>> getVillagesByState(String state);
  
  /// Fetches villages sorted by prioritization score (highest first)
  Future<List<VillageModel>> getVillagesByPriority();
  
  /// Fetches villages by selection status (selected/not selected)
  Future<List<VillageModel>> getVillagesBySelectionStatus(bool isSelected);
  
  /// Fetches villages within a specific SC population percentage range
  Future<List<VillageModel>> getVillagesByScPopulationRange({
    required double minPercentage,
    required double maxPercentage,
  });
  
  /// Updates village selection status
  Future<VillageModel> updateVillageSelection(String id, bool isSelected);
  
  /// Calculates and updates prioritization score for a village
  Future<VillageModel> updateVillagePrioritization(
    String id,
    VillagePrioritizationCriteria criteria,
  );
  
  /// Stream of real-time village updates
  Stream<VillageModel> watchVillage(String id);
  
  /// Stream of all villages
  Stream<List<VillageModel>> watchVillages();
  
  /// Stream of eligible villages only
  Stream<List<VillageModel>> watchEligibleVillages();
}