


import 'package:fintech_app/models/transaction_model.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';

class RegistrationProvider extends ChangeNotifier {
UserServiceProvider userProvider = UserServiceProvider();
  DateTime? selectedDate;
  UserDetails? userDetails;
  WalletPayload? walletPayload;
  updateSelectedDate (DateTime pickedDate){
    selectedDate = pickedDate;
    notifyListeners();
  }
  updateUserDetails(UserDetails? userDetail){
    userDetails = userDetail;
    notifyListeners();
  }
}