// Placeholder for the Researcher Details Entity
// This entity will be used to transfer data across layers
class ResearcherDetailsEntity {
  final String affiliatedInstitution;
  final String department;
  final String researchPurpose;
  final String researchFocusArea;
  final String? academicTitle;
  final String? orcidId;

  const ResearcherDetailsEntity({
    required this.affiliatedInstitution,
    required this.department,
    required this.researchPurpose,
    required this.researchFocusArea,
    this.academicTitle,
    this.orcidId,
  });
}