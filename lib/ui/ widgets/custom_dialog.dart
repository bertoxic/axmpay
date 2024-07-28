import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: 500.sp,
          padding: EdgeInsets.only(top: 30.h, bottom: 16.h, left: 16.w, right: 16.w),
          margin: EdgeInsets.only(top: 66.h),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow:  [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0.sp, 10.0.sp),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w,vertical: 10.h),
                        child: Center(
                          child: Text(
                            title,
                            style: titleStyle ?? Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0.sp),
              AppText.caption(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              _buildActionButtons(context),
            ],
          ),
        ),
        Positioned(
          top: 16.h,
          left: 16.w,
          right: 16.w,
          child: CircleAvatar(
            backgroundColor: _getIconBackgroundColor(),
            radius: 36.sp,
            child: customIcon ?? _getDefaultIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions!.map((action) {
        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: 4.0.w),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
            child: Text(action.text),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
              ),
              backgroundColor: action.color ?? Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case PopupType.info:
        return Colors.blue;
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
    return Icon(iconData, size: 30.sp, color: Colors.white);
  }

  static Future<Future<Object?>> show({
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
  }) async {
    return showGeneralDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black38,
      transitionDuration: animationDuration,
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
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