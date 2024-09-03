import 'package:flutter/material.dart';

class AppTextTheme {
  static const String _fontFamily = 'Roboto';

  static TextStyle _baseTextStyle(double fontSize, FontWeight fontWeight, {Color? color, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black,
      height: height,
    );
  }

  static TextStyle display({Color? color}) => _baseTextStyle(24, FontWeight.bold, color: color, height: 1.2);
  static TextStyle headline({Color? color}) => _baseTextStyle(32, FontWeight.bold, color: color, height: 1.3);
  static TextStyle title({Color? color}) => _baseTextStyle(18, FontWeight.w600, color: color, height: 1.4);
  static TextStyle subtitle({Color? color}) => _baseTextStyle(16, FontWeight.w500, color: color, height: 1.5);
  static TextStyle body({Color? color}) => _baseTextStyle(14, FontWeight.normal, color: color, height: 1.5);
  static TextStyle caption({Color? color}) => _baseTextStyle(12, FontWeight.w400, color: color, height: 1.4);
  static TextStyle overline({Color? color}) => _baseTextStyle(12, FontWeight.w300, color: color, height: 1.3);
}

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText._({
    required this.text,
     this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory AppText.display(String text, {Color? color, TextStyle? style, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style?? AppTextTheme.display(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.headline(String text, {Color? color, TextStyle? style, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style?? AppTextTheme.headline(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.title(String text, {Color? color, TextStyle? style, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style??  AppTextTheme.title(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.subtitle(String text, {Color? color,TextStyle? style,  TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style??  AppTextTheme.subtitle(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.body(String text, {Color? color, TextStyle? style, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style?? AppTextTheme.body(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.caption(String text, {Color? color, TextStyle? style, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style??  AppTextTheme.caption(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.overline(String text, {Color? color,TextStyle? style,  TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText._(
      text: text,
      style:style??  AppTextTheme.overline(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

//192.168.1.86