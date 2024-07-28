

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

class UserServiceProvider extends ChangeNotifier{
  UserData? userdata ;
  ApiService apiService = ApiService();
UserRepository userRepo  = UserRepository();
  Future<UserData?>  getUserDetails() async{
    try{
      String? token = await SharedPreferencesUtil.getString('auth_token');
      Response response  = await apiService.get("getUserDetails.php", token);
      if (response.statusCode != 200 ){
        throw Exception("status code is  : ${response.statusCode}, henczz error");
      }
      userdata =  UserData.fromJson(jsonDecode(response.data));
      if (userdata != null){
        userRepo.insertUser(userdata!);
        if(userdata?.id !=null){
          UserData? usr = await userRepo.getUserById(userdata!.id);
          print("userrr from database isss ${usr?.email}");
        }
      }else{
        throw Exception("userdata is null ....user_service_provider.dart");
      }

    }catch(e){
      print("errorrr : $e");
    }

    return userdata;
  }


}