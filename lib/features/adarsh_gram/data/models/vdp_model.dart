/// Village Development Plan (VDP) Models
/// Based on PM-AJAY Guidelines Formats I-VI

class VillageDevelopmentPlan {
  final String id;
  final String villageId;
  final String villageName;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final VDPStatus status;
  final String createdBy;
  
  // Format I: General Information
  final FormatI generalInformation;
  
  // Format II: Demographic Profile
  final FormatII demographicProfile;
  
  // Format III: Infrastructure Assessment
  final FormatIII infrastructureAssessment;
  
  // Format IV: Socio-Economic Status
  final FormatIV socioEconomicStatus;
  
  // Format V: Development Priorities
  final FormatV developmentPriorities;
  
  // Format VI: Action Plan & Budget
  final FormatVI actionPlanBudget;
  
  final List<String> attachments;
  final Map<String, dynamic>? additionalData;

  VillageDevelopmentPlan({
    required this.id,
    required this.villageId,
    required this.villageName,
    required this.createdDate,
    required this.lastUpdated,
    required this.status,
    required this.createdBy,
    required this.generalInformation,
    required this.demographicProfile,
    required this.infrastructureAssessment,
    required this.socioEconomicStatus,
    required this.developmentPriorities,
    required this.actionPlanBudget,
    this.attachments = const [],
    this.additionalData,
  });

  factory VillageDevelopmentPlan.fromJson(Map<String, dynamic> json) {
    return VillageDevelopmentPlan(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      villageName: json['villageName'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      status: VDPStatus.values.byName(json['status'] as String),
      createdBy: json['createdBy'] as String,
      generalInformation: FormatI.fromJson(json['generalInformation'] as Map<String, dynamic>),
      demographicProfile: FormatII.fromJson(json['demographicProfile'] as Map<String, dynamic>),
      infrastructureAssessment: FormatIII.fromJson(json['infrastructureAssessment'] as Map<String, dynamic>),
      socioEconomicStatus: FormatIV.fromJson(json['socioEconomicStatus'] as Map<String, dynamic>),
      developmentPriorities: FormatV.fromJson(json['developmentPriorities'] as Map<String, dynamic>),
      actionPlanBudget: FormatVI.fromJson(json['actionPlanBudget'] as Map<String, dynamic>),
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageId': villageId,
      'villageName': villageName,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status.name,
      'createdBy': createdBy,
      'generalInformation': generalInformation.toJson(),
      'demographicProfile': demographicProfile.toJson(),
      'infrastructureAssessment': infrastructureAssessment.toJson(),
      'socioEconomicStatus': socioEconomicStatus.toJson(),
      'developmentPriorities': developmentPriorities.toJson(),
      'actionPlanBudget': actionPlanBudget.toJson(),
      'attachments': attachments,
      'additionalData': additionalData,
    };
  }
}

enum VDPStatus {
  draft,
  inProgress,
  underReview,
  approved,
  rejected,
  implemented,
}

/// Format I: General Information
class FormatI {
  final String censusCode;
  final String state;
  final String district;
  final String block;
  final String gramPanchayat;
  final String villageName;
  final double latitude;
  final double longitude;
  final String nearestTown;
  final double distanceFromTown;
  final String accessibility; // Road type, connectivity
  final Map<String, String> administrativeContacts;

  FormatI({
    required this.censusCode,
    required this.state,
    required this.district,
    required this.block,
    required this.gramPanchayat,
    required this.villageName,
    required this.latitude,
    required this.longitude,
    required this.nearestTown,
    required this.distanceFromTown,
    required this.accessibility,
    required this.administrativeContacts,
  });

  factory FormatI.fromJson(Map<String, dynamic> json) {
    return FormatI(
      censusCode: json['censusCode'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      block: json['block'] as String,
      gramPanchayat: json['gramPanchayat'] as String,
      villageName: json['villageName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      nearestTown: json['nearestTown'] as String,
      distanceFromTown: (json['distanceFromTown'] as num).toDouble(),
      accessibility: json['accessibility'] as String,
      administrativeContacts: Map<String, String>.from(json['administrativeContacts'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'censusCode': censusCode,
      'state': state,
      'district': district,
      'block': block,
      'gramPanchayat': gramPanchayat,
      'villageName': villageName,
      'latitude': latitude,
      'longitude': longitude,
      'nearestTown': nearestTown,
      'distanceFromTown': distanceFromTown,
      'accessibility': accessibility,
      'administrativeContacts': administrativeContacts,
    };
  }
}

/// Format II: Demographic Profile
class FormatII {
  final int totalPopulation;
  final int scPopulation;
  final double scPercentage;
  final int stPopulation;
  final int totalHouseholds;
  final int scHouseholds;
  final int bplHouseholds;
  final DemographicBreakdown ageDistribution;
  final DemographicBreakdown genderDistribution;
  final double literacyRate;
  final double scLiteracyRate;
  final int schoolGoingChildren;
  final Map<String, int> occupationDistribution;

  FormatII({
    required this.totalPopulation,
    required this.scPopulation,
    required this.scPercentage,
    required this.stPopulation,
    required this.totalHouseholds,
    required this.scHouseholds,
    required this.bplHouseholds,
    required this.ageDistribution,
    required this.genderDistribution,
    required this.literacyRate,
    required this.scLiteracyRate,
    required this.schoolGoingChildren,
    required this.occupationDistribution,
  });

  factory FormatII.fromJson(Map<String, dynamic> json) {
    return FormatII(
      totalPopulation: json['totalPopulation'] as int,
      scPopulation: json['scPopulation'] as int,
      scPercentage: (json['scPercentage'] as num).toDouble(),
      stPopulation: json['stPopulation'] as int,
      totalHouseholds: json['totalHouseholds'] as int,
      scHouseholds: json['scHouseholds'] as int,
      bplHouseholds: json['bplHouseholds'] as int,
      ageDistribution: DemographicBreakdown.fromJson(json['ageDistribution'] as Map<String, dynamic>),
      genderDistribution: DemographicBreakdown.fromJson(json['genderDistribution'] as Map<String, dynamic>),
      literacyRate: (json['literacyRate'] as num).toDouble(),
      scLiteracyRate: (json['scLiteracyRate'] as num).toDouble(),
      schoolGoingChildren: json['schoolGoingChildren'] as int,
      occupationDistribution: Map<String, int>.from(json['occupationDistribution'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPopulation': totalPopulation,
      'scPopulation': scPopulation,
      'scPercentage': scPercentage,
      'stPopulation': stPopulation,
      'totalHouseholds': totalHouseholds,
      'scHouseholds': scHouseholds,
      'bplHouseholds': bplHouseholds,
      'ageDistribution': ageDistribution.toJson(),
      'genderDistribution': genderDistribution.toJson(),
      'literacyRate': literacyRate,
      'scLiteracyRate': scLiteracyRate,
      'schoolGoingChildren': schoolGoingChildren,
      'occupationDistribution': occupationDistribution,
    };
  }
}

class DemographicBreakdown {
  final Map<String, int> data;

  DemographicBreakdown({required this.data});

  factory DemographicBreakdown.fromJson(Map<String, dynamic> json) {
    return DemographicBreakdown(
      data: Map<String, int>.from(json['data'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data};
  }
}

/// Format III: Infrastructure Assessment
class FormatIII {
  final WaterSupply waterSupply;
  final Sanitation sanitation;
  final ElectricityAccess electricity;
  final RoadConnectivity roads;
  final EducationFacilities education;
  final HealthFacilities health;
  final PublicBuildings publicBuildings;
  final CommunityAssets communityAssets;

  FormatIII({
    required this.waterSupply,
    required this.sanitation,
    required this.electricity,
    required this.roads,
    required this.education,
    required this.health,
    required this.publicBuildings,
    required this.communityAssets,
  });

  factory FormatIII.fromJson(Map<String, dynamic> json) {
    return FormatIII(
      waterSupply: WaterSupply.fromJson(json['waterSupply'] as Map<String, dynamic>),
      sanitation: Sanitation.fromJson(json['sanitation'] as Map<String, dynamic>),
      electricity: ElectricityAccess.fromJson(json['electricity'] as Map<String, dynamic>),
      roads: RoadConnectivity.fromJson(json['roads'] as Map<String, dynamic>),
      education: EducationFacilities.fromJson(json['education'] as Map<String, dynamic>),
      health: HealthFacilities.fromJson(json['health'] as Map<String, dynamic>),
      publicBuildings: PublicBuildings.fromJson(json['publicBuildings'] as Map<String, dynamic>),
      communityAssets: CommunityAssets.fromJson(json['communityAssets'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waterSupply': waterSupply.toJson(),
      'sanitation': sanitation.toJson(),
      'electricity': electricity.toJson(),
      'roads': roads.toJson(),
      'education': education.toJson(),
      'health': health.toJson(),
      'publicBuildings': publicBuildings.toJson(),
      'communityAssets': communityAssets.toJson(),
    };
  }
}

class WaterSupply {
  final bool hasPipedWater;
  final int handpumps;
  final int wells;
  final double coveragePercentage;
  final List<String> gaps;

  WaterSupply({
    required this.hasPipedWater,
    required this.handpumps,
    required this.wells,
    required this.coveragePercentage,
    required this.gaps,
  });

  factory WaterSupply.fromJson(Map<String, dynamic> json) {
    return WaterSupply(
      hasPipedWater: json['hasPipedWater'] as bool,
      handpumps: json['handpumps'] as int,
      wells: json['wells'] as int,
      coveragePercentage: (json['coveragePercentage'] as num).toDouble(),
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPipedWater': hasPipedWater,
      'handpumps': handpumps,
      'wells': wells,
      'coveragePercentage': coveragePercentage,
      'gaps': gaps,
    };
  }
}

class Sanitation {
  final int toiletsConstructed;
  final double coveragePercentage;
  final bool hasWasteManagement;
  final List<String> gaps;

  Sanitation({
    required this.toiletsConstructed,
    required this.coveragePercentage,
    required this.hasWasteManagement,
    required this.gaps,
  });

  factory Sanitation.fromJson(Map<String, dynamic> json) {
    return Sanitation(
      toiletsConstructed: json['toiletsConstructed'] as int,
      coveragePercentage: (json['coveragePercentage'] as num).toDouble(),
      hasWasteManagement: json['hasWasteManagement'] as bool,
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toiletsConstructed': toiletsConstructed,
      'coveragePercentage': coveragePercentage,
      'hasWasteManagement': hasWasteManagement,
      'gaps': gaps,
    };
  }
}

class ElectricityAccess {
  final double householdCoverage;
  final bool hasStreetLights;
  final List<String> gaps;

  ElectricityAccess({
    required this.householdCoverage,
    required this.hasStreetLights,
    required this.gaps,
  });

  factory ElectricityAccess.fromJson(Map<String, dynamic> json) {
    return ElectricityAccess(
      householdCoverage: (json['householdCoverage'] as num).toDouble(),
      hasStreetLights: json['hasStreetLights'] as bool,
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'householdCoverage': householdCoverage,
      'hasStreetLights': hasStreetLights,
      'gaps': gaps,
    };
  }
}

class RoadConnectivity {
  final String roadType;
  final bool allWeatherRoad;
  final double internalRoadLength;
  final List<String> gaps;

  RoadConnectivity({
    required this.roadType,
    required this.allWeatherRoad,
    required this.internalRoadLength,
    required this.gaps,
  });

  factory RoadConnectivity.fromJson(Map<String, dynamic> json) {
    return RoadConnectivity(
      roadType: json['roadType'] as String,
      allWeatherRoad: json['allWeatherRoad'] as bool,
      internalRoadLength: (json['internalRoadLength'] as num).toDouble(),
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roadType': roadType,
      'allWeatherRoad': allWeatherRoad,
      'internalRoadLength': internalRoadLength,
      'gaps': gaps,
    };
  }
}

class EducationFacilities {
  final int primarySchools;
  final int secondarySchools;
  final int anganwadis;
  final List<String> gaps;

  EducationFacilities({
    required this.primarySchools,
    required this.secondarySchools,
    required this.anganwadis,
    required this.gaps,
  });

  factory EducationFacilities.fromJson(Map<String, dynamic> json) {
    return EducationFacilities(
      primarySchools: json['primarySchools'] as int,
      secondarySchools: json['secondarySchools'] as int,
      anganwadis: json['anganwadis'] as int,
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primarySchools': primarySchools,
      'secondarySchools': secondarySchools,
      'anganwadis': anganwadis,
      'gaps': gaps,
    };
  }
}

class HealthFacilities {
  final bool hasPHC;
  final bool hasSubCenter;
  final int ashaWorkers;
  final List<String> gaps;

  HealthFacilities({
    required this.hasPHC,
    required this.hasSubCenter,
    required this.ashaWorkers,
    required this.gaps,
  });

  factory HealthFacilities.fromJson(Map<String, dynamic> json) {
    return HealthFacilities(
      hasPHC: json['hasPHC'] as bool,
      hasSubCenter: json['hasSubCenter'] as bool,
      ashaWorkers: json['ashaWorkers'] as int,
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPHC': hasPHC,
      'hasSubCenter': hasSubCenter,
      'ashaWorkers': ashaWorkers,
      'gaps': gaps,
    };
  }
}

class PublicBuildings {
  final bool hasPanchayatBhawan;
  final bool hasCommunityHall;
  final List<String> gaps;

  PublicBuildings({
    required this.hasPanchayatBhawan,
    required this.hasCommunityHall,
    required this.gaps,
  });

  factory PublicBuildings.fromJson(Map<String, dynamic> json) {
    return PublicBuildings(
      hasPanchayatBhawan: json['hasPanchayatBhawan'] as bool,
      hasCommunityHall: json['hasCommunityHall'] as bool,
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPanchayatBhawan': hasPanchayatBhawan,
      'hasCommunityHall': hasCommunityHall,
      'gaps': gaps,
    };
  }
}

class CommunityAssets {
  final Map<String, int> assets;
  final List<String> gaps;

  CommunityAssets({
    required this.assets,
    required this.gaps,
  });

  factory CommunityAssets.fromJson(Map<String, dynamic> json) {
    return CommunityAssets(
      assets: Map<String, int>.from(json['assets'] as Map),
      gaps: List<String>.from(json['gaps'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assets': assets,
      'gaps': gaps,
    };
  }
}

/// Format IV: Socio-Economic Status
class FormatIV {
  final Map<String, int> livelihoodSources;
  final double averageIncome;
  final int landlessHouseholds;
  final double agricultureLandPercentage;
  final List<SocialIssue> majorSocialIssues;
  final Map<String, double> governmentSchemesCoverage;

  FormatIV({
    required this.livelihoodSources,
    required this.averageIncome,
    required this.landlessHouseholds,
    required this.agricultureLandPercentage,
    required this.majorSocialIssues,
    required this.governmentSchemesCoverage,
  });

  factory FormatIV.fromJson(Map<String, dynamic> json) {
    return FormatIV(
      livelihoodSources: Map<String, int>.from(json['livelihoodSources'] as Map),
      averageIncome: (json['averageIncome'] as num).toDouble(),
      landlessHouseholds: json['landlessHouseholds'] as int,
      agricultureLandPercentage: (json['agricultureLandPercentage'] as num).toDouble(),
      majorSocialIssues: (json['majorSocialIssues'] as List)
          .map((e) => SocialIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      governmentSchemesCoverage: Map<String, double>.from(json['governmentSchemesCoverage'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'livelihoodSources': livelihoodSources,
      'averageIncome': averageIncome,
      'landlessHouseholds': landlessHouseholds,
      'agricultureLandPercentage': agricultureLandPercentage,
      'majorSocialIssues': majorSocialIssues.map((e) => e.toJson()).toList(),
      'governmentSchemesCoverage': governmentSchemesCoverage,
    };
  }
}

class SocialIssue {
  final String issue;
  final String severity;
  final String proposedIntervention;

  SocialIssue({
    required this.issue,
    required this.severity,
    required this.proposedIntervention,
  });

  factory SocialIssue.fromJson(Map<String, dynamic> json) {
    return SocialIssue(
      issue: json['issue'] as String,
      severity: json['severity'] as String,
      proposedIntervention: json['proposedIntervention'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue': issue,
      'severity': severity,
      'proposedIntervention': proposedIntervention,
    };
  }
}

/// Format V: Development Priorities
class FormatV {
  final List<DevelopmentPriority> priorities;
  final Map<String, String> communityAspirations;
  final List<String> convergenceOpportunities;

  FormatV({
    required this.priorities,
    required this.communityAspirations,
    required this.convergenceOpportunities,
  });

  factory FormatV.fromJson(Map<String, dynamic> json) {
    return FormatV(
      priorities: (json['priorities'] as List)
          .map((e) => DevelopmentPriority.fromJson(e as Map<String, dynamic>))
          .toList(),
      communityAspirations: Map<String, String>.from(json['communityAspirations'] as Map),
      convergenceOpportunities: List<String>.from(json['convergenceOpportunities'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priorities': priorities.map((e) => e.toJson()).toList(),
      'communityAspirations': communityAspirations,
      'convergenceOpportunities': convergenceOpportunities,
    };
  }
}

class DevelopmentPriority {
  final String sector;
  final String intervention;
  final String rationale;
  final int rank;
  final double estimatedCost;

  DevelopmentPriority({
    required this.sector,
    required this.intervention,
    required this.rationale,
    required this.rank,
    required this.estimatedCost,
  });

  factory DevelopmentPriority.fromJson(Map<String, dynamic> json) {
    return DevelopmentPriority(
      sector: json['sector'] as String,
      intervention: json['intervention'] as String,
      rationale: json['rationale'] as String,
      rank: json['rank'] as int,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sector': sector,
      'intervention': intervention,
      'rationale': rationale,
      'rank': rank,
      'estimatedCost': estimatedCost,
    };
  }
}

/// Format VI: Action Plan & Budget
class FormatVI {
  final List<ActionItem> actionItems;
  final BudgetBreakdown budgetBreakdown;
  final TimelinePhases timeline;
  final List<ResponsibleAgency> agencies;
  final MonitoringPlan monitoringPlan;

  FormatVI({
    required this.actionItems,
    required this.budgetBreakdown,
    required this.timeline,
    required this.agencies,
    required this.monitoringPlan,
  });

  factory FormatVI.fromJson(Map<String, dynamic> json) {
    return FormatVI(
      actionItems: (json['actionItems'] as List)
          .map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetBreakdown: BudgetBreakdown.fromJson(json['budgetBreakdown'] as Map<String, dynamic>),
      timeline: TimelinePhases.fromJson(json['timeline'] as Map<String, dynamic>),
      agencies: (json['agencies'] as List)
          .map((e) => ResponsibleAgency.fromJson(e as Map<String, dynamic>))
          .toList(),
      monitoringPlan: MonitoringPlan.fromJson(json['monitoringPlan'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionItems': actionItems.map((e) => e.toJson()).toList(),
      'budgetBreakdown': budgetBreakdown.toJson(),
      'timeline': timeline.toJson(),
      'agencies': agencies.map((e) => e.toJson()).toList(),
      'monitoringPlan': monitoringPlan.toJson(),
    };
  }
}

class ActionItem {
  final String id;
  final String activity;
  final String sector;
  final double budget;
  final String fundingSource;
  final DateTime startDate;
  final DateTime endDate;
  final String responsibleAgency;
  final List<String> milestones;

  ActionItem({
    required this.id,
    required this.activity,
    required this.sector,
    required this.budget,
    required this.fundingSource,
    required this.startDate,
    required this.endDate,
    required this.responsibleAgency,
    required this.milestones,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'] as String,
      activity: json['activity'] as String,
      sector: json['sector'] as String,
      budget: (json['budget'] as num).toDouble(),
      fundingSource: json['fundingSource'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      responsibleAgency: json['responsibleAgency'] as String,
      milestones: List<String>.from(json['milestones'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity': activity,
      'sector': sector,
      'budget': budget,
      'fundingSource': fundingSource,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'responsibleAgency': responsibleAgency,
      'milestones': milestones,
    };
  }
}

class BudgetBreakdown {
  final double totalBudget;
  final Map<String, double> sectorWiseAllocation;
  final Map<String, double> fundingSourceBreakdown;

  BudgetBreakdown({
    required this.totalBudget,
    required this.sectorWiseAllocation,
    required this.fundingSourceBreakdown,
  });

  factory BudgetBreakdown.fromJson(Map<String, dynamic> json) {
    return BudgetBreakdown(
      totalBudget: (json['totalBudget'] as num).toDouble(),
      sectorWiseAllocation: Map<String, double>.from(json['sectorWiseAllocation'] as Map),
      fundingSourceBreakdown: Map<String, double>.from(json['fundingSourceBreakdown'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBudget': totalBudget,
      'sectorWiseAllocation': sectorWiseAllocation,
      'fundingSourceBreakdown': fundingSourceBreakdown,
    };
  }
}

class TimelinePhases {
  final Map<String, DateRange> phases;

  TimelinePhases({required this.phases});

  factory TimelinePhases.fromJson(Map<String, dynamic> json) {
    final phases = <String, DateRange>{};
    (json['phases'] as Map).forEach((key, value) {
      phases[key as String] = DateRange.fromJson(value as Map<String, dynamic>);
    });
    return TimelinePhases(phases: phases);
  }

  Map<String, dynamic> toJson() {
    return {
      'phases': phases.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }
}

class ResponsibleAgency {
  final String name;
  final String role;
  final String contactPerson;
  final String contactDetails;

  ResponsibleAgency({
    required this.name,
    required this.role,
    required this.contactPerson,
    required this.contactDetails,
  });

  factory ResponsibleAgency.fromJson(Map<String, dynamic> json) {
    return ResponsibleAgency(
      name: json['name'] as String,
      role: json['role'] as String,
      contactPerson: json['contactPerson'] as String,
      contactDetails: json['contactDetails'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'contactPerson': contactPerson,
      'contactDetails': contactDetails,
    };
  }
}

class MonitoringPlan {
  final List<MonitoringIndicator> indicators;
  final String reportingFrequency;
  final List<String> reviewMechanisms;

  MonitoringPlan({
    required this.indicators,
    required this.reportingFrequency,
    required this.reviewMechanisms,
  });

  factory MonitoringPlan.fromJson(Map<String, dynamic> json) {
    return MonitoringPlan(
      indicators: (json['indicators'] as List)
          .map((e) => MonitoringIndicator.fromJson(e as Map<String, dynamic>))
          .toList(),
      reportingFrequency: json['reportingFrequency'] as String,
      reviewMechanisms: List<String>.from(json['reviewMechanisms'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'indicators': indicators.map((e) => e.toJson()).toList(),
      'reportingFrequency': reportingFrequency,
      'reviewMechanisms': reviewMechanisms,
    };
  }
}

class MonitoringIndicator {
  final String indicator;
  final String target;
  final String measurementMethod;

  MonitoringIndicator({
    required this.indicator,
    required this.target,
    required this.measurementMethod,
  });

  factory MonitoringIndicator.fromJson(Map<String, dynamic> json) {
    return MonitoringIndicator(
      indicator: json['indicator'] as String,
      target: json['target'] as String,
      measurementMethod: json['measurementMethod'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'indicator': indicator,
      'target': target,
      'measurementMethod': measurementMethod,
    };
  }
}