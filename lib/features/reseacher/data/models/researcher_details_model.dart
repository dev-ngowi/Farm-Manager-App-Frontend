import 'package:farm_manager_app/features/reseacher/domain/entities/researcher_details_entity.dart';

// Data model for submitting researcher details (PUT request)
class ResearcherDetailsModel extends ResearcherDetailsEntity {
  const ResearcherDetailsModel({
    required String affiliatedInstitution,
    required String department,
    required String researchPurpose,
    required String researchFocusArea,
    String? academicTitle,
    String? orcidId,
  }) : super(
          affiliatedInstitution: affiliatedInstitution,
          department: department,
          researchPurpose: researchPurpose,
          researchFocusArea: researchFocusArea,
          academicTitle: academicTitle,
          orcidId: orcidId,
        );

  factory ResearcherDetailsModel.fromEntity(ResearcherDetailsEntity entity) {
    return ResearcherDetailsModel(
      affiliatedInstitution: entity.affiliatedInstitution,
      department: entity.department,
      researchPurpose: entity.researchPurpose,
      researchFocusArea: entity.researchFocusArea,
      academicTitle: entity.academicTitle,
      orcidId: entity.orcidId,
    );
  }

  /// Converts the model to a JSON map suitable for the API body (PUT request)
  Map<String, dynamic> toJson() {
    return {
      'affiliated_institution': affiliatedInstitution,
      'department': department,
      'research_purpose': researchPurpose,
      'research_focus_area': researchFocusArea,
      'academic_title': academicTitle, // Nullable field
      'orcid_id': orcidId,             // Nullable field
    };
  }
}