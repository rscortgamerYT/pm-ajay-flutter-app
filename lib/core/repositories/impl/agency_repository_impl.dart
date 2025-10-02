import 'dart:async';
import '../../../domain/entities/agency.dart';
import '../agency_repository.dart';
import '../../data/demo_data_provider.dart';
import '../../services/realtime_service.dart';
import '../../storage/local_storage_service.dart';

/// Concrete implementation of AgencyRepository
class AgencyRepositoryImpl implements AgencyRepository {
  final RealtimeService _realtimeService;
  final LocalStorageService _localStorage;
  
  List<Agency>? _cachedAgencies;
  
  AgencyRepositoryImpl({
    required RealtimeService realtimeService,
    required LocalStorageService localStorage,
  })  : _realtimeService = realtimeService,
        _localStorage = localStorage;

  @override
  Future<List<Agency>> getAgencies() async {
    if (_cachedAgencies != null) {
      return _cachedAgencies!;
    }
    
    final cached = await _localStorage.getAgencies();
    if (cached.isNotEmpty) {
      _cachedAgencies = cached;
      return cached;
    }
    
    final agencies = DemoDataProvider.getDemoAgencies();
    _cachedAgencies = agencies;
    await _localStorage.saveAgencies(agencies);
    
    return agencies;
  }

  @override
  Future<Agency> getAgencyById(String id) async {
    final agencies = await getAgencies();
    return agencies.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Agency not found: $id'),
    );
  }

  @override
  Future<Agency> createAgency(Agency agency) async {
    final agencies = await getAgencies();
    final updatedAgencies = [...agencies, agency];
    
    _cachedAgencies = updatedAgencies;
    await _localStorage.saveAgencies(updatedAgencies);
    
    return agency;
  }

  @override
  Future<Agency> updateAgency(Agency agency) async {
    final agencies = await getAgencies();
    final index = agencies.indexWhere((a) => a.id == agency.id);
    
    if (index == -1) {
      throw Exception('Agency not found: ${agency.id}');
    }
    
    final updatedAgencies = [...agencies];
    updatedAgencies[index] = agency;
    
    _cachedAgencies = updatedAgencies;
    await _localStorage.saveAgencies(updatedAgencies);
    
    return agency;
  }

  @override
  Future<void> deleteAgency(String id) async {
    final agencies = await getAgencies();
    final updatedAgencies = agencies.where((a) => a.id != id).toList();
    
    _cachedAgencies = updatedAgencies;
    await _localStorage.saveAgencies(updatedAgencies);
  }

  @override
  Future<List<Agency>> getAgenciesByType(AgencyType type) async {
    final agencies = await getAgencies();
    return agencies.where((a) => a.type == type).toList();
  }

  @override
  Future<List<Agency>> getAgenciesByStatus(AgencyStatus status) async {
    final agencies = await getAgencies();
    return agencies.where((a) => a.status == status).toList();
  }

  @override
  Future<List<Agency>> getConnectedAgencies(String agencyId) async {
    final agency = await getAgencyById(agencyId);
    final allAgencies = await getAgencies();
    
    return allAgencies
        .where((a) => agency.connectedAgencyIds.contains(a.id))
        .toList();
  }

  @override
  Future<List<Agency>> getAgenciesWithLowCoordination({double threshold = 0.5}) async {
    final agencies = await getAgencies();
    return agencies
        .where((a) => a.coordinationScore < threshold)
        .toList()
      ..sort((a, b) => a.coordinationScore.compareTo(b.coordinationScore));
  }

  @override
  Future<void> updateCoordinationScore(String agencyId, double score) async {
    final agency = await getAgencyById(agencyId);
    final updatedAgency = agency.copyWith(
      coordinationScore: score,
      updatedAt: DateTime.now(),
    );
    await updateAgency(updatedAgency);
  }

  @override
  Stream<Agency> watchAgency(String id) {
    return _realtimeService.watchProject(id).map((project) {
      // This is a placeholder - in production, implement proper agency streaming
      throw UnimplementedError('Agency streaming not yet implemented');
    });
  }

  @override
  Stream<List<Agency>> watchAgencies() {
    return _realtimeService.watchAgencies();
  }

  void clearCache() {
    _cachedAgencies = null;
  }
}