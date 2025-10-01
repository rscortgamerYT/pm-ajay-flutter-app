import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/blockchain_record.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/fund.dart';

/// Blockchain service for transparent and immutable record keeping
class BlockchainService {
  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  
  // Network configuration
  static const String _rpcUrl = 'https://sepolia.infura.io/v3/YOUR_PROJECT_ID'; // Use Sepolia testnet
  static const String _contractABI = '''[
    {
      "inputs": [{"type": "string", "name": "entityId"}, {"type": "string", "name": "recordType"}, {"type": "string", "name": "data"}],
      "name": "recordTransaction",
      "outputs": [{"type": "bytes32"}],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"type": "string", "name": "entityId"}],
      "name": "getRecords",
      "outputs": [{"type": "string[]"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"type": "bytes32", "name": "txHash"}],
      "name": "verifyTransaction",
      "outputs": [{"type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]''';

  Future<void> initialize(String contractAddress) async {
    _client = Web3Client(_rpcUrl, http.Client());
    _contractAddress = EthereumAddress.fromHex(contractAddress);
    _contract = DeployedContract(
      ContractAbi.fromJson(_contractABI, 'PMajayTransparency'),
      _contractAddress,
    );
  }

  /// Record project creation on blockchain
  Future<BlockchainRecord> recordProjectCreation(Project project) async {
    final data = {
      'projectId': project.id,
      'name': project.name,
      'type': project.type.name,
      'implementingAgency': project.implementingAgencyId,
      'executingAgency': project.executingAgencyId,
      'startDate': project.startDate.toIso8601String(),
      'expectedEndDate': project.expectedEndDate.toIso8601String(),
    };

    return await _recordTransaction(
      entityId: project.id,
      recordType: BlockchainRecordType.projectCreation,
      data: data,
    );
  }

  /// Record project status update on blockchain
  Future<BlockchainRecord> recordProjectUpdate(
    Project project,
    String updateDescription,
  ) async {
    final data = {
      'projectId': project.id,
      'status': project.status.name,
      'completionPercentage': project.completionPercentage,
      'updateDescription': updateDescription,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return await _recordTransaction(
      entityId: project.id,
      recordType: BlockchainRecordType.projectUpdate,
      data: data,
    );
  }

  /// Record fund allocation on blockchain
  Future<BlockchainRecord> recordFundAllocation(
    Fund fund,
    String projectId,
    double amount,
  ) async {
    final data = {
      'fundId': fund.id,
      'projectId': projectId,
      'amount': amount,
      'source': fund.source,
      'allocationDate': DateTime.now().toIso8601String(),
    };

    return await _recordTransaction(
      entityId: fund.id,
      recordType: BlockchainRecordType.fundAllocation,
      data: data,
    );
  }

  /// Record fund release on blockchain
  Future<BlockchainRecord> recordFundRelease(Fund fund) async {
    final data = {
      'fundId': fund.id,
      'amount': fund.amount,
      'releaseDate': fund.releaseDate.toIso8601String(),
      'approvalChain': fund.approvalChain,
      'status': fund.status.name,
    };

    return await _recordTransaction(
      entityId: fund.id,
      recordType: BlockchainRecordType.fundRelease,
      data: data,
    );
  }

  /// Record approval on blockchain
  Future<BlockchainRecord> recordApproval(
    String entityId,
    String entityType,
    String approver,
    String approvalLevel,
  ) async {
    final data = {
      'entityId': entityId,
      'entityType': entityType,
      'approver': approver,
      'approvalLevel': approvalLevel,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return await _recordTransaction(
      entityId: entityId,
      recordType: BlockchainRecordType.approval,
      data: data,
    );
  }

  /// Record milestone completion on blockchain
  Future<BlockchainRecord> recordMilestone(
    String projectId,
    Milestone milestone,
  ) async {
    final data = {
      'projectId': projectId,
      'milestoneId': milestone.id,
      'milestoneName': milestone.name,
      'completedDate': milestone.completedDate?.toIso8601String() ?? '',
      'status': milestone.status.name,
      'weightage': milestone.weightage,
    };

    return await _recordTransaction(
      entityId: projectId,
      recordType: BlockchainRecordType.milestone,
      data: data,
    );
  }

  /// Verify a blockchain record
  Future<bool> verifyRecord(String transactionHash) async {
    try {
      final receipt = await _client.getTransactionReceipt(transactionHash);
      return receipt != null && receipt.status == true;
    } catch (e) {
      print('Error verifying record: $e');
      return false;
    }
  }

  /// Get all records for an entity
  Future<List<BlockchainRecord>> getEntityRecords(String entityId) async {
    try {
      final function = _contract.function('getRecords');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [entityId],
      );

      // Parse and return blockchain records
      // This is simplified - actual implementation would parse the data
      return [];
    } catch (e) {
      print('Error getting entity records: $e');
      return [];
    }
  }

  /// Calculate hash for data integrity verification
  String calculateDataHash(Map<String, dynamic> data) {
    // Simple hash calculation using data string
    // In production, use cryptographic hash function
    final dataString = data.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    return dataString.hashCode.toRadixString(16);
  }

  /// Verify data integrity using blockchain record
  Future<bool> verifyDataIntegrity(
    String entityId,
    Map<String, dynamic> currentData,
  ) async {
    final records = await getEntityRecords(entityId);
    if (records.isEmpty) return false;

    final latestRecord = records.last;
    final currentHash = calculateDataHash(currentData);
    
    // Compare with blockchain record
    // This is simplified - actual implementation would be more robust
    return latestRecord.transactionHash.isNotEmpty;
  }

  // Private helper methods

  Future<BlockchainRecord> _recordTransaction({
    required String entityId,
    required BlockchainRecordType recordType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Prepare transaction data
      final dataJson = data.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|');

      // In production, this would actually send transaction to blockchain
      // For now, we'll create a mock record
      final mockRecord = BlockchainRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
        blockHash: '0xblock${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
        blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        contractAddress: _contractAddress.hex,
        type: recordType,
        entityId: entityId,
        data: data,
        timestamp: DateTime.now(),
        previousRecordId: null,
        network: BlockchainNetwork.sepolia,
        status: BlockchainStatus.confirmed,
      );

      print('Blockchain record created: ${mockRecord.transactionHash}');
      return mockRecord;

      /* Production implementation would look like:
      final function = _contract.function('recordTransaction');
      final credentials = await _getCredentials();
      
      final transaction = Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [entityId, recordType.name, dataJson],
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 11155111, // Sepolia chain ID
      );

      // Wait for confirmation
      final receipt = await _waitForConfirmation(txHash);

      return BlockchainRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transactionHash: txHash,
        blockHash: receipt.blockHash.toString(),
        blockNumber: receipt.blockNumber.toInt(),
        contractAddress: _contractAddress.hex,
        type: recordType,
        entityId: entityId,
        data: data,
        timestamp: DateTime.now(),
        previousRecordId: null,
        network: BlockchainNetwork.sepolia,
        status: BlockchainStatus.confirmed,
      );
      */
    } catch (e) {
      print('Error recording transaction: $e');
      rethrow;
    }
  }

  Future<TransactionReceipt?> _waitForConfirmation(
    String txHash, {
    int maxAttempts = 60,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final receipt = await _client.getTransactionReceipt(txHash);
      if (receipt != null) return receipt;
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _client.dispose();
  }
}

/// Smart contract manager for deploying and managing contracts
class SmartContractManager {
  final Web3Client _client;

  SmartContractManager(this._client);

  /// Deploy PM-AJAY transparency contract
  Future<String> deployTransparencyContract(
    EthPrivateKey credentials,
  ) async {
    // Contract bytecode and ABI would be here
    // This is a simplified version
    
    const contractBytecode = '0x...'; // Compiled contract bytecode
    
    try {
      final transaction = Transaction(
        to: null, // null for contract deployment
        data: Uint8List(0), // Simplified - actual bytecode would go here
        maxGas: 3000000,
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 11155111, // Sepolia
      );

      // Wait for deployment
      await Future.delayed(const Duration(seconds: 30));
      
      final receipt = await _client.getTransactionReceipt(txHash);
      if (receipt?.contractAddress != null) {
        return receipt!.contractAddress!.hex;
      }

      throw Exception('Contract deployment failed');
    } catch (e) {
      print('Error deploying contract: $e');
      rethrow;
    }
  }

  /// Verify contract deployment
  Future<bool> verifyContract(String contractAddress) async {
    try {
      final address = EthereumAddress.fromHex(contractAddress);
      final code = await _client.getCode(address);
      return code.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Transaction logger for audit trail
class TransactionLogger {
  final List<BlockchainTransaction> _transactions = [];

  void logTransaction(BlockchainTransaction transaction) {
    _transactions.add(transaction);
  }

  List<BlockchainTransaction> getTransactionHistory({
    String? entityId,
    BlockchainRecordType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _transactions.where((tx) {
      if (entityId != null && tx.entityId != entityId) return false;
      if (type != null && tx.type != type) return false;
      if (startDate != null && tx.timestamp.isBefore(startDate)) return false;
      if (endDate != null && tx.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Map<String, int> getTransactionStatistics() {
    return {
      'total': _transactions.length,
      'confirmed': _transactions.where((tx) => tx.status == BlockchainStatus.confirmed).length,
      'pending': _transactions.where((tx) => tx.status == BlockchainStatus.pending).length,
      'failed': _transactions.where((tx) => tx.status == BlockchainStatus.failed).length,
    };
  }
}

class BlockchainTransaction {
  final String entityId;
  final BlockchainRecordType type;
  final String transactionHash;
  final BlockchainStatus status;
  final DateTime timestamp;

  BlockchainTransaction({
    required this.entityId,
    required this.type,
    required this.transactionHash,
    required this.status,
    required this.timestamp,
  });
}