import 'dart:async';
import '../../../domain/entities/fund.dart';
import '../fund_repository.dart';
import '../../data/demo_data_provider.dart';
import '../../services/realtime_service.dart';
import '../../storage/local_storage_service.dart';

/// Concrete implementation of FundRepository
class FundRepositoryImpl implements FundRepository {
  final RealtimeService _realtimeService;
  final LocalStorageService _localStorage;
  
  List<Fund>? _cachedFunds;
  
  FundRepositoryImpl({
    required RealtimeService realtimeService,
    required LocalStorageService localStorage,
  })  : _realtimeService = realtimeService,
        _localStorage = localStorage;

  @override
  Future<List<Fund>> getFunds() async {
    if (_cachedFunds != null) {
      return _cachedFunds!;
    }
    
    final cached = await _localStorage.getFunds();
    if (cached.isNotEmpty) {
      _cachedFunds = cached;
      return cached;
    }
    
    final funds = DemoDataProvider.getDemoFunds();
    _cachedFunds = funds;
    await _localStorage.saveFunds(funds);
    
    return funds;
  }

  @override
  Future<Fund> getFundById(String id) async {
    final funds = await getFunds();
    return funds.firstWhere(
      (f) => f.id == id,
      orElse: () => throw Exception('Fund not found: $id'),
    );
  }

  @override
  Future<Fund> createFund(Fund fund) async {
    final funds = await getFunds();
    final updatedFunds = [...funds, fund];
    
    _cachedFunds = updatedFunds;
    await _localStorage.saveFunds(updatedFunds);
    
    return fund;
  }

  @override
  Future<Fund> updateFund(Fund fund) async {
    final funds = await getFunds();
    final index = funds.indexWhere((f) => f.id == fund.id);
    
    if (index == -1) {
      throw Exception('Fund not found: ${fund.id}');
    }
    
    final updatedFunds = [...funds];
    updatedFunds[index] = fund;
    
    _cachedFunds = updatedFunds;
    await _localStorage.saveFunds(updatedFunds);
    
    return fund;
  }

  @override
  Future<void> deleteFund(String id) async {
    final funds = await getFunds();
    final updatedFunds = funds.where((f) => f.id != id).toList();
    
    _cachedFunds = updatedFunds;
    await _localStorage.saveFunds(updatedFunds);
  }

  @override
  Future<List<Fund>> getFundsByStatus(FundStatus status) async {
    final funds = await getFunds();
    return funds.where((f) => f.status == status).toList();
  }

  @override
  Future<List<Fund>> getDelayedFunds() async {
    final funds = await getFunds();
    return funds.where((f) => f.isDelayed).toList();
  }

  @override
  Future<List<Fund>> getAvailableFunds() async {
    final funds = await getFunds();
    return funds.where((f) => !f.isFullyAllocated).toList();
  }

  @override
  Future<DateTime> predictFundReleaseDate(String fundId) async {
    final fund = await getFundById(fundId);
    
    if (fund.predictedReleaseDate != null) {
      return fund.predictedReleaseDate!;
    }
    
    // AI prediction logic
    // Factor in approval chain length, historical data, etc.
    const approvalDaysPerStep = 5;
    final daysToRelease = fund.approvalChain.length * approvalDaysPerStep;
    
    return DateTime.now().add(Duration(days: daysToRelease));
  }

  @override
  Future<void> allocateFund(String fundId, String projectId, double amount) async {
    final fund = await getFundById(fundId);
    
    if (fund.remainingAmount < amount) {
      throw Exception('Insufficient funds available');
    }
    
    final allocation = FundAllocation(
      id: 'ALLOC_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      amount: amount,
      allocationDate: DateTime.now(),
      status: FundAllocationStatus.approved,
    );
    
    final updatedFund = fund.copyWith(
      allocations: [...fund.allocations, allocation],
      updatedAt: DateTime.now(),
    );
    
    await updateFund(updatedFund);
  }

  @override
  Stream<Fund> watchFund(String id) {
    return _realtimeService.watchFunds().map((funds) {
      return funds.firstWhere(
        (f) => f.id == id,
        orElse: () => throw Exception('Fund not found: $id'),
      );
    });
  }

  @override
  Stream<List<Fund>> watchFunds() {
    return _realtimeService.watchFunds();
  }

  void clearCache() {
    _cachedFunds = null;
  }
}