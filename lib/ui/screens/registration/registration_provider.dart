


import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';

class RegistrationProvider extends ChangeNotifier {
UserServiceProvider userProvider = UserServiceProvider();
  DateTime? selectedDate;
  UserDetails? userDetails;
  updateSelectedDate (DateTime pickedDate){
    selectedDate = pickedDate;
    notifyListeners();
  }
  updateUserDetails(UserDetails? userDetail){
    userDetails = userDetail;
    notifyListeners();
  }
}