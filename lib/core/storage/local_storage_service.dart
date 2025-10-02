import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/agency.dart';
import '../../domain/entities/fund.dart';

/// Service for local data persistence using Hive
class LocalStorageService {
  static const String _projectsBox = 'projects';
  static const String _agenciesBox = 'agencies';
  static const String _fundsBox = 'funds';
  static const String _citizensBox = 'citizens';
  static const String _reportsBox = 'citizen_reports';
  static const String _preferencesBox = 'preferences';
  static const String _syncQueueBox = 'sync_queue';
  
  /// Initializes Hive and opens all boxes
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters for custom types
    // TODO: Generate adapters using hive_generator
    
    // Open boxes
    await Hive.openBox(_projectsBox);
    await Hive.openBox(_agenciesBox);
    await Hive.openBox(_fundsBox);
    await Hive.openBox(_citizensBox);
    await Hive.openBox(_reportsBox);
    await Hive.openBox(_preferencesBox);
    await Hive.openBox(_syncQueueBox);
  }
  
  // ===== Project Operations =====
  
  Future<void> saveProjects(List<Project> projects) async {
    final box = Hive.box(_projectsBox);
    final map = {for (var p in projects) p.id: _projectToMap(p)};
    await box.putAll(map);
  }
  
  Future<List<Project>> getProjects() async {
    final box = Hive.box(_projectsBox);
    return box.values
        .map((v) => _mapToProject(Map<String, dynamic>.from(v as Map)))
        .toList();
  }
  
  Future<Project?> getProject(String id) async {
    final box = Hive.box(_projectsBox);
    final data = box.get(id);
    if (data == null) return null;
    return _mapToProject(Map<String, dynamic>.from(data as Map));
  }
  
  Future<void> saveProject(Project project) async {
    final box = Hive.box(_projectsBox);
    await box.put(project.id, _projectToMap(project));
  }
  
  Future<void> deleteProject(String id) async {
    final box = Hive.box(_projectsBox);
    await box.delete(id);
  }
  
  // ===== Agency Operations =====
  
  Future<void> saveAgencies(List<Agency> agencies) async {
    final box = Hive.box(_agenciesBox);
    final map = {for (var a in agencies) a.id: _agencyToMap(a)};
    await box.putAll(map);
  }
  
  Future<List<Agency>> getAgencies() async {
    final box = Hive.box(_agenciesBox);
    return box.values
        .map((v) => _mapToAgency(Map<String, dynamic>.from(v as Map)))
        .toList();
  }
  
  Future<Agency?> getAgency(String id) async {
    final box = Hive.box(_agenciesBox);
    final data = box.get(id);
    if (data == null) return null;
    return _mapToAgency(Map<String, dynamic>.from(data as Map));
  }
  
  Future<void> saveAgency(Agency agency) async {
    final box = Hive.box(_agenciesBox);
    await box.put(agency.id, _agencyToMap(agency));
  }
  
  // ===== Fund Operations =====
  
  Future<void> saveFunds(List<Fund> funds) async {
    final box = Hive.box(_fundsBox);
    final map = {for (var f in funds) f.id: _fundToMap(f)};
    await box.putAll(map);
  }
  
  Future<List<Fund>> getFunds() async {
    final box = Hive.box(_fundsBox);
    return box.values
        .map((v) => _mapToFund(Map<String, dynamic>.from(v as Map)))
        .toList();
  }
  
  // ===== Citizen Report Operations =====
  
  Future<void> saveReport(dynamic report) async {
    final box = Hive.box(_reportsBox);
    await box.put(report.id, report);
  }
  
  Future<dynamic> getReport(String id) async {
    final box = Hive.box(_reportsBox);
    return box.get(id);
  }
  
  Future<void> deleteReport(String id) async {
    final box = Hive.box(_reportsBox);
    await box.delete(id);
  }
  
  Future<List<dynamic>> getAllReports() async {
    final box = Hive.box(_reportsBox);
    return box.values.toList();
  }
  
  // ===== Preferences Operations =====
  
  Future<void> setPreference(String key, dynamic value) async {
    final box = Hive.box(_preferencesBox);
    await box.put(key, value);
  }
  
  T? getPreference<T>(String key) {
    final box = Hive.box(_preferencesBox);
    return box.get(key) as T?;
  }
  
  // ===== Sync Queue Operations =====
  
  Future<void> addToSyncQueue(Map<String, dynamic> operation) async {
    final box = Hive.box(_syncQueueBox);
    await box.add({
      ...operation,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final box = Hive.box(_syncQueueBox);
    return box.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }
  
  Future<void> clearSyncQueue() async {
    final box = Hive.box(_syncQueueBox);
    await box.clear();
  }
  
  // ===== Cache Management =====
  
  Future<void> clearAllCache() async {
    await Hive.box(_projectsBox).clear();
    await Hive.box(_agenciesBox).clear();
    await Hive.box(_fundsBox).clear();
    await Hive.box(_citizensBox).clear();
    await Hive.box(_reportsBox).clear();
  }
  
  Future<int> getCacheSize() async {
    int total = 0;
    total += Hive.box(_projectsBox).length;
    total += Hive.box(_agenciesBox).length;
    total += Hive.box(_fundsBox).length;
    total += Hive.box(_citizensBox).length;
    total += Hive.box(_reportsBox).length;
    return total;
  }
  
  // ===== Serialization Helpers =====
  
  Map<String, dynamic> _projectToMap(Project project) {
    // Simplified serialization - in production, use json_serializable
    return {
      'id': project.id,
      'name': project.name,
      'type': project.type.name,
      'description': project.description,
      'implementingAgencyId': project.implementingAgencyId,
      'executingAgencyId': project.executingAgencyId,
      'status': project.status.name,
      'completionPercentage': project.completionPercentage,
      'startDate': project.startDate.toIso8601String(),
      'expectedEndDate': project.expectedEndDate.toIso8601String(),
      'updatedAt': project.updatedAt.toIso8601String(),
    };
  }
  
  Project _mapToProject(Map<String, dynamic> map) {
    // Simplified deserialization - in production, use json_serializable
    throw UnimplementedError('Full deserialization not yet implemented');
  }
  
  Map<String, dynamic> _agencyToMap(Agency agency) {
    return {
      'id': agency.id,
      'name': agency.name,
      'type': agency.type.name,
      'coordinationScore': agency.coordinationScore,
      'status': agency.status.name,
    };
  }
  
  Agency _mapToAgency(Map<String, dynamic> map) {
    throw UnimplementedError('Full deserialization not yet implemented');
  }
  
  Map<String, dynamic> _fundToMap(Fund fund) {
    return {
      'id': fund.id,
      'name': fund.name,
      'amount': fund.amount,
      'status': fund.status.name,
    };
  }
  
  Fund _mapToFund(Map<String, dynamic> map) {
    throw UnimplementedError('Full deserialization not yet implemented');
  }
}