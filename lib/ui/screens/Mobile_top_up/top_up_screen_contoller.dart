
import 'package:flutter/material.dart';

import '../../widgets/svg_maker/svg_icon.dart';

class TopUpController{

   topUpController(){
     _initialization();
   }

   void _initialization(){}
    SvgIcon getServiceProviderLogo( String serviceProvider){
     String path = "assets/images/${serviceProvider.toLowerCase()}_logo.svg";
     print(path);
     return SvgIcon(path, color: _getColor(serviceProvider),
     );
    }

    Color? _getColor(String providerLogo){
     switch (providerLogo) {
       case "9MOBILE":
         return Colors.green;
         case "GLO":
         return null;
         case "AIRTEL":
         return Colors.red;
         case "MTN":
         return null;}
      return Colors.purple;
    }

}