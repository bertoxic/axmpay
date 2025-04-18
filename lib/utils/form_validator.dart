
enum ValidatorType { name, email, password, digits, remarks, isEmpty }

class FormValidator {
  static String? validate(String? value, ValidatorType type, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? type.toString().split('.').last.capitalize()} is required';
    }

    switch (type) {
      case ValidatorType.name:
        return validateName(value);
      case ValidatorType.email:
        return validateEmail(value);
      case ValidatorType.password:
        return validatePassword(value);
      case ValidatorType.digits:
        return validateDigits(value);
      case ValidatorType.remarks:
        return validateRemarks(value);
      case ValidatorType.isEmpty:
        return validateNotEmpty(value);
    }
  }

  static String? validateName(String value) {
    if (value.length < 2) {
      return 'Name must be at least 3 characters long';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z]+(?: [a-zA-Z]+)*$').hasMatch(value)) {
      return 'Name can only contain letters and single spaces between words';
    }
    return null;
  }

  static String? validateEmail(String value) {
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  static String? validateNotEmpty(String value) {
    if (value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }
  static String? validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }
    return null;
  }

  static String? validateDigits(String value) {
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter only digits';
    }
    if (value.length > 11) {
      return 'Input must not exceed 10 digits';
    }
    return null;
  }

  static String? validateRemarks(String value) {
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Please enter only letters';
    }
    if (value.length > 50) {
      return 'Input must not exceed 50 letters';
    }
    return null;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}