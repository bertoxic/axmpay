import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fintech_app/database/database.dart';
import 'package:fintech_app/database/user_repository.dart';
import 'package:fintech_app/providers/authentication_provider.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/utils/sharedPrefernce.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';
import '../models/recepients_model.dart';
import '../models/user_model.dart';
import '../utils/global_error_handler.dart';

class UserServiceProvider extends ChangeNotifier {
  UserData? userdata;
  Wallet? wallet;
  BankListResponse? bankListResponse;
  ApiService apiService = ApiService();
  UserRepository userRepo = UserRepository();

  //     https://www.axmpay.com/api/v1/getBankNames.php

  Future<UserData?> getUserDetails(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response = await apiService.get(context,"getUserDetails.php", token);
      //await getWalletDetails();
      // if (response.statusCode != 200) {
      //   throw Exception(
      //       "status code is  : ${response.statusCode}, hence error");
      // }
      if (response.statusCode==401) {
        throw TokenExpiredException();
      }
      userdata = UserData.fromJson(jsonDecode(response.data));
      // await getWalletDetails();
      await getBankNames(context);
      if (userdata != null) {
        userRepo.insertUser(userdata!);
        if (userdata?.id != null) {
          UserData? usr = await userRepo.getUserById(userdata!.id);
          print(userdata);
        }
      } else {
        throw Exception("userdata is null ....user_service_provider.dart");
      }
    } catch (e) {
      print("errorrrx : $e");
      rethrow;
    }
    notifyListeners();
    return userdata;
  }

  Future<Wallet?> getWalletDetails(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response = await apiService.get(context,"getUserWalletDetails.php", token);
      wallet = Wallet.fromJson(jsonDecode(response.data));
      if (response.statusCode == 200) {
        print("wallllett is ${wallet?.toJson()}");
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

  Future<BankListResponse?> getBankNames(BuildContext context) async {
    String? token = await SharedPreferencesUtil.getString("auth_token");
    Response response = await apiService.get(context,"getBankNames.php", token);
    var jsondata = jsonDecode(response.data);
    bankListResponse = BankListResponse.fromJson(jsondata);

    notifyListeners();
    return bankListResponse;
  }

  Future<RecipientDetails?> getReceiversAccountDetails (
      AccountRequestDetails accountRequestDetails) async {
    try{
    final data = accountRequestDetails.toJson();
    String? token = await SharedPreferencesUtil.getString('auth_token');
    final response =
        await apiService.post("getAccountDetails.php", data, token);

    var jsonData = jsonDecode(response.data);
    if (jsonData["status"]=="failed") {
      throw Exception("unable to get receiver's account");
    }
    RecipientDetails recipientDetails = RecipientDetails.fromJson(jsonData);
    return recipientDetails;
  }catch(e){
      print("erorr occured in userservice provider"+e.toString());
      rethrow;
    }
  }

  makeBankTransfer(TransactionModel transactionModel) async{
    try{
    final data = transactionModel.toJson();
    String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("bankTransfer.php", data, token);
    var jsonData = jsonDecode(response.data);
  }catch(e){
      rethrow;
    }
  }
 Future<List<TransactionHistoryModel>> fetchTransactionHistory(BuildContext context)async {
    try{
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.get(context,"fetchTransactions.php", token);
    var jsonData = jsonDecode(response.data);
     var  data=List<TransactionHistoryModel>.from(
        jsonData['data'].map((transactionJson) => TransactionHistoryModel.fromJson(transactionJson)));
      return data;
  }catch(e){
      print("throoooooooooooowwwwwwwwwwwwwwwww");
      handleGlobalError(context, e);
      rethrow;
  }
  }

  Future<SpecificTransactionData> fetchTransactionDetails(BuildContext context, String trxID)async {
    try{
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.get(context,"transactionsDetails.php?trxID=$trxID", token);
    var jsonData = jsonDecode(response.data);
     var  transactionData = SpecificTransactionData.fromJson(jsonData);
      return transactionData;
  }catch(e){
      print("throoooooooooooowwwwwwwwwwwwwwwww error");
      handleGlobalError(context, e);
      rethrow;
  }
  }

  Future<String> sendVerificationCode(BuildContext context, String email)async {
    try{
      Map<String, dynamic> data = {"email":email};
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("sendVerificationCode.php?", data, token);
    var jsonData = jsonDecode(response.data);
    if (jsonData["status"]=="failed") {
      throw Exception(jsonData["message"]);
    }
    return jsonData["status"].toString();
  }catch(e){
      handleGlobalError(context, e);
      rethrow;
  }
  }


}

