import '../../config/constants.dart';

class Validators {
  // Validasi email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    }
    
    // Regex untuk validasi email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.emailInvalid;
    }
    
    return null;
  }
  
  // Validasi password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordTooShort;
    }
    
    return null;
  }
  
  // Validasi konfirmasi password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return AppConstants.passwordMismatch;
    }
    
    return null;
  }
  
  // Validasi nama lengkap
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.nameRequired;
    }
    
    if (value.length < AppConstants.minNameLength) {
      return AppConstants.nameTooShort;
    }
    
    if (value.length > AppConstants.maxNameLength) {
      return 'Nama maksimal ${AppConstants.maxNameLength} karakter';
    }
    
    return null;
  }
  
  // Validasi field required
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }
}
