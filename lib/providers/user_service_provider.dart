import 'dart:convert';
import 'dart:io';

import 'package:AXMPAY/models/other_models.dart';
import 'package:dio/dio.dart';
import 'package:AXMPAY/database/user_repository.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/services/api_service.dart';
import 'package:flutter/material.dart';

import '../models/recepients_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../utils/global_error_handler.dart';
import '../utils/sharedPrefernce.dart';


class UserServiceProvider extends ChangeNotifier {
  UserData? userdata;
  Wallet? wallet;
  BankListResponse? bankListResponse;
  List<TransactionHistoryModel>? transactHistoryList;
  AxmpayFaqList? axmpayFaqList = AxmpayFaqList(faqs: null);
  AxmpayTermsList? axmpayTermsList = AxmpayTermsList(data: null);
  TermSection? termSection;
  ApiService apiService = ApiService();
  UserRepository userRepo = UserRepository();

  //     https://www.axmpay.com/api/v1/getBankNames.php

  Future<UserData?> getUserDetails(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response = await apiService.get(
          context, "getUserDetails.php", token);

      if (response.statusCode == 401) {
        throw TokenExpiredException();
      }

      // Debug information
      print("Response type: ${response.data.runtimeType}");

      // Handle the response data properly
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map) {
        jsonData = Map<String, dynamic>.from(response.data);
      } else {
        throw Exception(
            "Unexpected response format: ${response.data.runtimeType}");
      }

      // Use jsonData instead of parsing response.data again
      userdata = UserData.fromJson(jsonData);
      notifyListeners();

      // await getWalletDetails();
      await getBankNames(context);

      if (userdata != null) {
        userRepo.insertUser(userdata!);
        if (userdata?.id != null) {
          int? userID = int.tryParse(userdata!.id);
          if (userID != null) {
            UserData? usr = await userRepo.getUserById(userID);
            print("datazzzz$userdata");
          } else {
            print("Failed to parse user ID: ${userdata!.id}");
          }
        }
      } else {
        throw Exception("userdata is null ....user_service_provider.dart");
      }
    } catch (e) {
      print("errorrrx : $e");
      rethrow;
    }
    return userdata;
  }


  Future<Wallet?> getWalletDetails(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response =
      await apiService.get(context, "getUserWalletDetails.php", token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format");
      }

      wallet = Wallet.fromJson(jsonData);

      if (response.statusCode == 200) {
        print("wallllett is ${wallet?.toJson()}");
      }
      if (response.statusCode != 200) {
        throw Exception(
            "status code is  : ${response.statusCode}, hence error");
      }

      print(jsonData);
    } catch (e) {
      print("errorrr : $e");
    }

    return wallet;
  }

  Future<BankListResponse?> getBankNames(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      Response response =
      await apiService.get(context, "getBankNames.php", token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format");
      }

      bankListResponse = BankListResponse.fromJson(jsonData);

      notifyListeners();
      return bankListResponse;
    } catch (e) {
      print("error occurred in getBankNames: $e");
      rethrow;
    }
  }

  Future<RecipientDetails?> getReceiversAccountDetails(BuildContext context,
      AccountRequestDetails accountRequestDetails) async {
    try {
      final data = accountRequestDetails.toJson();
      String? token = await SharedPreferencesUtil.getString('auth_token');
      final response =
      await apiService.post(context, "getAccountDetails.php", data, token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format");
      }

      if (jsonData["status"] == "failed") {
        throw Exception("unable to get receiver's account");
      }
      RecipientDetails recipientDetails = RecipientDetails.fromJson(jsonData);
      return recipientDetails;
    } catch (e) {
      print("error occurred in userservice provider: $e");
      rethrow;
    }
  }

  Future<ResponseResult?> makeBankTransfer(BuildContext context,
      TransactionModel transactionModel) async {
    try {
      final data = transactionModel.toJson();
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response =
      await apiService.post(context, "bankTransfer.php", data, token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Verification failed",
          data: jsonData["data"] is Map<String, dynamic>
              ? jsonData["data"]
              : null,
        );
      }
      getUserDetails(context);
      notifyListeners();
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Verification successful",
        data: jsonData["data"] is Map<String, dynamic>
            ? jsonData["data"]
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionHistoryModel>> fetchTransactionHistory(
      BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response = await apiService.get(
          context, "fetchTransactions.php?limit=32", token);

      // Debug info
      print("Transaction history response type: ${response.data.runtimeType}");

      // Parse the response data correctly based on its type
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map) {
        jsonData = Map<String, dynamic>.from(response.data);
      } else {
        throw Exception(
            "Unexpected response format: ${response.data.runtimeType}");
      }

      // Check if data is empty
      if (jsonData["Data"]?.toString() == "[]" ||
          jsonData["data"]?.toString() == "[]") {
        return [];
      }

      // Handle possible different case in the JSON response ('Data' vs 'data')
      var transactionData = jsonData['data'] ?? jsonData['Data'];
      if (transactionData == null) {
        print("No 'data' or 'Data' field found in response: $jsonData");
        return [];
      }

      var data = List<TransactionHistoryModel>.from(transactionData.map(
              (transactionJson) =>
              TransactionHistoryModel.fromJson(transactionJson)));

      transactHistoryList = data;
      notifyListeners();
      return data;
    } catch (e) {
      print("Error fetching transaction history: $e");
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<AxmpayFaqList?> getFAQs(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response = await apiService.get(context, "FAQs.php", token);
      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;
      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format in getFAQs");
      }
      if (jsonData["status"] == "failed") {
        return null;
      }
      // Check if jsonData["data"] is a list or a map
      if (jsonData["data"] is List) {
        // If it's a list, wrap it in a map with 'faqs' key
        AxmpayFaqList data = AxmpayFaqList.fromJson({"faqs": jsonData["data"]});
        axmpayFaqList = data;
        notifyListeners();
        return data;
      } else if (jsonData["data"] is Map) {
        // If it's already a map, pass it directly
        AxmpayFaqList data = AxmpayFaqList.fromJson(jsonData["data"]);
        axmpayFaqList = data;
        notifyListeners();
        return data;
      } else {
        // Handle empty or invalid data
        AxmpayFaqList data = AxmpayFaqList(faqs: []);
        axmpayFaqList = data;
        notifyListeners();
        return data;
      }
    } catch (e) {
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<AxmpayTermsList?> getTandC(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response = await apiService.get(
          context, "termsConditions.php", token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format in getTandC");
      }

      if (jsonData["status"] == "failed") {
        return null;
      }

      // Fixed: Use jsonData instead of response.data for creating the object
      AxmpayTermsList data = AxmpayTermsList.fromJson(jsonData);
      axmpayTermsList = data;
      notifyListeners();
      return data;
    } catch (e) {
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<SpecificTransactionData> fetchTransactionDetails(BuildContext context,
      String trxID) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response = await apiService.get(
          context, "transactionsDetails.php?trxID=$trxID", token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format in fetchTransactionDetails");
      }

      var transactionData = SpecificTransactionData.fromJson(jsonData);
      return transactionData;
    } catch (e) {
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> sendVerificationCode(BuildContext context,
      String email) async {
    try {
      Map<String, dynamic> data = {"email": email};
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response = await apiService.post(
          context, "sendVerificationCode.php?", data, token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format in sendVerificationCode");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? " failed",
          data: jsonData["data"] is Map<String, dynamic>
              ? jsonData["data"]
              : null,
        );
      }

      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? " successful",
        data: jsonData["data"] is Map<String, dynamic>
            ? jsonData["data"]
            : null,
      );
    } catch (e) {
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<ResponseResult> verifyOTPForPasswordChange(BuildContext context,
      String email, String otp) async {
    try {
      Map<String, dynamic> data = {"email": email, "code": otp};
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response =
      await apiService.post(context, "verifyCode.php?", data, token);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception(
            "Invalid response format in verifyOTPForPasswordChange");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Verification failed",
          data: jsonData["data"] is Map<String, dynamic>
              ? jsonData["data"]
              : null,
        );
      }

      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Verification successful",
        data: jsonData["data"] is Map<String, dynamic>
            ? jsonData["data"]
            : null,
      );
    } catch (e) {
      if (!context.mounted) {
        throw e;
      }
      handleGlobalError(context, e);
      throw e;
    }
  }

  Future<ResponseResult> resendOtp(BuildContext context, String email) async {
    try {
      Map<String, dynamic> requestData = {"email": email};
      final response = await apiService.post(
          context, "resendEmailOtp.php", requestData, null);

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format in resendOtp");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Failed to resend OTP",
          data: jsonData["data"] is Map<String, dynamic>
              ? jsonData["data"]
              : null,
        );
      }

      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "OTP resent successfully",
        data: jsonData["data"] is Map<String, dynamic>
            ? jsonData["data"]
            : null,
      );
    } catch (e) {
      if (!context.mounted) {
        throw e;
      }
      handleGlobalError(context, e);
      throw e;
    }
  }

  Future<ResponseResult> emailVerification(BuildContext context, email,
      String otp) async {
    try {
      Map<String, dynamic> requestData = {"otp": otp, "email": email};
      final response = await apiService.post(
          context, "verifyEmailOtp.php", requestData, null);
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else {
        jsonData = response.data;
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Verification failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }

      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Verification successful",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        throw e;
      }
      handleGlobalError(context, e);
      throw e;
    }
  }

  Future<String> xemailVerification(BuildContext context, String otp) async {
    try {
      Map<String, dynamic> data = {"verification_code": otp};
      final response =
      await apiService.post(context, "emailVerification.php", data, null);
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else {
        jsonData = response.data;
      }
      if (jsonData["status"] == "failed") {
        throw Exception(jsonData["message"]);
      }
      return jsonData["status"].toString();
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<String> changeUserPassword(BuildContext context, String email,
      String otp, String password) async {
    try {
      Map<String, dynamic> data = {
        "email": email,
        "code": otp,
        "newPassword": password
      };
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response =
      await apiService.post(context, "updatePassword.php?", data, token);

      if (response.data == null) {
        throw Exception("no response from the server");
      }

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        jsonData = jsonDecode(responseData);
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format in changeUserPassword");
      }

      // Check if status exists in the response
      if (!jsonData.containsKey("status")) {
        throw Exception("Response does not contain 'status' field");
      }

      return jsonData["status"].toString();
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<String> createAccount(BuildContext context,
      PreRegisterDetails userDetails) async {
    try {
      print("Starting account creation process...");

      // Ensure `userDetails` has valid data
      if (userDetails == null) {
        throw Exception("User details cannot be null.");
      }

      // Convert user details to JSON
      Map<String, dynamic> data = userDetails.toJSON();

      // Check if `data` is a valid map
      if (data.isEmpty) {
        throw Exception("User details data is empty.");
      }

      // Make API call
      final response =
      await apiService.post(context, "createAccount.php?", data, null);

      // Check if response is null
      if (response == null) {
        throw Exception("No response received from the server.");
      }

      // Check if response data is null or empty
      if (response.data == null) {
        throw Exception("Response data is null.");
      }

      if (response.data is String && response.data
          .toString()
          .isEmpty) {
        throw Exception("Response data is empty.");
      }

      // Debugging: Log response details
      print("Response code: ${response.statusCode}");
      print("Raw response data: ${response.data}");

      // Handle response data whether it's a string or already a map
      dynamic responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is String) {
        try {
          jsonData = jsonDecode(responseData);
        } catch (error) {
          print("Error decoding response data: $error");
          throw Exception("Failed to decode response data: ${responseData}");
        }
      } else if (responseData is Map) {
        jsonData = responseData as Map<String, dynamic>;
      } else {
        throw Exception(
            "Response data is neither a Map nor a valid JSON string.");
      }

      // Check for status in the JSON response
      if (!jsonData.containsKey("status")) {
        throw Exception("Response does not contain 'status' field.");
      }

      // Return status as a string
      return jsonData["status"].toString();
    } catch (e) {
      // Ensure context is mounted before handling exceptions
      if (!context.mounted) {
        rethrow;
      }

      // Log the caught exception for debugging
      print("Caught exception of type: ${e.runtimeType}");
      print("Error creating account: $e");

      // Handle exception globally and rethrow
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }


  Future<String> updateUserDetails(BuildContext context, String email,
      String password) async {
    try {
      Map<String, dynamic> data = {"email": email, "password": password};
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response =
      await apiService.post(context, "updateUserDetails.php?", data, token);
      if (response.data == null) {
        throw Exception("no response from the server");
      }

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      // if (jsonData["status"]=="failed") {
      //   throw Exception(jsonData["message"]);
      // }
      return jsonData["status"].toString();
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<String> updateUserRegistrationDetails(BuildContext context,
      UserDetails userDetails) async {
    try {
      Map<String, dynamic> data = userDetails.toJSON();
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response =
      await apiService.post(context, "updateUserDetails.php", data, token);
      if (response.data == null) {
        throw Exception("no response from the server");
      }

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      // if (jsonData["status"]=="failed") {
      //   throw Exception(jsonData["message"]);
      // }
      return jsonData["status"].toString();
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult> createUserWallet(BuildContext context,
      WalletPayload walletPayload) async {
    try {
      Map<String, dynamic> data = walletPayload.toJSON();
      print(data);
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response = await apiService.post(
          context, "createWallet.php", data, token);
      print("rexponzxxxxxxxxxxxxxxxxxzzz iz: ${response.toString()}");

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      return ResponseResult(
        status: jsonData["status"] == "failed"
            ? ResponseStatus.failed
            : ResponseStatus.success,
        message: jsonData["message"] ?? (jsonData["status"] == "failed"
            ? "Wallet creation failed"
            : "Wallet creation successful"),
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: "Error: ${e.toString()}",
          data: null,
        );
      }
      handleExceptionGlobally(context, e);
      return ResponseResult(
        status: ResponseStatus.failed,
        message: "Error creating wallet",
        data: null,
      );
    }
  }

  Future<ResponseResult> upgradeUserWallet(BuildContext context,
      UpgradeWalletPayload walletPayload) async {
    try {
      Map<String, dynamic> data = walletPayload.toJson();
      String? token = await SharedPreferencesUtil.getString("auth_token");
      final response =
      await apiService.post(context, "upgradeWallet.php", data, token);

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Verification failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Verification successful",
        data: jsonData["data"] as Map<String, dynamic>?,);
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> getNetworkProvider(BuildContext context,
      String phoneNumber) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;
      final response = await apiService.get(
          context, "API-9PSB/VAS/getNetwork.php?phoneNumber=$phoneNumber",
          token);

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Verification failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Verification successful",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<DataBundleList?>? getDataPlans(BuildContext context,
      String phoneNumber) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;
      final response = await apiService.get(context,
          "API-9PSB/VAS/getDataPlans.php?phoneNumber=$phoneNumber", token);
      if (response.statusCode != 200) {
        throw Exception("no response from the server");
      }

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      return DataBundleList.fromJson(jsonData);
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> buyAirtime(BuildContext context,
      TopUpPayload topUpPayload) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;
      final response = await apiService.post(
          context, "buyAirtime.php", topUpPayload.toJson(), token);
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else {
        jsonData = response.data;
      }
      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "buyairtime failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "buyairtime successful",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> topUpData(BuildContext context,
      TopUpPayload topUpPayload) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;
      final response = await apiService.post(
          context, "topupData.php", topUpPayload.toJson(), token);

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "dataTopUp failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "DataTopUp successful",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> cashOutEarnings(BuildContext context,
      String amount) async {
    Map<String, dynamic> data = {"totalAmount": amount};
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;
      final response = await apiService.post(
          context, "cashoutEarnings.php", data, token);

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      if (jsonData["status"].toString().toLowerCase() == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "earningTopUp failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "earning withdrawal successful",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> fetchReferralDetails(BuildContext context) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;
      final response = await apiService.get(
          context, "fetchReferralDetails.php", token);

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Verification failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Verification successful",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }

  Future<ResponseResult?> changePassword(BuildContext context, {
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      String? token = await SharedPreferencesUtil.getString("auth_token");
      if (!context.mounted) return null;

      // Make a POST request to changePassword.php
      final response = await apiService.post(
          context,
          "profileUpdatePassword.php",
          {
            "oldPassword": oldPassword,
            "newPassword": newPassword,
          },
          token

      );

      // Handle both String and Map response types
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception("Unexpected response format");
      }

      if (jsonData["status"] == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"] ?? "Change password failed",
          data: jsonData["data"] as Map<String, dynamic>?,
        );
      }
      return ResponseResult(
        status: ResponseStatus.success,
        message: jsonData["message"] ?? "Password changed successfully",
        data: jsonData["data"] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (!context.mounted) {
        rethrow;
      }
      handleExceptionGlobally(context, e);
      rethrow;
    }
  }


  void handleExceptionGlobally(BuildContext context, dynamic e) {
    print("Caught exception of type: ${e.runtimeType}");

    if (e is SocketException) {
      handleGlobalError(
          context, "No Internet connection. Please try again later.");
    } else if (e is HttpException) {
      handleGlobalError(context,
          "Failed to communicate with the server. Please try again later.");
    } else if (e is FormatException) {
      handleGlobalError(
          context, "Bad response format. Please try again later.");
    } else if (e is TypeError) {
      handleGlobalError(context, "Unexpected type error occurred.");
    } else {
      // Handle any other type of error
      handleGlobalError(context, e.toString());
    }
  }
}
