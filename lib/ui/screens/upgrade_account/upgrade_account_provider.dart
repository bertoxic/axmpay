


import 'package:AXMPAY/models/transaction_model.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';

class UpgradeAccountProvider extends ChangeNotifier {
UserServiceProvider userProvider = UserServiceProvider();
//UserServiceProvider userProvider = Provider.of<UserServiceProvider>(context,listen: false);

  DateTime? selectedDate;
  UserDetails? userDetails;
  UserData? preRegistrationDetails;
  UpgradeWalletPayload? walletPayload;
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