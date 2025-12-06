// # Researcher Events
abstract class ResearcherEvent {}

class SubmitResearcherDetailsEvent extends ResearcherEvent {
  // REQUIRED FIELDS (Aligned with backend keys)
  final String affiliatedInstitution; // Renamed from institution
  final String department;             // Renamed from fieldOfStudy
  final String researchPurpose;        // New, required field
  final String researchFocusArea;      // Renamed from researchFocus, and made required
  
  // OPTIONAL FIELDS (New fields)
  final String? academicTitle;         // Optional field
  final String? orcidId;               // Optional field

  // Status Flag
  final bool hasCompletedDetails;

  SubmitResearcherDetailsEvent({
    required this.affiliatedInstitution,
    required this.department,
    required this.researchPurpose,
    required this.researchFocusArea,
    this.academicTitle,
    this.orcidId,
    this.hasCompletedDetails = true,
  });
}