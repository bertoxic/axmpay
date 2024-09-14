import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';
import '../utils/sharedPrefernce.dart';
import 'api_service.dart';

class AuthService {
  ApiService apiService = ApiService();
  UserServiceProvider userServiceProvider = UserServiceProvider();
  Future<Map<String,dynamic>?>? login(BuildContext context, LoginDetails userLoginDetails) async {
    try {
      Map<String, dynamic> userlogindetails = userLoginDetails.toJSON();

      // Log the request details
      print("Login request details: $userlogindetails");

      // API call
      Response response = await apiService.post( context,"login.php", userlogindetails,"");
      // Log the full response
      print("Full responsexlogin: $response");
      print("Response status codexlogin: ${response.statusCode}");
      print("Response dataxlogin: ${response.data.toString()}");

      if (response.statusCode == 200) {

        // Check if response.data is a String, if so, try to parse it
        if (response.data is String) {

          try {
            Map<String, dynamic> jsonData = jsonDecode(response.data);
            response.data = jsonData;
          } catch (e) {
            print("Error parsing response data: $e");
          }
        }

        // Access token from response data
        if (response.data is Map<String, dynamic> && response.data['token'] != null) {
          String obtainedToken = response.data["token"];
          print("Obtained token: $obtainedToken");

          await SharedPreferencesUtil.saveString('auth_token', obtainedToken);
          print("Token saved to SharedPreferences");

          String? savedToken = await SharedPreferencesUtil.getString('auth_token');
          print("Retrieved token from SharedPreferences: $savedToken");
          await userServiceProvider.getUserDetails(context);
          String? status = userServiceProvider.userdata?.status;
          return {"obtainedToken":obtainedToken, "status":status};
        } else {
          print("Error: 'token' key not found in response data");
          print("Response data structure: ${response.data.runtimeType}");
          throw Exception('Token not found in response');
        }
      } else {
        print("Error: Unexpected status code ${response.statusCode}");
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioException occurred: $e");
      print("DioException type: ${e.type}");
      print("DioException message: ${e.message}");
      print("DioException response: ${e.response}");
      return Future.error(e);
    } catch (e) {
      print("Unexpected error occurred: $e");
      return Future.error(e);
    }
  }

  Future<void> Register(BuildContext context,PreRegisterDetails userdetails) async {
    try {
      Map<String, dynamic> details = userdetails.toJSON();
      final res = await apiService.post( context,"signup", details,"");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var u = User.fromJSON(res.data);
        print("User registered successfully: $u");
      } else {
        print("Registration failed with status code: ${res.statusCode}");
        throw Exception('Registration failed: ${res.statusCode}');
      }
    } catch (e) {
      print("Error during registration: $e");
      rethrow;
    }
  }
}