import 'package:AXMPAY/models/other_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Information_Screen_Provider.dart';

class InformationScreenController {
  BuildContext context;
  late InformationScreenProvider informationScreenProvider;
  AxmpayFaqList? axmpayFaqList;
  AxmpayTermsList? axmpayTermsList;
  InformationScreenController(this.context) {
    _initializeController();
  }

  _initializeController() {
    getAxmList();
  }

  Future<AxmpayFaqList?> getAxmList() async {
    informationScreenProvider = Provider.of(context, listen: false);
    axmpayFaqList = await informationScreenProvider.getAxmFAQsList(context);
    return axmpayFaqList;
  }
  Future<AxmpayTermsList?> getAxmTermsList() async {
    informationScreenProvider = Provider.of(context, listen: false);
    axmpayTermsList = await informationScreenProvider.getAxmTermsList(context);
    return axmpayTermsList;

    return null;
  }
}
