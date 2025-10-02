class VillageModel {
  final String id;
  final String name;
  final String district;
  final String state;
  final String pincode;
  final double scPopulationPercentage;
  final int totalPopulation;
  final int scPopulation;
  final int totalHouseholds;
  final int scHouseholds;
  final int bplHouseholds;
  final double literacyRate;
  final VillageEligibilityStatus eligibilityStatus;
  final DateTime lastUpdated;
  final String? censusCode;
  final String? seccCode;
  final Map<String, double>? socioEconomicIndicators;
  final Map<String, bool>? infrastructureGaps;
  final List<String>? convergentSchemes;
  final double? priorityScore;
  final DateTime? selectedDate;
  final String? selectedBy;

  VillageModel({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    required this.pincode,
    required this.scPopulationPercentage,
    required this.totalPopulation,
    required this.scPopulation,
    required this.totalHouseholds,
    required this.scHouseholds,
    required this.bplHouseholds,
    required this.literacyRate,
    required this.eligibilityStatus,
    required this.lastUpdated,
    this.censusCode,
    this.seccCode,
    this.socioEconomicIndicators,
    this.infrastructureGaps,
    this.convergentSchemes,
    this.priorityScore,
    this.selectedDate,
    this.selectedBy,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      scPopulationPercentage: (json['scPopulationPercentage'] as num).toDouble(),
      totalPopulation: json['totalPopulation'] as int,
      scPopulation: json['scPopulation'] as int,
      totalHouseholds: json['totalHouseholds'] as int,
      scHouseholds: json['scHouseholds'] as int,
      bplHouseholds: json['bplHouseholds'] as int,
      literacyRate: (json['literacyRate'] as num).toDouble(),
      eligibilityStatus: VillageEligibilityStatus.values.byName(
        json['eligibilityStatus'] as String,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      censusCode: json['censusCode'] as String?,
      seccCode: json['seccCode'] as String?,
      socioEconomicIndicators: json['socioEconomicIndicators'] != null
          ? Map<String, double>.from(json['socioEconomicIndicators'] as Map)
          : null,
      infrastructureGaps: json['infrastructureGaps'] != null
          ? Map<String, bool>.from(json['infrastructureGaps'] as Map)
          : null,
      convergentSchemes: json['convergentSchemes'] != null
          ? List<String>.from(json['convergentSchemes'] as List)
          : null,
      priorityScore: json['priorityScore'] as double?,
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'] as String)
          : null,
      selectedBy: json['selectedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'state': state,
      'pincode': pincode,
      'scPopulationPercentage': scPopulationPercentage,
      'totalPopulation': totalPopulation,
      'scPopulation': scPopulation,
      'totalHouseholds': totalHouseholds,
      'scHouseholds': scHouseholds,
      'bplHouseholds': bplHouseholds,
      'literacyRate': literacyRate,
      'eligibilityStatus': eligibilityStatus.name,
      'lastUpdated': lastUpdated.toIso8601String(),
      'censusCode': censusCode,
      'seccCode': seccCode,
      'socioEconomicIndicators': socioEconomicIndicators,
      'infrastructureGaps': infrastructureGaps,
      'convergentSchemes': convergentSchemes,
      'priorityScore': priorityScore,
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedBy': selectedBy,
    };
  }

  VillageModel copyWith({
    String? id,
    String? name,
    String? district,
    String? state,
    String? pincode,
    double? scPopulationPercentage,
    int? totalPopulation,
    int? scPopulation,
    int? totalHouseholds,
    int? scHouseholds,
    int? bplHouseholds,
    double? literacyRate,
    VillageEligibilityStatus? eligibilityStatus,
    DateTime? lastUpdated,
    String? censusCode,
    String? seccCode,
    Map<String, double>? socioEconomicIndicators,
    Map<String, bool>? infrastructureGaps,
    List<String>? convergentSchemes,
    double? priorityScore,
    DateTime? selectedDate,
    String? selectedBy,
  }) {
    return VillageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      scPopulationPercentage: scPopulationPercentage ?? this.scPopulationPercentage,
      totalPopulation: totalPopulation ?? this.totalPopulation,
      scPopulation: scPopulation ?? this.scPopulation,
      totalHouseholds: totalHouseholds ?? this.totalHouseholds,
      scHouseholds: scHouseholds ?? this.scHouseholds,
      bplHouseholds: bplHouseholds ?? this.bplHouseholds,
      literacyRate: literacyRate ?? this.literacyRate,
      eligibilityStatus: eligibilityStatus ?? this.eligibilityStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      censusCode: censusCode ?? this.censusCode,
      seccCode: seccCode ?? this.seccCode,
      socioEconomicIndicators: socioEconomicIndicators ?? this.socioEconomicIndicators,
      infrastructureGaps: infrastructureGaps ?? this.infrastructureGaps,
      convergentSchemes: convergentSchemes ?? this.convergentSchemes,
      priorityScore: priorityScore ?? this.priorityScore,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedBy: selectedBy ?? this.selectedBy,
    );
  }
}

enum VillageEligibilityStatus {
  eligible, // >= 50% SC population
  ineligible, // < 50% SC population
  pending, // Data not yet verified
  selected, // Already selected for Adarsh Gram
  completed, // Adarsh Gram work completed
}

class VillagePrioritizationCriteria {
  final double scPopulationWeight;
  final double bplHouseholdsWeight;
  final double literacyRateWeight;
  final double infrastructureGapWeight;
  final double convergenceOpportunityWeight;

  VillagePrioritizationCriteria({
    this.scPopulationWeight = 0.30,
    this.bplHouseholdsWeight = 0.20,
    this.literacyRateWeight = 0.15,
    this.infrastructureGapWeight = 0.20,
    this.convergenceOpportunityWeight = 0.15,
  });

  factory VillagePrioritizationCriteria.fromJson(Map<String, dynamic> json) {
    return VillagePrioritizationCriteria(
      scPopulationWeight: (json['scPopulationWeight'] as num?)?.toDouble() ?? 0.30,
      bplHouseholdsWeight: (json['bplHouseholdsWeight'] as num?)?.toDouble() ?? 0.20,
      literacyRateWeight: (json['literacyRateWeight'] as num?)?.toDouble() ?? 0.15,
      infrastructureGapWeight: (json['infrastructureGapWeight'] as num?)?.toDouble() ?? 0.20,
      convergenceOpportunityWeight: (json['convergenceOpportunityWeight'] as num?)?.toDouble() ?? 0.15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scPopulationWeight': scPopulationWeight,
      'bplHouseholdsWeight': bplHouseholdsWeight,
      'literacyRateWeight': literacyRateWeight,
      'infrastructureGapWeight': infrastructureGapWeight,
      'convergenceOpportunityWeight': convergenceOpportunityWeight,
    };
  }
}

class InfrastructureGap {
  final String category;
  final String item;
  final bool hasGap;
  final String? description;
  final double? estimatedCost;

  InfrastructureGap({
    required this.category,
    required this.item,
    required this.hasGap,
    this.description,
    this.estimatedCost,
  });

  factory InfrastructureGap.fromJson(Map<String, dynamic> json) {
    return InfrastructureGap(
      category: json['category'] as String,
      item: json['item'] as String,
      hasGap: json['hasGap'] as bool,
      description: json['description'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'item': item,
      'hasGap': hasGap,
      'description': description,
      'estimatedCost': estimatedCost,
    };
  }
}

class ConvergenceScheme {
  final String schemeId;
  final String schemeName;
  final String schemeType; // Central/State
  final double allocatedFunds;
  final String purpose;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  ConvergenceScheme({
    required this.schemeId,
    required this.schemeName,
    required this.schemeType,
    required this.allocatedFunds,
    required this.purpose,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory ConvergenceScheme.fromJson(Map<String, dynamic> json) {
    return ConvergenceScheme(
      schemeId: json['schemeId'] as String,
      schemeName: json['schemeName'] as String,
      schemeType: json['schemeType'] as String,
      allocatedFunds: (json['allocatedFunds'] as num).toDouble(),
      purpose: json['purpose'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemeId': schemeId,
      'schemeName': schemeName,
      'schemeType': schemeType,
      'allocatedFunds': allocatedFunds,
      'purpose': purpose,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
    };
  }
}