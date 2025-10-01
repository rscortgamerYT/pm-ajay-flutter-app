import 'package:equatable/equatable.dart';

/// Represents a citizen who can interact with the PM-AJAY system
class Citizen extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? whatsapp;
  final String? address;
  final String? district;
  final String? state;
  final String? pincode;
  final List<CitizenReport> reports;
  final CitizenStatus status;
  final DateTime registeredAt;
  final DateTime lastActiveAt;

  const Citizen({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.whatsapp,
    this.address,
    this.district,
    this.state,
    this.pincode,
    required this.reports,
    required this.status,
    required this.registeredAt,
    required this.lastActiveAt,
  });

  Citizen copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? whatsapp,
    String? address,
    String? district,
    String? state,
    String? pincode,
    List<CitizenReport>? reports,
    CitizenStatus? status,
    DateTime? registeredAt,
    DateTime? lastActiveAt,
  }) {
    return Citizen(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      reports: reports ?? this.reports,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        whatsapp,
        address,
        district,
        state,
        pincode,
        reports,
        status,
        registeredAt,
        lastActiveAt,
      ];
}

enum CitizenStatus {
  active,
  inactive,
  blocked,
}

/// Represents a report submitted by a citizen
class CitizenReport extends Equatable {
  final String id;
  final String citizenId;
  final ReportType type;
  final String title;
  final String description;
  final String? projectId;
  final String? agencyId;
  final ReportPriority priority;
  final ReportStatus status;
  final List<String> attachments;
  final double? latitude;
  final double? longitude;
  final String? assignedAgencyId;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final int? rating;
  final String? feedback;

  const CitizenReport({
    required this.id,
    required this.citizenId,
    required this.type,
    required this.title,
    required this.description,
    this.projectId,
    this.agencyId,
    required this.priority,
    required this.status,
    required this.attachments,
    this.latitude,
    this.longitude,
    this.assignedAgencyId,
    required this.createdAt,
    this.assignedAt,
    this.resolvedAt,
    this.resolution,
    this.rating,
    this.feedback,
  });

  CitizenReport copyWith({
    String? id,
    String? citizenId,
    ReportType? type,
    String? title,
    String? description,
    String? projectId,
    String? agencyId,
    ReportPriority? priority,
    ReportStatus? status,
    List<String>? attachments,
    double? latitude,
    double? longitude,
    String? assignedAgencyId,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? resolvedAt,
    String? resolution,
    int? rating,
    String? feedback,
  }) {
    return CitizenReport(
      id: id ?? this.id,
      citizenId: citizenId ?? this.citizenId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      agencyId: agencyId ?? this.agencyId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      assignedAgencyId: assignedAgencyId ?? this.assignedAgencyId,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        id,
        citizenId,
        type,
        title,
        description,
        projectId,
        agencyId,
        priority,
        status,
        attachments,
        latitude,
        longitude,
        assignedAgencyId,
        createdAt,
        assignedAt,
        resolvedAt,
        resolution,
        rating,
        feedback,
      ];
}

enum ReportType {
  complaint,
  suggestion,
  inquiry,
  projectUpdate,
  qualityIssue,
  fundMisuse,
  other,
}

enum ReportPriority {
  low,
  medium,
  high,
  urgent,
}

enum ReportStatus {
  submitted,
  assigned,
  inProgress,
  resolved,
  closed,
  rejected,
}