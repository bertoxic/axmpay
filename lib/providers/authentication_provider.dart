import 'dart:convert';

import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/services/api_service.dart';
import 'package:AXMPAY/utils/sharedPrefernce.dart';


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

  //setter function ---------------------------------------------------------------------------->
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }


  Future<ResponseResult?> login(BuildContext context ,LoginDetails userdetails) async {
    UserServiceProvider userServiceProvider = Provider.of(context,listen: false);
    try {
          final response = await authService.login(context,userdetails);
          Map<String, dynamic> jsonData;
          if (response.data is String) {
            jsonData = jsonDecode(response.data);
          } else {
            jsonData = response.data;
          }

          if (jsonData["status"].toString() == "Failed") {

             return ResponseResult(
               status: ResponseStatus.failed,
               message: jsonData["message"] ?? "Verification failed",
               data: null,
             );
           }else{

             String? token = jsonData["token"];
             await SharedPreferencesUtil.saveString('auth_token', token??"");
             await SharedPreferencesUtil.saveString(
                 "isAuthenticated", _isAuthenticated.toString());
             setToken(token);
             await _saveTokenTOPref();
             await userServiceProvider.getUserDetails(context);

           notifyListeners();
           return ResponseResult(
             status: ResponseStatus.success,
             message: jsonData["message"] ?? "Verification successful",
             data: null,
           );
           }
        }catch(e){
          print("error occurred in authenticationprovidder$e");
        }

  }


  Future<void> register(BuildContext context,PreRegisterDetails userDetails) async {
    Map<String, dynamic> details = userDetails.toJSON();
    final res = await apiService.post( context,"/signup", details, "");
    if (res.statusCode == 200 || res.statusCode == 201) {
      _isAuthenticated = true;

      User.fromJSON(res.data);

      await SharedPreferencesUtil.saveString("auth_token", _token ?? "");
      await SharedPreferencesUtil.saveString(
          "isAuthenticated", _isAuthenticated.toString());
    }
    notifyListeners();
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
