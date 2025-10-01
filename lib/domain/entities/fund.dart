import 'package:equatable/equatable.dart';

/// Represents a fund allocation in the PM-AJAY system
class Fund extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String source;
  final FundStatus status;
  final List<FundAllocation> allocations;
  final DateTime releaseDate;
  final DateTime? predictedReleaseDate;
  final List<String> approvalChain;
  final String? blockchainRecordId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Fund({
    required this.id,
    required this.name,
    required this.amount,
    required this.source,
    required this.status,
    required this.allocations,
    required this.releaseDate,
    this.predictedReleaseDate,
    required this.approvalChain,
    this.blockchainRecordId,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Fund copyWith({
    String? id,
    String? name,
    double? amount,
    String? source,
    FundStatus? status,
    List<FundAllocation>? allocations,
    DateTime? releaseDate,
    DateTime? predictedReleaseDate,
    List<String>? approvalChain,
    String? blockchainRecordId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Fund(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      status: status ?? this.status,
      allocations: allocations ?? this.allocations,
      releaseDate: releaseDate ?? this.releaseDate,
      predictedReleaseDate: predictedReleaseDate ?? this.predictedReleaseDate,
      approvalChain: approvalChain ?? this.approvalChain,
      blockchainRecordId: blockchainRecordId ?? this.blockchainRecordId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get allocatedAmount {
    return allocations.fold(0.0, (sum, allocation) => sum + allocation.amount);
  }

  double get remainingAmount {
    return amount - allocatedAmount;
  }

  bool get isFullyAllocated => remainingAmount <= 0;

  bool get isDelayed {
    if (status == FundStatus.released) return false;
    return DateTime.now().isAfter(releaseDate);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        source,
        status,
        allocations,
        releaseDate,
        predictedReleaseDate,
        approvalChain,
        blockchainRecordId,
        metadata,
        createdAt,
        updatedAt,
      ];
}

enum FundStatus {
  pending,
  approved,
  released,
  partiallyAllocated,
  fullyAllocated,
  delayed,
  cancelled,
}

class FundAllocation extends Equatable {
  final String id;
  final String projectId;
  final double amount;
  final DateTime allocationDate;
  final FundAllocationStatus status;
  final String? remarks;

  const FundAllocation({
    required this.id,
    required this.projectId,
    required this.amount,
    required this.allocationDate,
    required this.status,
    this.remarks,
  });

  FundAllocation copyWith({
    String? id,
    String? projectId,
    double? amount,
    DateTime? allocationDate,
    FundAllocationStatus? status,
    String? remarks,
  }) {
    return FundAllocation(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      amount: amount ?? this.amount,
      allocationDate: allocationDate ?? this.allocationDate,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        amount,
        allocationDate,
        status,
        remarks,
      ];
}

enum FundAllocationStatus {
  pending,
  approved,
  disbursed,
  completed,
}