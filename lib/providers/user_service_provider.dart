import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fintech_app/database/database.dart';
import 'package:fintech_app/database/user_repository.dart';
import 'package:fintech_app/providers/authentication_provider.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/utils/sharedPrefernce.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class UserServiceProvider extends ChangeNotifier {
  UserData? userdata;
  Wallet? wallet;
  BankListResponse? bankListResponse;
  ApiService apiService = ApiService();
  UserRepository userRepo = UserRepository();


  //     https://www.axmpay.com/api/v1/getBankNames.php

  Future<UserData?> getUserDetails() async {
    try {
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response = await apiService.get("getUserDetails.php", token);
      await getWalletDetails();
      if (response.statusCode != 200) {
        throw Exception(
            "status code is  : ${response.statusCode}, hence error");
      }
      userdata = UserData.fromJson(jsonDecode(response.data));
     // await getWalletDetails();
      await getBankNames();
      if (userdata != null) {
        userRepo.insertUser(userdata!);
        if (userdata?.id != null) {
          UserData? usr = await userRepo.getUserById(userdata!.id);
        }
      } else {
        throw Exception("userdata is null ....user_service_provider.dart");
      }
    } catch (e) {
      print("errorrr : $e");
    }
    notifyListeners();
    return userdata;
  }

  Future<Wallet?> getWalletDetails() async {
    try {

      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response = await apiService.get("walletEnquiry.php", token);
      wallet = Wallet.fromJson(jsonDecode(response.data));
      if (response.statusCode ==200) {
         // print("wallllett is ${wallet?.toJson()}");

      }
      if (response.statusCode != 200) {
        throw Exception(
            "status code is  : ${response.statusCode}, hence error");
      }

          print(jsonDecode(response.data));
    } catch (e) {
      print("errorrr : $e");
    }

    return wallet;
  }

  Future<BankListResponse?> getBankNames() async {

    String? token = await SharedPreferencesUtil.getString("auth_token");
   Response response = await apiService.get("getBankNames.php", token);
   var jsondata = jsonDecode(response.data);
    bankListResponse = BankListResponse.fromJson(jsondata);

  notifyListeners();
  print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ${bankListResponse?.bankList[0].bankName}");
    return bankListResponse;
  }


}
