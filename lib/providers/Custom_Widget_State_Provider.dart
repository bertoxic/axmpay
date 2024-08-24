

import 'package:flutter/cupertino.dart';

class CustomWidgetStateProvider<T> extends ChangeNotifier {
 T? _dropdownValue;

 T? get dropdownValue => _dropdownValue;

 void setDropdownValue(T? newValue) {
  _dropdownValue = newValue;
  notifyListeners();
 }
}