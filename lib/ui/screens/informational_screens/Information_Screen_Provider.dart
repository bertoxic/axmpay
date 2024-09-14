

import 'dart:convert';

import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/models/other_models.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformationScreenProvider extends ChangeNotifier{

  AxmpayFaqList? axmpayFaqList;
  AxmpayTermsList? axmpayTermsList;
 UserServiceProvider userProvider = UserServiceProvider();
  Future<AxmpayFaqList?> getAxmFAQsList (BuildContext context) async {

  axmpayFaqList = await userProvider.getFAQs(context);

  notifyListeners();
  return axmpayFaqList;
 }
  Future<AxmpayTermsList?> getAxmTermsList (BuildContext context) async {
  axmpayTermsList = await userProvider.getTandC(context);
  notifyListeners();
  return axmpayTermsList;
 }
}