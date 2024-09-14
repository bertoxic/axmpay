import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// State management
class PasscodeSetupModel extends ChangeNotifier {
  String _passcode = '';
  String _confirmedPasscode = '';
  bool _isConfirming = false;
  bool _isPasscodeVisible = false;
  bool _isConfirmedPasscodeVisible = false;

  String get passcode => _passcode;
  String get confirmedPasscode => _confirmedPasscode;
  bool get isConfirming => _isConfirming;
  bool get isPasscodeVisible => _isPasscodeVisible;
  bool get isConfirmedPasscodeVisible => _isConfirmedPasscodeVisible;

  void addDigit(String digit) {
    if (_isConfirming) {
      if (_confirmedPasscode.length < 5) {
        _confirmedPasscode += digit;
        notifyListeners();
      }
    } else {
      if (_passcode.length < 5) {
        _passcode += digit;
        notifyListeners();
      }
    }
  }


  void removeDigit() {
    if (_isConfirming) {
      if (_confirmedPasscode.isNotEmpty) {
        _confirmedPasscode = _confirmedPasscode.substring(0, _confirmedPasscode.length - 1);
      }
      else if (_passcode.isNotEmpty) {
        _isConfirming = false;
        _passcode = _passcode.substring(0, _passcode.length - 1);
      }
    } else {
      if (_passcode.isNotEmpty) {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      }
    }
    notifyListeners();
  }

  void togglePasscodeVisibility() {
    _isPasscodeVisible = !_isPasscodeVisible;
    notifyListeners();
  }

  void toggleConfirmedPasscodeVisibility() {
    _isConfirmedPasscodeVisible = !_isConfirmedPasscodeVisible;
    notifyListeners();
  }

  void switchToConfirmation() {
    if (_passcode.length == 5) {
      _isConfirming = true;
      notifyListeners();
    }else if(_confirmedPasscode.isEmpty){
      _isConfirming = false;
      notifyListeners();
    }
  }

  Future<void> savePasscode() async {
    if (_passcode == _confirmedPasscode && _passcode.length == 5) {
      final storage = FlutterSecureStorage();
      await storage.write(key: 'passcode', value: _passcode);
      String? pass = await storage.read(key: "passcode");
      //await storage.delete(key: "passcode");
       pass = await storage.read(key: "passcode");
      notifyListeners();
    }
  }
}

