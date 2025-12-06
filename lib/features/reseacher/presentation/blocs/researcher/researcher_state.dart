
/// # Researcher States
abstract class ResearcherState {}

class ResearcherInitial extends ResearcherState {}

class ResearcherLoading extends ResearcherState {}

class ResearcherSuccess extends ResearcherState {
  final String? message;
  final bool hasCompletedDetails; 
  ResearcherSuccess({this.message, this.hasCompletedDetails = true});
}

class ResearcherError extends ResearcherState {
  final String message;
  ResearcherError(this.message);
}
