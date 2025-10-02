import 'package:equatable/equatable.dart';
import '../../../domain/entities/citizen.dart';

/// Enhanced citizen report model with additional fields
class CitizenReportModel extends Equatable {
  final String id;
  final String citizenId;
  final String? projectId;
  final ReportType type;
  final String title;
  final String description;
  final ReportPriority priority;
  final ReportStatus status;
  final List<String> attachments; // Photo URLs
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? assignedAgencyId;
  final String? assignedOfficerId;
  final bool isAnonymous;
  final int upvotes;
  final List<String> upvotedBy;
  final List<ReportComment> comments;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final DateTime updatedAt;

  const CitizenReportModel({
    required this.id,
    required this.citizenId,
    this.projectId,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.attachments = const [],
    this.latitude,
    this.longitude,
    this.address,
    this.assignedAgencyId,
    this.assignedOfficerId,
    this.isAnonymous = false,
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.comments = const [],
    required this.createdAt,
    this.assignedAt,
    this.resolvedAt,
    required this.updatedAt,
  });

  CitizenReportModel copyWith({
    String? id,
    String? citizenId,
    String? projectId,
    ReportType? type,
    String? title,
    String? description,
    ReportPriority? priority,
    ReportStatus? status,
    List<String>? attachments,
    double? latitude,
    double? longitude,
    String? address,
    String? assignedAgencyId,
    String? assignedOfficerId,
    bool? isAnonymous,
    int? upvotes,
    List<String>? upvotedBy,
    List<ReportComment>? comments,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? resolvedAt,
    DateTime? updatedAt,
  }) {
    return CitizenReportModel(
      id: id ?? this.id,
      citizenId: citizenId ?? this.citizenId,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      assignedAgencyId: assignedAgencyId ?? this.assignedAgencyId,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      upvotes: upvotes ?? this.upvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        citizenId,
        projectId,
        type,
        title,
        description,
        priority,
        status,
        attachments,
        latitude,
        longitude,
        address,
        assignedAgencyId,
        assignedOfficerId,
        isAnonymous,
        upvotes,
        upvotedBy,
        comments,
        createdAt,
        assignedAt,
        resolvedAt,
        updatedAt,
      ];
}

class ReportComment extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final bool isOfficial; // From government official

  const ReportComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isOfficial = false,
  });

  @override
  List<Object?> get props => [id, authorId, authorName, content, createdAt, isOfficial];
}