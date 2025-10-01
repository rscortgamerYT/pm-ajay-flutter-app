import 'package:equatable/equatable.dart';

/// Represents a blockchain record for transparency and auditability
class BlockchainRecord extends Equatable {
  final String id;
  final String transactionHash;
  final String blockHash;
  final int blockNumber;
  final String contractAddress;
  final BlockchainRecordType type;
  final String entityId; // ID of the project, fund, or agency
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? previousRecordId;
  final BlockchainNetwork network;
  final BlockchainStatus status;

  const BlockchainRecord({
    required this.id,
    required this.transactionHash,
    required this.blockHash,
    required this.blockNumber,
    required this.contractAddress,
    required this.type,
    required this.entityId,
    required this.data,
    required this.timestamp,
    this.previousRecordId,
    required this.network,
    required this.status,
  });

  BlockchainRecord copyWith({
    String? id,
    String? transactionHash,
    String? blockHash,
    int? blockNumber,
    String? contractAddress,
    BlockchainRecordType? type,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? previousRecordId,
    BlockchainNetwork? network,
    BlockchainStatus? status,
  }) {
    return BlockchainRecord(
      id: id ?? this.id,
      transactionHash: transactionHash ?? this.transactionHash,
      blockHash: blockHash ?? this.blockHash,
      blockNumber: blockNumber ?? this.blockNumber,
      contractAddress: contractAddress ?? this.contractAddress,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      previousRecordId: previousRecordId ?? this.previousRecordId,
      network: network ?? this.network,
      status: status ?? this.status,
    );
  }

  String get explorerUrl {
    final baseUrl = network == BlockchainNetwork.ethereum
        ? 'https://etherscan.io'
        : 'https://sepolia.etherscan.io';
    return '$baseUrl/tx/$transactionHash';
  }

  @override
  List<Object?> get props => [
        id,
        transactionHash,
        blockHash,
        blockNumber,
        contractAddress,
        type,
        entityId,
        data,
        timestamp,
        previousRecordId,
        network,
        status,
      ];
}

enum BlockchainRecordType {
  projectCreation,
  projectUpdate,
  fundAllocation,
  fundRelease,
  approval,
  milestone,
  statusChange,
  other,
}

enum BlockchainNetwork {
  ethereum,
  sepolia, // Testnet
  polygon,
  other,
}

enum BlockchainStatus {
  pending,
  confirmed,
  failed,
}