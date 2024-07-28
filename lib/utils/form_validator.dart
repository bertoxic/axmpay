import 'package:flutter/material.dart';

enum ValidatorType { name, email, password }

class FormValidator {
  static String? validate(String? value, ValidatorType type, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? type.toString().split('.').last.capitalize()} is required';
    }

    switch (type) {
      case ValidatorType.name:
        return _validateName(value);
      case ValidatorType.email:
        return _validateEmail(value);
      case ValidatorType.password:
        return _validatePassword(value);
    }
  }

  static String? _validateName(String value) {
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

  static String? _validateEmail(String value) {
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? _validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }
    return null;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}