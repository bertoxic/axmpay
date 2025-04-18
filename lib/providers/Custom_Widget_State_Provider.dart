

import 'package:flutter/cupertino.dart';

class CustomWidgetStateProvider<T> extends ChangeNotifier {
 bool _dropdownValue= false;

 bool get dropdownValue => _dropdownValue;

 void setDropdownValue(bool newValue) {
  _dropdownValue = newValue;
  notifyListeners();
 }
}