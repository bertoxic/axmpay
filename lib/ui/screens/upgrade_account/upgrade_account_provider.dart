


import 'package:fintech_app/models/transaction_model.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';

class UpgradeAccountProvider extends ChangeNotifier {
UserServiceProvider userProvider = UserServiceProvider();
  DateTime? selectedDate;
  UserDetails? userDetails;
  UserData? preRegistrationDetails;
  WalletPayload? walletPayload;
  updateSelectedDate (DateTime pickedDate){
    selectedDate = pickedDate;
    notifyListeners();
  }
  UserData? getUserDetails (){
    preRegistrationDetails =  userProvider.userdata;
    notifyListeners();
    return preRegistrationDetails;
  }
  updateUserDetails(UserDetails? userDetail){
    userDetails = userDetail;
    notifyListeners();
  }
}