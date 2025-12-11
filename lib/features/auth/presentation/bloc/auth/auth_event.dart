// lib/features/auth/presentation/bloc/auth/auth_event.dart

part of 'auth_bloc.dart';


/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ========================================
// REGISTER EVENT
// ========================================

/// Event triggered when user submits registration form
class RegisterSubmitted extends AuthEvent {
  final String firstname;
  final String lastname;
  final String phoneNumber;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;

  const RegisterSubmitted({
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  @override
  List<Object?> get props => [
        firstname,
        lastname,
        phoneNumber,
        email,
        password,
        passwordConfirmation,
        role,
      ];
}

// ========================================
// LOGIN EVENT
// ========================================

/// Event triggered when user submits login form
/// Login can be email, phone number, or username
class LoginSubmitted extends AuthEvent {
  final String login;
  final String password;

  const LoginSubmitted({
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [login, password];
}

// ========================================
// FETCH USER LOCATIONS EVENT
// ========================================

/// Event triggered to fetch user's locations from API
class FetchUserLocations extends AuthEvent {
  final String token;

  const FetchUserLocations({required this.token});

  @override
  List<Object?> get props => [token];
}

// ========================================
// ASSIGN ROLE EVENT
// ========================================

/// Event triggered when assigning a role to user
class AssignRoleSubmitted extends AuthEvent {
  final String role;
  final String token;

  const AssignRoleSubmitted({
    required this.role,
    required this.token,
  });

  @override
  List<Object?> get props => [role, token];
}

// ========================================
// SUBMIT FARMER DETAILS EVENT
// ========================================

/// Event triggered when farmer submits their farm details
class SubmitFarmerDetails extends AuthEvent {
  final String farmName;
  final String farmPurpose;
  final double totalLandAcres;
  final int yearsExperience;
  final int locationId;
  final String? token;
  final String? profilePhotoBase64;

  const SubmitFarmerDetails({
    required this.farmName,
    required this.farmPurpose,
    required this.totalLandAcres,
    required this.yearsExperience,
    required this.locationId,
    this.token,
    this.profilePhotoBase64,
  });

  @override
  List<Object?> get props => [
        farmName,
        farmPurpose,
        totalLandAcres,
        yearsExperience,
        locationId,
        token,
        profilePhotoBase64,
      ];
}

// ========================================
// SUBMIT VET DETAILS EVENT
// ========================================

class SubmitVetDetails extends AuthEvent {
  final String clinicName;
  final String licenseNumber;
  final String specialization;
  final double consultationFee;
  final int yearsExperience;
  final int locationId;
  final String? token;
  final String certificateBase64;
  final String licenseBase64;
  final List<String> clinicPhotosBase64;

  const SubmitVetDetails({
    required this.clinicName,
    required this.licenseNumber,
    required this.specialization,
    required this.consultationFee,
    required this.yearsExperience,
    required this.locationId,
    required this.certificateBase64,
    required this.licenseBase64,
    required this.clinicPhotosBase64,
    this.token,
  });

  @override
  List<Object?> get props => [
        clinicName,
        licenseNumber,
        specialization,
        consultationFee,
        yearsExperience,
        locationId,
        certificateBase64,
        licenseBase64,
        clinicPhotosBase64,
        token,
      ];
}

// ========================================
// SUBMIT RESEARCHER DETAILS EVENT
// ========================================

/// Event triggered when researcher submits their details
class SubmitResearcherDetails extends AuthEvent {
  final String affiliatedInstitution;
  final String department;
  final String researchPurpose;
  final String researchFocusArea;
  final String? academicTitle;
  final String? orcidId;
  final String? token;

  const SubmitResearcherDetails({
    required this.affiliatedInstitution,
    required this.department,
    required this.researchPurpose,
    required this.researchFocusArea,
    this.academicTitle,
    this.orcidId,
    this.token,
  });

  @override
  List<Object?> get props => [
        affiliatedInstitution,
        department,
        researchPurpose,
        researchFocusArea,
        academicTitle,
        orcidId,
        token,
      ];
}

// ========================================
// USER DETAILS UPDATED EVENT (New Fix)
// ========================================

/// 🎯 NEW: Event triggered by other BLoCs (e.g., ResearcherBloc) to update the core UserEntity
/// after a profile submission API call.
class UserDetailsUpdated extends AuthEvent {
  final UserEntity user;
  const UserDetailsUpdated(this.user);
  
  @override
  List<Object> get props => [user];
}

// ========================================
// USER LOCATION UPDATED EVENT - FULLY FIXED
// ========================================

/// Event triggered when user saves a new location (from LocationManagerPage)
/// Now passes the FULL LocationEntity so it can be stored in user.locations list
class UserLocationUpdated extends AuthEvent {
  final LocationEntity location;  // Full location object (not just ID!)
  final String? role;

  const UserLocationUpdated({
    required this.location,
    this.role,
  });

  @override
  List<Object?> get props => [location, role];
}




// ========================================
// LOGOUT EVENT
// ========================================

/// Event triggered when user requests to logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// ========================================
// CHECK AUTH STATUS EVENT
// ========================================

/// Event triggered to check current authentication status
/// Usually called on app startup
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}