// lib/core/utils/validators.dart

/// A utility class containing static methods for common input validation tasks
/// in forms.
class Validators {
  /// Validates that a value is not null and not an empty string (after trimming).
  ///
  /// [value] The input string to validate.
  /// [fieldName] The name of the field, used in the error message.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates that a value is a valid non-negative double and is required.
  ///
  /// [value] The input string to validate.
  /// [fieldName] The name of the field, used in the error message.
  static String? validateDouble(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    if (number < 0) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  /// Validates that a value is a valid non-negative double, but is optional.
  /// Returns null if the field is empty or if the value is a valid double.
  ///
  /// [value] The input string to validate.
  /// [fieldName] The name of the field, used in the error message.
  static String? validateDoubleOptional(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      // Optional field, empty is acceptable
      return null;
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    if (number < 0) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  /// Validates that a value is a valid non-negative integer, but is optional.
  /// Returns null if the field is empty or if the value is a valid integer.
  ///
  /// [value] The input string to validate.
  /// [fieldName] The name of the field, used in the error message.
  static String? validateIntegerOptional(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      // Optional field, empty is acceptable
      return null;
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid whole number for $fieldName.';
    }
    if (number < 0) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  // You can add more specific validators here, e.g., for email, passwords, etc.
}