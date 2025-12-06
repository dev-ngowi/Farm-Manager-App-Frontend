class Validators {
  Validators._(); // Private constructor (utility class)

  // ✅ Farm name validation
  static String? validateFarmName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Farm name is required';
    }
    if (value.length > 100) {
      return 'Farm name must be less than 100 characters';
    }
    return null; // Valid
  }

  // ✅ Total land acres validation (matches backend: 0.1-10000)
  static String? validateLandAcres(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Total land acres is required';
    }
    
    final acres = double.tryParse(value);
    if (acres == null) {
      return 'Please enter a valid number';
    }
    
    if (acres < 0.1 || acres > 10000) {
      return 'Must be between 0.1 and 10,000 acres';
    }
    
    return null;
  }

  // ✅ Years of experience validation (matches backend: 0-70)
  static String? validateExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Years of experience is required';
    }
    
    final years = int.tryParse(value);
    if (years == null) {
      return 'Please enter a valid number';
    }
    
    if (years < 0 || years > 70) {
      return 'Must be between 0 and 70 years';
    }
    
    return null;
  }

  // ✅ Farm purpose validation
  static String? validateFarmPurpose(String? value) {
    const validPurposes = ['Milk', 'Meat', 'Mixed', 'Other'];
    
    if (value == null || value.isEmpty) {
      return 'Farm purpose is required';
    }
    
    if (!validPurposes.contains(value)) {
      return 'Invalid farm purpose selected';
    }
    
    return null;
  }

  // ✅ Location validation
  static String? validateLocation(int? locationId) {
    if (locationId == null) {
      return 'Please select a location';
    }
    return null;
  }

  // 📧 Email validation (you might already have this)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
}