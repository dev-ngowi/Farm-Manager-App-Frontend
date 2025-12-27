import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';

class PregnancyCheckModel extends PregnancyCheckEntity {
  const PregnancyCheckModel({
    required super.id,
    required super.inseminationId,
    required super.checkDate,
    required super.method,
    required super.result,
    super.fetusCount,
    super.expectedDeliveryDate,
    super.vetId,
    super.vetName,
    required super.notes,
    required super.damName,
    required super.damTagNumber,
  });

  factory PregnancyCheckModel.fromJson(Map<String, dynamic> json) {
    // Extract dam information from nested insemination object
    String damName = '';
    String damTagNumber = '';
    
    if (json['insemination'] != null) {
      final insemination = json['insemination'] as Map<String, dynamic>;
      if (insemination['dam'] != null) {
        final dam = insemination['dam'] as Map<String, dynamic>;
        damName = dam['name'] ?? '';
        damTagNumber = dam['tag_number'] ?? '';
      }
    }

    // Extract vet name from nested vet object
    String? vetName;
    if (json['vet'] != null) {
      final vet = json['vet'] as Map<String, dynamic>;
      vetName = vet['name'] ?? vet['full_name'];
    }

    return PregnancyCheckModel(
      id: json['check_id'] ?? json['id'] ?? 0,  // Handle both check_id and id
      inseminationId: json['insemination_id'] ?? 0,
      checkDate: json['check_date'] != null 
          ? DateTime.parse(json['check_date']) 
          : DateTime.now(),
      method: json['method'] ?? '',
      result: json['result'] ?? '',
      fetusCount: json['fetus_count'],
      expectedDeliveryDate: json['expected_delivery_date'] != null 
          ? DateTime.parse(json['expected_delivery_date']) 
          : null,
      vetId: json['vet_id'],
      vetName: vetName,
      notes: json['notes'] ?? '',
      damName: damName,
      damTagNumber: damTagNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insemination_id': inseminationId,
      'check_date': checkDate.toIso8601String(),
      'method': method,
      'result': result,
      'fetus_count': fetusCount,
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'vet_id': vetId,
      'notes': notes,
    };
  }
}

class PregnancyCheckVetModel extends PregnancyCheckVetEntity {
  const PregnancyCheckVetModel({
    required super.id,
    required super.name,
  });

  factory PregnancyCheckVetModel.fromJson(Map<String, dynamic> json) {
    return PregnancyCheckVetModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['full_name'] ?? 'Unknown Vet',
    );
  }
}

class PregnancyCheckInseminationModel extends PregnancyCheckInseminationEntity {
  const PregnancyCheckInseminationModel({
    required super.id,
    required super.damName,
    required super.damTagNumber,
  });

  factory PregnancyCheckInseminationModel.fromJson(Map<String, dynamic> json) {
    return PregnancyCheckInseminationModel(
      id: json['id'] ?? 0,
      damName: json['dam_name'] ?? 'Unknown', 
      damTagNumber: json['dam_tag_number'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dam_name': damName,
      'dam_tag_number': damTagNumber,
    };
  }
}