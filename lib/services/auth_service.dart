import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  ApiService apiService = ApiService();
  UserServiceProvider userServiceProvider = UserServiceProvider();



  Future<Response<dynamic>> login(BuildContext context, LoginDetails userLoginDetails) async {
    try {
      Map<String, dynamic> userlogindetails = userLoginDetails.toJSON();
      print("Login request details: $userlogindetails");

      Response<dynamic> response = await apiService.post(
          context,
          "login.php",
          userlogindetails,
          ""
      );


      if (response.statusCode == 200) {
        print("Response received with status 200");

        // Parse the response data
        Map<String, dynamic> data;
        if (response.data is String) {
          data = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          data = response.data;
        } else {
          throw Exception('Unexpected response data type: ${response.data.runtimeType}');
        }

        print("Parsed response data: $data");

        // Check the status in the response
        if (data['status'] == 'Success') {
          print("Login successful");
          if (data.containsKey('token')) {
            // String obtainedToken = data['token'];
            // print("Obtained token: $obtainedToken");
            //
            // await SharedPreferencesUtil.saveString('auth_token', obtainedToken);
            // print("Token saved to SharedPreferences");
            //
            // String? savedToken = await SharedPreferencesUtil.getString('auth_token');
            // print("Retrieved token from SharedPreferences: $savedToken");


            //String? status = userServiceProvider.userdata?.status;
            return response;
          } else {
            throw Exception('Token not found in successful response');
          }
        } else if (data['status'] == 'Failed') {

          return response;
          throw Exception('Login failed: ${data['message']}');
        } else {
          throw Exception('Unexpected status in response: ${data['status']}');
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