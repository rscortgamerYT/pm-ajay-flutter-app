import 'package:equatable/equatable.dart';

/// Represents a document in the system
class DocumentModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final DocumentType type;
  final String fileUrl;
  final String? thumbnailUrl;
  final int fileSizeBytes;
  final String mimeType;
  final String uploadedBy;
  final String? projectId;
  final String? agencyId;
  final DocumentStatus status;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final String? ocrText;
  final bool isConfidential;
  final DateTime uploadedAt;
  final DateTime? expiryDate;
  final DateTime updatedAt;
  final List<DocumentVersion> versions;
  final List<DocumentApproval> approvals;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploadedBy,
    this.projectId,
    this.agencyId,
    required this.status,
    this.tags = const [],
    this.metadata,
    this.ocrText,
    this.isConfidential = false,
    required this.uploadedAt,
    this.expiryDate,
    required this.updatedAt,
    this.versions = const [],
    this.approvals = const [],
  });

  DocumentModel copyWith({
    String? id,
    String? name,
    String? description,
    DocumentType? type,
    String? fileUrl,
    String? thumbnailUrl,
    int? fileSizeBytes,
    String? mimeType,
    String? uploadedBy,
    String? projectId,
    String? agencyId,
    DocumentStatus? status,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? ocrText,
    bool? isConfidential,
    DateTime? uploadedAt,
    DateTime? expiryDate,
    DateTime? updatedAt,
    List<DocumentVersion>? versions,
    List<DocumentApproval>? approvals,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      projectId: projectId ?? this.projectId,
      agencyId: agencyId ?? this.agencyId,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      ocrText: ocrText ?? this.ocrText,
      isConfidential: isConfidential ?? this.isConfidential,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      updatedAt: updatedAt ?? this.updatedAt,
      versions: versions ?? this.versions,
      approvals: approvals ?? this.approvals,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        fileUrl,
        thumbnailUrl,
        fileSizeBytes,
        mimeType,
        uploadedBy,
        projectId,
        agencyId,
        status,
        tags,
        metadata,
        ocrText,
        isConfidential,
        uploadedAt,
        expiryDate,
        updatedAt,
        versions,
        approvals,
      ];
}

enum DocumentType {
  tender,
  contract,
  compliance,
  report,
  blueprint,
  invoice,
  certificate,
  permit,
  correspondence,
  other,
}

enum DocumentStatus {
  draft,
  pending,
  approved,
  rejected,
  archived,
}

class DocumentVersion extends Equatable {
  final String id;
  final int versionNumber;
  final String fileUrl;
  final String uploadedBy;
  final String? changeDescription;
  final DateTime uploadedAt;

  const DocumentVersion({
    required this.id,
    required this.versionNumber,
    required this.fileUrl,
    required this.uploadedBy,
    this.changeDescription,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [
        id,
        versionNumber,
        fileUrl,
        uploadedBy,
        changeDescription,
        uploadedAt,
      ];
}

class DocumentApproval extends Equatable {
  final String id;
  final String approverId;
  final String approverName;
  final bool approved;
  final String? comments;
  final DateTime timestamp;

  const DocumentApproval({
    required this.id,
    required this.approverId,
    required this.approverName,
    required this.approved,
    this.comments,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        approverId,
        approverName,
        approved,
        comments,
        timestamp,
      ];
}