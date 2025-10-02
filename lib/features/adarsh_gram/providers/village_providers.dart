import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/repositories/village_repository.dart';
import '../../../core/repositories/impl/village_repository_impl.dart';
import '../data/models/village_model.dart';

// Service Providers
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Repository Provider
final villageRepositoryProvider = Provider<VillageRepository>((ref) {
  return VillageRepositoryImpl(
    realtimeService: ref.watch(realtimeServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

// Village Notifier
class VillageNotifier extends StateNotifier<AsyncValue<List<VillageModel>>> {
  final VillageRepository _repository;

  VillageNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadVillages();
  }

  Future<void> _loadVillages() async {
    try {
      final villages = await _repository.getVillages();
      state = AsyncValue.data(villages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadVillages();
  }

  Future<void> createVillage(VillageModel village) async {
    try {
      await _repository.createVillage(village);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateVillage(VillageModel village) async {
    try {
      await _repository.updateVillage(village);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteVillage(String villageId) async {
    try {
      await _repository.deleteVillage(villageId);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> selectVillage(String villageId) async {
    try {
      await _repository.updateVillageSelection(villageId, true);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePrioritization(
    String villageId,
    VillagePrioritizationCriteria criteria,
  ) async {
    try {
      await _repository.updateVillagePrioritization(villageId, criteria);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Main Villages Provider
final villagesProvider =
    StateNotifierProvider<VillageNotifier, AsyncValue<List<VillageModel>>>(
  (ref) {
    final repository = ref.watch(villageRepositoryProvider);
    return VillageNotifier(repository);
  },
);

// Single Village Provider
final villageProvider =
    FutureProvider.family<VillageModel?, String>((ref, villageId) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getVillageById(villageId);
});

// Filtered Villages Providers
final eligibleVillagesProvider =
    FutureProvider<List<VillageModel>>((ref) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getEligibleVillages();
});

final ineligibleVillagesProvider =
    FutureProvider<List<VillageModel>>((ref) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getIneligibleVillages();
});

final selectedVillagesProvider =
    FutureProvider<List<VillageModel>>((ref) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getVillagesBySelectionStatus(true);
});

final prioritizedVillagesProvider =
    FutureProvider<List<VillageModel>>((ref) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getVillagesByPriority();
});

// Geographic Filters
final villagesByDistrictProvider =
    FutureProvider.family<List<VillageModel>, String>((ref, district) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getVillagesByDistrict(district);
});

final villagesByStateProvider =
    FutureProvider.family<List<VillageModel>, String>((ref, state) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getVillagesByState(state);
});

// SC Population Range Filter
final villagesBySCPopulationProvider = FutureProvider.family<
    List<VillageModel>,
    ({double minPercentage, double maxPercentage})>((ref, range) async {
  final repository = ref.watch(villageRepositoryProvider);
  return await repository.getVillagesByScPopulationRange(
    minPercentage: range.minPercentage,
    maxPercentage: range.maxPercentage,
  );
});

// Stream Providers
final villageStreamProvider =
    StreamProvider.family<VillageModel?, String>((ref, villageId) {
  final repository = ref.watch(villageRepositoryProvider);
  return repository.watchVillage(villageId);
});

final villagesStreamProvider = StreamProvider<List<VillageModel>>((ref) {
  final repository = ref.watch(villageRepositoryProvider);
  return repository.watchVillages();
});

final eligibleVillagesStreamProvider =
    StreamProvider<List<VillageModel>>((ref) {
  final repository = ref.watch(villageRepositoryProvider);
  return repository.watchEligibleVillages();
});

// Statistics Provider
final villageStatsProvider = Provider<VillageStatistics>((ref) {
  final villagesAsync = ref.watch(villagesProvider);

  return villagesAsync.when(
    data: (villages) {
      final total = villages.length;
      final eligible = villages
          .where((v) => v.eligibilityStatus == VillageEligibilityStatus.eligible)
          .length;
      final selected = villages
          .where((v) => v.eligibilityStatus == VillageEligibilityStatus.selected)
          .length;
      final completed = villages
          .where((v) => v.eligibilityStatus == VillageEligibilityStatus.completed)
          .length;
      final pending = villages
          .where((v) => v.eligibilityStatus == VillageEligibilityStatus.pending)
          .length;
      final ineligible = villages
          .where((v) => v.eligibilityStatus == VillageEligibilityStatus.ineligible)
          .length;

      final totalPopulation = villages.fold<int>(
        0,
        (sum, v) => sum + v.totalPopulation,
      );

      final totalSCPopulation = villages.fold<int>(
        0,
        (sum, v) => sum + v.scPopulation,
      );

      final averageSCPercentage = villages.isEmpty
          ? 0.0
          : villages.fold<double>(
                0.0,
                (sum, v) => sum + v.scPopulationPercentage,
              ) /
              villages.length;

      final averageLiteracyRate = villages.isEmpty
          ? 0.0
          : villages.fold<double>(
                0.0,
                (sum, v) => sum + v.literacyRate,
              ) /
              villages.length;

      final averagePriorityScore = villages
              .where((v) => v.priorityScore != null && v.priorityScore! > 0)
              .isEmpty
          ? 0.0
          : villages
                  .where((v) => v.priorityScore != null && v.priorityScore! > 0)
                  .fold<double>(
                    0.0,
                    (sum, v) => sum + v.priorityScore!,
                  ) /
              villages
                  .where((v) => v.priorityScore != null && v.priorityScore! > 0)
                  .length;

      return VillageStatistics(
        totalVillages: total,
        eligibleVillages: eligible,
        selectedVillages: selected,
        completedVillages: completed,
        pendingVillages: pending,
        ineligibleVillages: ineligible,
        totalPopulation: totalPopulation,
        totalSCPopulation: totalSCPopulation,
        averageSCPercentage: averageSCPercentage,
        averageLiteracyRate: averageLiteracyRate,
        averagePriorityScore: averagePriorityScore,
      );
    },
    loading: () => VillageStatistics.empty(),
    error: (_, __) => VillageStatistics.empty(),
  );
});

// Village Statistics Model
class VillageStatistics {
  final int totalVillages;
  final int eligibleVillages;
  final int selectedVillages;
  final int completedVillages;
  final int pendingVillages;
  final int ineligibleVillages;
  final int totalPopulation;
  final int totalSCPopulation;
  final double averageSCPercentage;
  final double averageLiteracyRate;
  final double averagePriorityScore;

  const VillageStatistics({
    required this.totalVillages,
    required this.eligibleVillages,
    required this.selectedVillages,
    required this.completedVillages,
    required this.pendingVillages,
    required this.ineligibleVillages,
    required this.totalPopulation,
    required this.totalSCPopulation,
    required this.averageSCPercentage,
    required this.averageLiteracyRate,
    required this.averagePriorityScore,
  });

  factory VillageStatistics.empty() {
    return const VillageStatistics(
      totalVillages: 0,
      eligibleVillages: 0,
      selectedVillages: 0,
      completedVillages: 0,
      pendingVillages: 0,
      ineligibleVillages: 0,
      totalPopulation: 0,
      totalSCPopulation: 0,
      averageSCPercentage: 0.0,
      averageLiteracyRate: 0.0,
      averagePriorityScore: 0.0,
    );
  }

  double get eligibilityRate =>
      totalVillages > 0 ? (eligibleVillages / totalVillages) * 100 : 0.0;

  double get selectionRate =>
      eligibleVillages > 0 ? (selectedVillages / eligibleVillages) * 100 : 0.0;

  double get completionRate =>
      selectedVillages > 0 ? (completedVillages / selectedVillages) * 100 : 0.0;

  double get scPopulationPercentage => totalPopulation > 0
      ? (totalSCPopulation / totalPopulation) * 100
      : 0.0;
}