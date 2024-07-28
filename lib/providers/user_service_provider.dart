

  import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fintech_app/providers/authentication_provider.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/utils/sharedPrefernce.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class UserServiceProvider extends ChangeNotifier{
  UserData? userdata ;
  ApiService apiService = ApiService();
  Future<UserData?>  getUserDetails() async{
    try{
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response  = await apiService.get("getUserDetails.php", token);
      if (response.statusCode != 200 ){
        throw Exception("status code is  : ${response.statusCode}, henczz error");
      }
      userdata =  UserData.fromJson(jsonDecode(response.data));
    }catch(e){
      print("errorrr : $e");
    }

    return userdata;
  }


}