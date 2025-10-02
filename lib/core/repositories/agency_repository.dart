import '../../domain/entities/agency.dart';

/// Abstract repository for agency-related operations
abstract class AgencyRepository {
  /// Fetches all agencies
  Future<List<Agency>> getAgencies();
  
  /// Fetches a single agency by ID
  Future<Agency> getAgencyById(String id);
  
  /// Creates a new agency
  Future<Agency> createAgency(Agency agency);
  
  /// Updates an existing agency
  Future<Agency> updateAgency(Agency agency);
  
  /// Deletes an agency
  Future<void> deleteAgency(String id);
  
  /// Fetches agencies by type
  Future<List<Agency>> getAgenciesByType(AgencyType type);
  
  /// Fetches agencies by status
  Future<List<Agency>> getAgenciesByStatus(AgencyStatus status);
  
  /// Fetches connected agencies for a given agency
  Future<List<Agency>> getConnectedAgencies(String agencyId);
  
  /// Fetches agencies with low coordination scores
  Future<List<Agency>> getAgenciesWithLowCoordination({double threshold = 0.5});
  
  /// Updates coordination score for an agency
  Future<void> updateCoordinationScore(String agencyId, double score);
  
  /// Stream of real-time agency updates
  Stream<Agency> watchAgency(String id);
  
  /// Stream of all agencies
  Stream<List<Agency>> watchAgencies();
}