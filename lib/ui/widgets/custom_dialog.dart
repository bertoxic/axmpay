import 'package:AXMPAY/main.dart';
import 'package:flutter/material.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';

enum PopupType { info, success, warning, error }

class CustomPopup extends StatelessWidget {
  final String title;
  final String message;
  final PopupType type;
  final List<PopupAction>? actions;
  final bool dismissible;
  final Duration animationDuration;
  final Widget? customIcon;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final Color? backgroundColor;

  const CustomPopup({
    Key? key,
    required this.title,
    required this.message,
    this.type = PopupType.info,
    this.actions,
    this.dismissible = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.customIcon,
    this.titleStyle,
    this.messageStyle,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: 550.sp,
          padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
          margin: EdgeInsets.only(top: 45.h),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: titleStyle ?? Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getIconColor(),
                ),
              ),
              SizedBox(height: 16.h),
              AppText.body(
                message,
                textAlign: TextAlign.center,
                style: messageStyle ?? Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 24.h),
              _buildActionButtons(context),
            ],
          ),
        ),
        Positioned(
          top: 50.h,
          left: 0,
          right: 260.w,
          child: CircleAvatar(
            backgroundColor: _getIconBackgroundColor(),
            radius: 12.sp,
            child: customIcon ?? _getDefaultIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (actions == null || actions!.isEmpty) {
      return SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: actions!.map((action) {
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            action.onPressed();
          },
          style: ElevatedButton.styleFrom(
            primary: action.color ?? _getIconColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            action.text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case PopupType.info:
        return Colors.blue.shade100;
      case PopupType.success:
        return Colors.green.shade100;
      case PopupType.warning:
        return Colors.orange.shade100;
      case PopupType.error:
        return Colors.red.shade100;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case PopupType.info:
        return colorScheme.primary;
      case PopupType.success:
        return Colors.green;
      case PopupType.warning:
        return Colors.orange;
      case PopupType.error:
        return Colors.red;
    }
  }

  Widget _getDefaultIcon() {
    IconData iconData;
    switch (type) {
      case PopupType.info:
        iconData = Icons.info_outline;
        break;
      case PopupType.success:
        iconData = Icons.check_circle_outline;
        break;
      case PopupType.warning:
        iconData = Icons.warning_amber_rounded;
        break;
      case PopupType.error:
        iconData = Icons.error_outline;
        break;
    }
    return Icon(iconData, size: 45.sp, color: _getIconColor());
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    PopupType type = PopupType.info,
    List<PopupAction>? actions,
    bool dismissible = true,
    Duration animationDuration = const Duration(milliseconds: 300),
    Widget? customIcon,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    Color? backgroundColor,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black38,
      transitionDuration: animationDuration,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return CustomPopup(
          title: title,
          message: message,
          type: type,
          actions: actions,
          dismissible: dismissible,
          animationDuration: animationDuration,
          customIcon: customIcon,
          titleStyle: titleStyle,
          messageStyle: messageStyle,
          backgroundColor: backgroundColor,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class PopupAction {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  PopupAction({required this.text, required this.onPressed, this.color});
}