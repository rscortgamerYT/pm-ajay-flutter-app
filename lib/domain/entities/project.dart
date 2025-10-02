import 'package:equatable/equatable.dart';

/// Represents a project in the PM-AJAY system
class Project extends Equatable {
  final String id;
  final String name;
  final ProjectType type;
  final String description;
  final String implementingAgencyId;
  final String executingAgencyId;
  final String? allocatedFundId;
  final ProjectStatus status;
  final List<Milestone> milestones;
  final GeoLocation location;
  final DateTime startDate;
  final DateTime expectedEndDate;
  final DateTime? actualEndDate;
  final double completionPercentage;
  final List<Alert> alerts;
  final String? blockchainRecordId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.implementingAgencyId,
    required this.executingAgencyId,
    this.allocatedFundId,
    required this.status,
    required this.milestones,
    required this.location,
    required this.startDate,
    required this.expectedEndDate,
    this.actualEndDate,
    required this.completionPercentage,
    required this.alerts,
    this.blockchainRecordId,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Project copyWith({
    String? id,
    String? name,
    ProjectType? type,
    String? description,
    String? implementingAgencyId,
    String? executingAgencyId,
    String? allocatedFundId,
    ProjectStatus? status,
    List<Milestone>? milestones,
    GeoLocation? location,
    DateTime? startDate,
    DateTime? expectedEndDate,
    DateTime? actualEndDate,
    double? completionPercentage,
    List<Alert>? alerts,
    String? blockchainRecordId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      implementingAgencyId: implementingAgencyId ?? this.implementingAgencyId,
      executingAgencyId: executingAgencyId ?? this.executingAgencyId,
      allocatedFundId: allocatedFundId ?? this.allocatedFundId,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      alerts: alerts ?? this.alerts,
      blockchainRecordId: blockchainRecordId ?? this.blockchainRecordId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDelayed {
    if (actualEndDate != null) return false;
    return DateTime.now().isAfter(expectedEndDate) && status != ProjectStatus.completed;
  }

  bool get hasAlerts => alerts.isNotEmpty;

  Duration get remainingDuration {
    if (actualEndDate != null || status == ProjectStatus.completed) {
      return Duration.zero;
    }
    final now = DateTime.now();
    return expectedEndDate.difference(now);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        implementingAgencyId,
        executingAgencyId,
        allocatedFundId,
        status,
        milestones,
        location,
        startDate,
        expectedEndDate,
        actualEndDate,
        completionPercentage,
        alerts,
        blockchainRecordId,
        metadata,
        createdAt,
        updatedAt,
      ];
}

enum ProjectType {
  adarshGram,
  gia,
  hostel,
  other,
}

enum ProjectStatus {
  planning,
  approved,
  inProgress,
  delayed,
  completed,
  suspended,
  cancelled,
}

class Milestone extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime targetDate;
  final DateTime? completedDate;
  final MilestoneStatus status;
  final double weightage;

  const Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.targetDate,
    this.completedDate,
    required this.status,
    required this.weightage,
  });

  Milestone copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? targetDate,
    DateTime? completedDate,
    MilestoneStatus? status,
    double? weightage,
  }) {
    return Milestone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      weightage: weightage ?? this.weightage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetDate,
        completedDate,
        status,
        weightage,
      ];
}

enum MilestoneStatus {
  pending,
  inProgress,
  completed,
  delayed,
}

class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? district;
  final String? state;
  final String? pincode;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.district,
    this.state,
    this.pincode,
  });

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? district,
    String? state,
    String? pincode,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        district,
        state,
        pincode,
      ];
}

class Alert extends Equatable {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;

  const Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isResolved,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
  });

  Alert copyWith({
    String? id,
    AlertType? type,
    AlertSeverity? severity,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolution,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        severity,
        title,
        description,
        createdAt,
        isResolved,
        resolvedAt,
        resolvedBy,
        resolution,
      ];
}

enum AlertType {
  delay,
  fundShortage,
  qualityIssue,
  coordinationIssue,
  documentMissing,
  complianceIssue,
  other,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}