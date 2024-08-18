import 'package:flutter/material.dart';
import 'dart:math' as math;

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double refHeight;
  static late double refWidth;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    refHeight = 812;
    refWidth = 375;

    if (screenHeight < 1200) {
      blockSizeHorizontal = screenWidth / 100;
      blockSizeVertical = screenHeight / 100;

      _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
      safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
      safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    } else {
      blockSizeHorizontal = screenWidth / 120;
      blockSizeVertical = screenHeight / 120;

      _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
      safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 120;
      safeBlockVertical = (screenHeight - _safeAreaVertical) / 120;
    }
  }

  static double getWidthRatio(double val) {
    double res = (val / refWidth) * 100;
    double temp = res * blockSizeHorizontal;
    return temp;
  }

  static double getHeightRatio(double val) {
    double res = (val / refHeight) * 100;
    double temp = res * blockSizeVertical;
    return temp;
  }

  static double getAdaptiveTextSize(double value) {
    double scaleFactor = math.min(screenWidth / refWidth, screenHeight / refHeight);
    return value * scaleFactor;
  }
}

class W {
  static double get(double val) => SizeConfig.getWidthRatio(val);
}

class H {
  static double get(double val) => SizeConfig.getHeightRatio(val);
}

class SP {
  static double get(double val) => SizeConfig.getAdaptiveTextSize(val);
}

extension SizeExtension on num {
  double get w => W.get(this.toDouble());
  double get h => H.get(this.toDouble());
  double get sp => SP.get(this.toDouble());
}