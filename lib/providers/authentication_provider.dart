import 'dart:convert';

import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/services/api_service.dart';
import '../utils/sharedPrefernce.dart';


class AuthenticationProvider extends ChangeNotifier {
  String? _token;
  final ApiService apiService;
  final BuildContext context;
  final AuthService  authService = AuthService();
  bool _isAuthenticated = false;
  String? _errMessage;
  AuthenticationProvider(this.context, {required this.apiService});

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  String? get errMessage => _errMessage;

  //setter function ------------------------------------------>  ---------------->  ------------------>
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }


  Future<ResponseResult?> login(BuildContext context, LoginDetails userdetails) async {
    UserServiceProvider userServiceProvider = Provider.of(context, listen: false);
    try {
      final response = await authService.login(context, userdetails);
      Map<String, dynamic> jsonData;

      // More robust handling of response data
      if (response.data == null) {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: "Empty response received",
        );
      }

      // Check the actual type and handle accordingly
      if (response.data is String) {
        try {
          jsonData = jsonDecode(response.data);
        } catch (e) {
          return ResponseResult(
            status: ResponseStatus.failed,
            message: "Invalid JSON format",
          );
        }
      } else if (response.data is Map) {
        // Properly cast Map to Map<String, dynamic>
        try {
          jsonData = Map<String, dynamic>.from(response.data as Map);
        } catch (e) {
          return ResponseResult(
            status: ResponseStatus.failed,
            message: "Failed to process map data",
          );
        }
      } else {
        // Convert to string and then parse if it's another type
        try {
          String stringData = response.data.toString();
          jsonData = jsonDecode(stringData);
        } catch (e) {
          return ResponseResult(
            status: ResponseStatus.failed,
            message: "Could not process response",
          );
        }
      }

      // Debug print to check what we're dealing with
      print("Parsed data: $jsonData");

      // Safely access status field, handling potential type issues
      final status = jsonData["status"];
      if (status != null && status.toString().toLowerCase() == "failed") {
        return ResponseResult(
          status: ResponseStatus.failed,
          message: jsonData["message"]?.toString() ?? "Verification failed",
        );
      } else {
        // Safely handle token - ensure it's a string
        String? token = jsonData["token"]?.toString();
        await SharedPreferencesUtil.saveString('auth_token', token ?? "");
        await SharedPreferencesUtil.saveString("isAuthenticated", "true");

        setToken(token);
        await _saveTokenTOPref();

        var user = await userServiceProvider.getUserDetails(context);
        notifyListeners();

        return ResponseResult(
          status: ResponseStatus.success,
          message: jsonData["message"]?.toString() ?? "Verification successful",
        );
      }
    } catch (e) {
      print("error occurred in authenticationprovider: $e");
      return ResponseResult(
        status: ResponseStatus.failed,
        message: "An error occurred",
      );
    }
  }

  Future<void> register(BuildContext context, PreRegisterDetails userDetails) async {
    try {
      Map<String, dynamic> details = userDetails.toJSON();
      final res = await apiService.post(context, "/signup", details, "");

      if (res.statusCode == 200 || res.statusCode == 201) {
        Map<String, dynamic> responseData;

        // Handle different response data types
        if (res.data == null) {
          throw Exception("Empty response received");
        } else if (res.data is String) {
          try {
            responseData = jsonDecode(res.data);
          } catch (e) {
            throw Exception("Invalid JSON format: $e");
          }
        } else if (res.data is Map) {
          try {
            responseData = Map<String, dynamic>.from(res.data as Map);
          } catch (e) {
            throw Exception("Failed to process map data: $e");
          }
        } else {
          try {
            String stringData = res.data.toString();
            responseData = jsonDecode(stringData);
          } catch (e) {
            throw Exception("Could not process response: $e");
          }
        }

        _isAuthenticated = true;

        // Update user from response data
        User.fromJSON(responseData);

        // Save authentication info
        await SharedPreferencesUtil.saveString("auth_token", token ?? "");
        await SharedPreferencesUtil.saveString(
            "isAuthenticated", isAuthenticated.toString());
      }
      notifyListeners();
    } catch (e) {
      print("Error occurred in register: $e");
      // You might want to handle the error or rethrow it
      // throw e;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    SharedPreferencesUtil.saveString('userId', '');
    await _removeToken();
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> _saveTokenTOPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
