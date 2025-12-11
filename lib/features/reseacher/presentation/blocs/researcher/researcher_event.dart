// lib/features/researcher/presentation/blocs/researcher/researcher_event.dart

abstract class ResearcherEvent {}

class SubmitResearcherDetailsEvent extends ResearcherEvent {
  final String affiliatedInstitution; 
  final String department;             
  final String researchPurpose;        
  final String researchFocusArea;      
  final String? academicTitle;         
  final String? orcidId;               
  final bool hasCompletedDetails;
  final String? token; // 🎯 NEW: Token parameter

  SubmitResearcherDetailsEvent({
    required this.affiliatedInstitution,
    required this.department,
    required this.researchPurpose,
    required this.researchFocusArea,
    this.academicTitle,
    this.orcidId,
    this.hasCompletedDetails = true,
    this.token, // 🎯 NEW: Token parameter
  });
}

class CheckApprovalStatusEvent extends ResearcherEvent {
  final String? token; // 🎯 NEW: Token parameter
  
  CheckApprovalStatusEvent({this.token});
}