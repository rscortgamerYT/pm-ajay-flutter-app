/// 50 Indicator Scorecard Model for Adarsh Gram Assessment
/// Based on PM-AJAY Guidelines for village development monitoring

class IndicatorScorecard {
  final String id;
  final String villageId;
  final String villageName;
  final DateTime assessmentDate;
  final String assessedBy;
  final IndicatorScoreStatus overallStatus;
  
  // 10 Categories with 50 indicators total
  final WaterSupplyIndicators waterSupply;
  final SanitationIndicators sanitation;
  final ElectricityIndicators electricity;
  final RoadConnectivityIndicators roads;
  final EducationIndicators education;
  final HealthIndicators health;
  final LivelihoodIndicators livelihood;
  final SocialWelfareIndicators socialWelfare;
  final GovernanceIndicators governance;
  final EnvironmentIndicators environment;
  
  final double overallScore; // 0-100
  final Map<String, double> categoryScores;
  final List<String> achievedIndicators;
  final List<String> pendingIndicators;
  final List<ActionRecommendation> recommendations;

  IndicatorScorecard({
    required this.id,
    required this.villageId,
    required this.villageName,
    required this.assessmentDate,
    required this.assessedBy,
    required this.overallStatus,
    required this.waterSupply,
    required this.sanitation,
    required this.electricity,
    required this.roads,
    required this.education,
    required this.health,
    required this.livelihood,
    required this.socialWelfare,
    required this.governance,
    required this.environment,
    required this.overallScore,
    required this.categoryScores,
    required this.achievedIndicators,
    required this.pendingIndicators,
    required this.recommendations,
  });

  factory IndicatorScorecard.fromJson(Map<String, dynamic> json) {
    return IndicatorScorecard(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      villageName: json['villageName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      assessedBy: json['assessedBy'] as String,
      overallStatus: IndicatorScoreStatus.values.byName(json['overallStatus'] as String),
      waterSupply: WaterSupplyIndicators.fromJson(json['waterSupply'] as Map<String, dynamic>),
      sanitation: SanitationIndicators.fromJson(json['sanitation'] as Map<String, dynamic>),
      electricity: ElectricityIndicators.fromJson(json['electricity'] as Map<String, dynamic>),
      roads: RoadConnectivityIndicators.fromJson(json['roads'] as Map<String, dynamic>),
      education: EducationIndicators.fromJson(json['education'] as Map<String, dynamic>),
      health: HealthIndicators.fromJson(json['health'] as Map<String, dynamic>),
      livelihood: LivelihoodIndicators.fromJson(json['livelihood'] as Map<String, dynamic>),
      socialWelfare: SocialWelfareIndicators.fromJson(json['socialWelfare'] as Map<String, dynamic>),
      governance: GovernanceIndicators.fromJson(json['governance'] as Map<String, dynamic>),
      environment: EnvironmentIndicators.fromJson(json['environment'] as Map<String, dynamic>),
      overallScore: (json['overallScore'] as num).toDouble(),
      categoryScores: Map<String, double>.from(json['categoryScores'] as Map),
      achievedIndicators: List<String>.from(json['achievedIndicators'] as List),
      pendingIndicators: List<String>.from(json['pendingIndicators'] as List),
      recommendations: (json['recommendations'] as List)
          .map((e) => ActionRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageId': villageId,
      'villageName': villageName,
      'assessmentDate': assessmentDate.toIso8601String(),
      'assessedBy': assessedBy,
      'overallStatus': overallStatus.name,
      'waterSupply': waterSupply.toJson(),
      'sanitation': sanitation.toJson(),
      'electricity': electricity.toJson(),
      'roads': roads.toJson(),
      'education': education.toJson(),
      'health': health.toJson(),
      'livelihood': livelihood.toJson(),
      'socialWelfare': socialWelfare.toJson(),
      'governance': governance.toJson(),
      'environment': environment.toJson(),
      'overallScore': overallScore,
      'categoryScores': categoryScores,
      'achievedIndicators': achievedIndicators,
      'pendingIndicators': pendingIndicators,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
    };
  }
}

enum IndicatorScoreStatus {
  excellent,      // 90-100
  good,          // 75-89
  satisfactory,  // 60-74
  needsImprovement, // 40-59
  critical,      // 0-39
}

class Indicator {
  final String id;
  final String name;
  final String description;
  final bool isAchieved;
  final double? currentValue;
  final double? targetValue;
  final String? unit;
  final DateTime? lastUpdated;
  final String? evidence;

  Indicator({
    required this.id,
    required this.name,
    required this.description,
    required this.isAchieved,
    this.currentValue,
    this.targetValue,
    this.unit,
    this.lastUpdated,
    this.evidence,
  });

  factory Indicator.fromJson(Map<String, dynamic> json) {
    return Indicator(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isAchieved: json['isAchieved'] as bool,
      currentValue: json['currentValue'] as double?,
      targetValue: json['targetValue'] as double?,
      unit: json['unit'] as String?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      evidence: json['evidence'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isAchieved': isAchieved,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'evidence': evidence,
    };
  }
}

/// Water Supply Indicators (5 indicators)
class WaterSupplyIndicators {
  final Indicator pipedWaterConnection;
  final Indicator waterQuality;
  final Indicator perCapitaWaterAvailability;
  final Indicator handpumpFunctionality;
  final Indicator waterStorageCapacity;

  WaterSupplyIndicators({
    required this.pipedWaterConnection,
    required this.waterQuality,
    required this.perCapitaWaterAvailability,
    required this.handpumpFunctionality,
    required this.waterStorageCapacity,
  });

  factory WaterSupplyIndicators.fromJson(Map<String, dynamic> json) {
    return WaterSupplyIndicators(
      pipedWaterConnection: Indicator.fromJson(json['pipedWaterConnection'] as Map<String, dynamic>),
      waterQuality: Indicator.fromJson(json['waterQuality'] as Map<String, dynamic>),
      perCapitaWaterAvailability: Indicator.fromJson(json['perCapitaWaterAvailability'] as Map<String, dynamic>),
      handpumpFunctionality: Indicator.fromJson(json['handpumpFunctionality'] as Map<String, dynamic>),
      waterStorageCapacity: Indicator.fromJson(json['waterStorageCapacity'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pipedWaterConnection': pipedWaterConnection.toJson(),
      'waterQuality': waterQuality.toJson(),
      'perCapitaWaterAvailability': perCapitaWaterAvailability.toJson(),
      'handpumpFunctionality': handpumpFunctionality.toJson(),
      'waterStorageCapacity': waterStorageCapacity.toJson(),
    };
  }
}

/// Sanitation Indicators (5 indicators)
class SanitationIndicators {
  final Indicator householdToilets;
  final Indicator solidWasteManagement;
  final Indicator liquidWasteManagement;
  final Indicator openDefecationFree;
  final Indicator communityToilets;

  SanitationIndicators({
    required this.householdToilets,
    required this.solidWasteManagement,
    required this.liquidWasteManagement,
    required this.openDefecationFree,
    required this.communityToilets,
  });

  factory SanitationIndicators.fromJson(Map<String, dynamic> json) {
    return SanitationIndicators(
      householdToilets: Indicator.fromJson(json['householdToilets'] as Map<String, dynamic>),
      solidWasteManagement: Indicator.fromJson(json['solidWasteManagement'] as Map<String, dynamic>),
      liquidWasteManagement: Indicator.fromJson(json['liquidWasteManagement'] as Map<String, dynamic>),
      openDefecationFree: Indicator.fromJson(json['openDefecationFree'] as Map<String, dynamic>),
      communityToilets: Indicator.fromJson(json['communityToilets'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'householdToilets': householdToilets.toJson(),
      'solidWasteManagement': solidWasteManagement.toJson(),
      'liquidWasteManagement': liquidWasteManagement.toJson(),
      'openDefecationFree': openDefecationFree.toJson(),
      'communityToilets': communityToilets.toJson(),
    };
  }
}

/// Electricity Indicators (5 indicators)
class ElectricityIndicators {
  final Indicator householdElectrification;
  final Indicator streetLighting;
  final Indicator reliablePowerSupply;
  final Indicator solarPowerUsage;
  final Indicator electricityForAgriculture;

  ElectricityIndicators({
    required this.householdElectrification,
    required this.streetLighting,
    required this.reliablePowerSupply,
    required this.solarPowerUsage,
    required this.electricityForAgriculture,
  });

  factory ElectricityIndicators.fromJson(Map<String, dynamic> json) {
    return ElectricityIndicators(
      householdElectrification: Indicator.fromJson(json['householdElectrification'] as Map<String, dynamic>),
      streetLighting: Indicator.fromJson(json['streetLighting'] as Map<String, dynamic>),
      reliablePowerSupply: Indicator.fromJson(json['reliablePowerSupply'] as Map<String, dynamic>),
      solarPowerUsage: Indicator.fromJson(json['solarPowerUsage'] as Map<String, dynamic>),
      electricityForAgriculture: Indicator.fromJson(json['electricityForAgriculture'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'householdElectrification': householdElectrification.toJson(),
      'streetLighting': streetLighting.toJson(),
      'reliablePowerSupply': reliablePowerSupply.toJson(),
      'solarPowerUsage': solarPowerUsage.toJson(),
      'electricityForAgriculture': electricityForAgriculture.toJson(),
    };
  }
}

/// Road Connectivity Indicators (5 indicators)
class RoadConnectivityIndicators {
  final Indicator allWeatherRoad;
  final Indicator internalRoadNetwork;
  final Indicator publicTransportAccess;
  final Indicator roadMaintenance;
  final Indicator lastMileConnectivity;

  RoadConnectivityIndicators({
    required this.allWeatherRoad,
    required this.internalRoadNetwork,
    required this.publicTransportAccess,
    required this.roadMaintenance,
    required this.lastMileConnectivity,
  });

  factory RoadConnectivityIndicators.fromJson(Map<String, dynamic> json) {
    return RoadConnectivityIndicators(
      allWeatherRoad: Indicator.fromJson(json['allWeatherRoad'] as Map<String, dynamic>),
      internalRoadNetwork: Indicator.fromJson(json['internalRoadNetwork'] as Map<String, dynamic>),
      publicTransportAccess: Indicator.fromJson(json['publicTransportAccess'] as Map<String, dynamic>),
      roadMaintenance: Indicator.fromJson(json['roadMaintenance'] as Map<String, dynamic>),
      lastMileConnectivity: Indicator.fromJson(json['lastMileConnectivity'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allWeatherRoad': allWeatherRoad.toJson(),
      'internalRoadNetwork': internalRoadNetwork.toJson(),
      'publicTransportAccess': publicTransportAccess.toJson(),
      'roadMaintenance': roadMaintenance.toJson(),
      'lastMileConnectivity': lastMileConnectivity.toJson(),
    };
  }
}

/// Education Indicators (5 indicators)
class EducationIndicators {
  final Indicator primarySchoolAccess;
  final Indicator secondarySchoolAccess;
  final Indicator anganwadiCoverage;
  final Indicator teacherStudentRatio;
  final Indicator educationalInfrastructure;

  EducationIndicators({
    required this.primarySchoolAccess,
    required this.secondarySchoolAccess,
    required this.anganwadiCoverage,
    required this.teacherStudentRatio,
    required this.educationalInfrastructure,
  });

  factory EducationIndicators.fromJson(Map<String, dynamic> json) {
    return EducationIndicators(
      primarySchoolAccess: Indicator.fromJson(json['primarySchoolAccess'] as Map<String, dynamic>),
      secondarySchoolAccess: Indicator.fromJson(json['secondarySchoolAccess'] as Map<String, dynamic>),
      anganwadiCoverage: Indicator.fromJson(json['anganwadiCoverage'] as Map<String, dynamic>),
      teacherStudentRatio: Indicator.fromJson(json['teacherStudentRatio'] as Map<String, dynamic>),
      educationalInfrastructure: Indicator.fromJson(json['educationalInfrastructure'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primarySchoolAccess': primarySchoolAccess.toJson(),
      'secondarySchoolAccess': secondarySchoolAccess.toJson(),
      'anganwadiCoverage': anganwadiCoverage.toJson(),
      'teacherStudentRatio': teacherStudentRatio.toJson(),
      'educationalInfrastructure': educationalInfrastructure.toJson(),
    };
  }
}

/// Health Indicators (5 indicators)
class HealthIndicators {
  final Indicator primaryHealthCenter;
  final Indicator subHealthCenter;
  final Indicator ashaWorkerCoverage;
  final Indicator immunizationCoverage;
  final Indicator maternalHealthServices;

  HealthIndicators({
    required this.primaryHealthCenter,
    required this.subHealthCenter,
    required this.ashaWorkerCoverage,
    required this.immunizationCoverage,
    required this.maternalHealthServices,
  });

  factory HealthIndicators.fromJson(Map<String, dynamic> json) {
    return HealthIndicators(
      primaryHealthCenter: Indicator.fromJson(json['primaryHealthCenter'] as Map<String, dynamic>),
      subHealthCenter: Indicator.fromJson(json['subHealthCenter'] as Map<String, dynamic>),
      ashaWorkerCoverage: Indicator.fromJson(json['ashaWorkerCoverage'] as Map<String, dynamic>),
      immunizationCoverage: Indicator.fromJson(json['immunizationCoverage'] as Map<String, dynamic>),
      maternalHealthServices: Indicator.fromJson(json['maternalHealthServices'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryHealthCenter': primaryHealthCenter.toJson(),
      'subHealthCenter': subHealthCenter.toJson(),
      'ashaWorkerCoverage': ashaWorkerCoverage.toJson(),
      'immunizationCoverage': immunizationCoverage.toJson(),
      'maternalHealthServices': maternalHealthServices.toJson(),
    };
  }
}

/// Livelihood Indicators (5 indicators)
class LivelihoodIndicators {
  final Indicator employmentOpportunities;
  final Indicator skillDevelopmentAccess;
  final Indicator agriculturalSupport;
  final Indicator financialInclusion;
  final Indicator entrepreneurshipSupport;

  LivelihoodIndicators({
    required this.employmentOpportunities,
    required this.skillDevelopmentAccess,
    required this.agriculturalSupport,
    required this.financialInclusion,
    required this.entrepreneurshipSupport,
  });

  factory LivelihoodIndicators.fromJson(Map<String, dynamic> json) {
    return LivelihoodIndicators(
      employmentOpportunities: Indicator.fromJson(json['employmentOpportunities'] as Map<String, dynamic>),
      skillDevelopmentAccess: Indicator.fromJson(json['skillDevelopmentAccess'] as Map<String, dynamic>),
      agriculturalSupport: Indicator.fromJson(json['agriculturalSupport'] as Map<String, dynamic>),
      financialInclusion: Indicator.fromJson(json['financialInclusion'] as Map<String, dynamic>),
      entrepreneurshipSupport: Indicator.fromJson(json['entrepreneurshipSupport'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employmentOpportunities': employmentOpportunities.toJson(),
      'skillDevelopmentAccess': skillDevelopmentAccess.toJson(),
      'agriculturalSupport': agriculturalSupport.toJson(),
      'financialInclusion': financialInclusion.toJson(),
      'entrepreneurshipSupport': entrepreneurshipSupport.toJson(),
    };
  }
}

/// Social Welfare Indicators (5 indicators)
class SocialWelfareIndicators {
  final Indicator pensionCoverage;
  final Indicator scholarshipAccess;
  final Indicator socialSecuritySchemes;
  final Indicator disabilitySupport;
  final Indicator womenEmpowermentPrograms;

  SocialWelfareIndicators({
    required this.pensionCoverage,
    required this.scholarshipAccess,
    required this.socialSecuritySchemes,
    required this.disabilitySupport,
    required this.womenEmpowermentPrograms,
  });

  factory SocialWelfareIndicators.fromJson(Map<String, dynamic> json) {
    return SocialWelfareIndicators(
      pensionCoverage: Indicator.fromJson(json['pensionCoverage'] as Map<String, dynamic>),
      scholarshipAccess: Indicator.fromJson(json['scholarshipAccess'] as Map<String, dynamic>),
      socialSecuritySchemes: Indicator.fromJson(json['socialSecuritySchemes'] as Map<String, dynamic>),
      disabilitySupport: Indicator.fromJson(json['disabilitySupport'] as Map<String, dynamic>),
      womenEmpowermentPrograms: Indicator.fromJson(json['womenEmpowermentPrograms'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pensionCoverage': pensionCoverage.toJson(),
      'scholarshipAccess': scholarshipAccess.toJson(),
      'socialSecuritySchemes': socialSecuritySchemes.toJson(),
      'disabilitySupport': disabilitySupport.toJson(),
      'womenEmpowermentPrograms': womenEmpowermentPrograms.toJson(),
    };
  }
}

/// Governance Indicators (5 indicators)
class GovernanceIndicators {
  final Indicator gramPanchayatFunctionality;
  final Indicator participatoryDecisionMaking;
  final Indicator transparencyMechanisms;
  final Indicator grievanceRedressal;
  final Indicator communityMobilization;

  GovernanceIndicators({
    required this.gramPanchayatFunctionality,
    required this.participatoryDecisionMaking,
    required this.transparencyMechanisms,
    required this.grievanceRedressal,
    required this.communityMobilization,
  });

  factory GovernanceIndicators.fromJson(Map<String, dynamic> json) {
    return GovernanceIndicators(
      gramPanchayatFunctionality: Indicator.fromJson(json['gramPanchayatFunctionality'] as Map<String, dynamic>),
      participatoryDecisionMaking: Indicator.fromJson(json['participatoryDecisionMaking'] as Map<String, dynamic>),
      transparencyMechanisms: Indicator.fromJson(json['transparencyMechanisms'] as Map<String, dynamic>),
      grievanceRedressal: Indicator.fromJson(json['grievanceRedressal'] as Map<String, dynamic>),
      communityMobilization: Indicator.fromJson(json['communityMobilization'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gramPanchayatFunctionality': gramPanchayatFunctionality.toJson(),
      'participatoryDecisionMaking': participatoryDecisionMaking.toJson(),
      'transparencyMechanisms': transparencyMechanisms.toJson(),
      'grievanceRedressal': grievanceRedressal.toJson(),
      'communityMobilization': communityMobilization.toJson(),
    };
  }
}

/// Environment Indicators (5 indicators)
class EnvironmentIndicators {
  final Indicator treePlantation;
  final Indicator waterConservation;
  final Indicator soilConservation;
  final Indicator cleanlinessAndHygiene;
  final Indicator renewableEnergyUsage;

  EnvironmentIndicators({
    required this.treePlantation,
    required this.waterConservation,
    required this.soilConservation,
    required this.cleanlinessAndHygiene,
    required this.renewableEnergyUsage,
  });

  factory EnvironmentIndicators.fromJson(Map<String, dynamic> json) {
    return EnvironmentIndicators(
      treePlantation: Indicator.fromJson(json['treePlantation'] as Map<String, dynamic>),
      waterConservation: Indicator.fromJson(json['waterConservation'] as Map<String, dynamic>),
      soilConservation: Indicator.fromJson(json['soilConservation'] as Map<String, dynamic>),
      cleanlinessAndHygiene: Indicator.fromJson(json['cleanlinessAndHygiene'] as Map<String, dynamic>),
      renewableEnergyUsage: Indicator.fromJson(json['renewableEnergyUsage'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treePlantation': treePlantation.toJson(),
      'waterConservation': waterConservation.toJson(),
      'soilConservation': soilConservation.toJson(),
      'cleanlinessAndHygiene': cleanlinessAndHygiene.toJson(),
      'renewableEnergyUsage': renewableEnergyUsage.toJson(),
    };
  }
}

class ActionRecommendation {
  final String category;
  final String action;
  final String priority; // High, Medium, Low
  final String estimatedTimeline;
  final double estimatedBudget;
  final List<String> convergenceSchemes;

  ActionRecommendation({
    required this.category,
    required this.action,
    required this.priority,
    required this.estimatedTimeline,
    required this.estimatedBudget,
    required this.convergenceSchemes,
  });

  factory ActionRecommendation.fromJson(Map<String, dynamic> json) {
    return ActionRecommendation(
      category: json['category'] as String,
      action: json['action'] as String,
      priority: json['priority'] as String,
      estimatedTimeline: json['estimatedTimeline'] as String,
      estimatedBudget: (json['estimatedBudget'] as num).toDouble(),
      convergenceSchemes: List<String>.from(json['convergenceSchemes'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'action': action,
      'priority': priority,
      'estimatedTimeline': estimatedTimeline,
      'estimatedBudget': estimatedBudget,
      'convergenceSchemes': convergenceSchemes,
    };
  }
}