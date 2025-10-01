import 'package:equatable/equatable.dart';

/// Represents a government agency in the PM-AJAY system
/// Can be either an implementing agency or executing agency
class Agency extends Equatable {
  final String id;
  final String name;
  final AgencyType type;
  final String? description;
  final List<String> responsibilities;
  final List<String> connectedAgencyIds;
  final double coordinationScore;
  final AgencyStatus status;
  final ContactInfo contactInfo;
  final Map<String, dynamic> aiInsights;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Agency({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.responsibilities,
    required this.connectedAgencyIds,
    required this.coordinationScore,
    required this.status,
    required this.contactInfo,
    required this.aiInsights,
    required this.createdAt,
    required this.updatedAt,
  });

  Agency copyWith({
    String? id,
    String? name,
    AgencyType? type,
    String? description,
    List<String>? responsibilities,
    List<String>? connectedAgencyIds,
    double? coordinationScore,
    AgencyStatus? status,
    ContactInfo? contactInfo,
    Map<String, dynamic>? aiInsights,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Agency(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      connectedAgencyIds: connectedAgencyIds ?? this.connectedAgencyIds,
      coordinationScore: coordinationScore ?? this.coordinationScore,
      status: status ?? this.status,
      contactInfo: contactInfo ?? this.contactInfo,
      aiInsights: aiInsights ?? this.aiInsights,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        responsibilities,
        connectedAgencyIds,
        coordinationScore,
        status,
        contactInfo,
        aiInsights,
        createdAt,
        updatedAt,
      ];
}

enum AgencyType {
  implementing,
  executing,
  both,
}

enum AgencyStatus {
  active,
  inactive,
  suspended,
}

class ContactInfo extends Equatable {
  final String email;
  final String phone;
  final String? whatsapp;
  final String? address;
  final String? contactPerson;

  const ContactInfo({
    required this.email,
    required this.phone,
    this.whatsapp,
    this.address,
    this.contactPerson,
  });

  ContactInfo copyWith({
    String? email,
    String? phone,
    String? whatsapp,
    String? address,
    String? contactPerson,
  }) {
    return ContactInfo(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }

  @override
  List<Object?> get props => [email, phone, whatsapp, address, contactPerson];
}