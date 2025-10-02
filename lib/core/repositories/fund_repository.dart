import '../../domain/entities/fund.dart';

/// Abstract repository for fund-related operations
abstract class FundRepository {
  /// Fetches all funds
  Future<List<Fund>> getFunds();
  
  /// Fetches a single fund by ID
  Future<Fund> getFundById(String id);
  
  /// Creates a new fund
  Future<Fund> createFund(Fund fund);
  
  /// Updates an existing fund
  Future<Fund> updateFund(Fund fund);
  
  /// Deletes a fund
  Future<void> deleteFund(String id);
  
  /// Fetches funds by status
  Future<List<Fund>> getFundsByStatus(FundStatus status);
  
  /// Fetches delayed funds
  Future<List<Fund>> getDelayedFunds();
  
  /// Fetches available funds (not fully allocated)
  Future<List<Fund>> getAvailableFunds();
  
  /// Predicts fund release date using AI
  Future<DateTime> predictFundReleaseDate(String fundId);
  
  /// Allocates fund to a project
  Future<void> allocateFund(String fundId, String projectId, double amount);
  
  /// Stream of real-time fund updates
  Stream<Fund> watchFund(String id);
  
  /// Stream of all funds
  Stream<List<Fund>> watchFunds();
}