import 'package:fintech_app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/utils/sharedPrefernce.dart';


class AuthenticationProvider extends ChangeNotifier {
  String? _token;
  final ApiService apiService;
  final AuthService  authService = AuthService();
  bool _isAuthenticated = false;
  String? _errMessage;
  AuthenticationProvider({required this.apiService});

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  String? get errMessage => _errMessage;

  //setter function ---------------------------------------------------------------------------->
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }


  Future<Map<String, dynamic>?> login(BuildContext context ,LoginDetails userdetails) async {
    Map<String, dynamic>? data;
        try {
           data = await authService.login(context,userdetails);
          String? token = data?["obtainedToken"];
          await SharedPreferencesUtil.saveString('auth_token', token??"");
          await SharedPreferencesUtil.saveString(
              "isAuthenticated", _isAuthenticated.toString());
          setToken(token);
         await _saveTokenTOPref();
         return data;
        }catch(e){
          print("erorr occured in authenticationprovidder$e");
        }
    notifyListeners();
        return data;
  }


  Future<void> register(PreRegisterDetails userDetails) async {
    Map<String, dynamic> details = userDetails.toJSON();
    final res = await apiService.post("/signup", details, "");
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
