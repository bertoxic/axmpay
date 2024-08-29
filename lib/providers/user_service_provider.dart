import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fintech_app/database/user_repository.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/utils/sharedPrefernce.dart';
import 'package:flutter/cupertino.dart';

import '../models/recepients_model.dart';
import '../models/transaction_model.dart';
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
          print("zqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq$userdata");
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
      print("erorr occured in userservice provider$e");
      rethrow;
    }
  }

  makeBankTransfer(TransactionModel transactionModel) async{
    try{
    final data = transactionModel.toJson();
    String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("bankTransfer.php", data, token);
    if(response.data != null){
      var jsonData = jsonDecode(response.data);
    }else {
      throw Exception("respose has no data for banktransfer");
    }
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
    // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){

      handleGlobalError(context, e);
      rethrow;
  }
  }

  Future<String> verifyOTPForPasswordChange(BuildContext context, String email, String otp)async {
    try{
      Map<String, dynamic> data = {"email":email,"code":otp};
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("verifyCode.php?", data, token);
    var jsonData = jsonDecode(response.data);
    // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
      handleGlobalError(context, e);
      rethrow;
  }
  }
  Future<String> emailVerification(BuildContext context, String otp)async {
    try{
      Map<String, dynamic> data = {"verification_code":otp};
    final response = await apiService.post("emailVerification.php", data, null);
    var jsonData = jsonDecode(response.data);
    // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
      handleGlobalError(context, e);
      rethrow;
  }
  }

  Future<String> changeUserPassword(BuildContext context, String email, String otp, String password)async {
    try{
      Map<String, dynamic> data = {"email":email,"code":otp,"newPassword":password};
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("updatePassword.php?", data, token);
      if (response.data == null) {
        throw Exception("no response from the server");
      }
    var jsonData = jsonDecode(response.data);
    // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
 handleExceptionGlobally(context, e);
      rethrow;
  }
  }
  Future<String> createAccount(BuildContext context, PreRegisterDetails userDetails)async {
    try{

      Map<String, dynamic> data = userDetails.toJSON();
    final response = await apiService.post("createAccount.php?", data, null);

      if (response.data == null) {
        throw Exception("no response from the server");
      }
    var jsonData = jsonDecode(response.data);
      // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
 handleExceptionGlobally(context, e);
      rethrow;
  }
  }
Future<String> updateUserDetails(BuildContext context, String email, String password)async {
    try{
      Map<String, dynamic> data = {"email":email,"password":password};
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("updateUserDetails.php?", data, token);
      if (response.data == null) {
        throw Exception("no response from the server");
      }
    var jsonData = jsonDecode(response.data);
    // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
 handleExceptionGlobally(context, e);
      rethrow;
    }}

Future<String> updateUserRegistrationDetails(BuildContext context, UserDetails userDetails)async {
    try{
      Map<String, dynamic> data = userDetails.toJSON();
      print(data);
      String? token = await SharedPreferencesUtil.getString("auth_token");
    final response = await apiService.post("updateUserDetails.php?", data, null);
      if (response.data == null) {
        throw Exception("no response from the server");
      }
    var jsonData = jsonDecode(response.data);
    // if (jsonData["status"]=="failed") {
    //   throw Exception(jsonData["message"]);
    // }
    return jsonData["status"].toString();
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
 handleExceptionGlobally(context, e);
      rethrow;
    }}

Future<String?> getNetworkProvider(BuildContext context, String phoneNumber)async {
    try{
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if(!context.mounted) return "";
    final response = await apiService.get(context,"API-9PSB/VAS/getNetwork.php?phoneNumber=$phoneNumber"  ,token);
      if (response.statusCode != 200) {
        throw Exception("no response from the server");
      }
    var jsonDat = jsonEncode(response.data);
      String jsonData = jsonDecode(jsonDat);

    return jsonData;
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
 handleExceptionGlobally(context, e);
      rethrow;
  }}

Future<DataBundleList?>? getDataPlans(BuildContext context, String phoneNumber)async {
    try{
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if(!context.mounted) return null;
    final response = await apiService.get(context,"API-9PSB/VAS/getDataPlans.php?phoneNumber=$phoneNumber"  ,token);
      if (response.statusCode != 200) {
        throw Exception("no response from the server");
      }
      Map<String, dynamic> jsonData;
      if(response.data is String){
        jsonData = jsonDecode(response.data);
      }else{
        jsonData = response.data;
      }
      DataBundleList.fromJson(jsonData);

    return   DataBundleList.fromJson(jsonData);
  }catch(e){
      if (!context.mounted) {
        rethrow;
      }
 handleExceptionGlobally(context, e);
      rethrow;
  }}



  Future<String> buyAirtime (BuildContext context, TopUpPayload topUpPayload)async {
    try{
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if(!context.mounted) return "";
      final response = await apiService.post("buyAirtime.php/phoneNumber",
          topUpPayload.toJson(),token);
      if (response.data == null) {
        throw Exception("no response from the server");
      }
      print(response.data);
      var jsonData = jsonDecode(response.data);
      // if (jsonData["status"]=="failed") {
      //   throw Exception(jsonData["message"]);
      // }
      return jsonData["status"].toString();
    }catch(e){
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }}
  Future<String> topUpData (BuildContext context, TopUpPayload topUpPayload)async {
    try{
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if(!context.mounted) return "";
      final response = await apiService.post("topupData.php",
          topUpPayload.toJson(),token);
      if (response.data == null) {
        throw Exception("no response from the server");
      }
      print(response.data);
      var jsonData = jsonDecode(response.data);
      // if (jsonData["status"]=="failed") {
      //   throw Exception(jsonData["message"]);
      // }
      return jsonData["status"].toString();
    }catch(e){
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }}






}




void handleExceptionGlobally(BuildContext context, dynamic e) {
  print("Caught exception of type: ${e.runtimeType}");

  if (e is SocketException) {
    handleGlobalError(context, "No Internet connection. Please try again later.");
  } else if (e is HttpException) {
    handleGlobalError(context, "Failed to communicate with the server. Please try again later.");
  } else if (e is FormatException) {
    handleGlobalError(context, "Bad response format. Please try again later.");
  } else if (e is TypeError) {
    handleGlobalError(context, "Unexpected type error occurred.");
  } else {
    // Handle any other type of error
    handleGlobalError(context, e.toString());
  }
}

