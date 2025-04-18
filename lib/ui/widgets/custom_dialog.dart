import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/Custom_Widget_State_Provider.dart';

enum PopupType { info, success, warning, error }
class PopupAction {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  PopupAction({required this.text, required this.onPressed, this.color});
}
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
          width: 550,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: titleStyle ??
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getIconColor(),
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: messageStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 260,
          child: CircleAvatar(
            backgroundColor: _getIconBackgroundColor(),
            radius: 12,
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

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: actions!.map((action) {
        return ElevatedButton(
          onPressed: () {
            // Reset the state when popup is dismissed via button
            Provider.of<CustomWidgetStateProvider>(context, listen: false)
                .setDropdownValue(false);
            Navigator.of(context).pop();
            action.onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: action?.color ?? _getIconColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            action.text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return Icon(iconData, size: 45, color: _getIconColor());
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
    // Get the state provider
    final stateProvider = Provider.of<CustomWidgetStateProvider>(context, listen: false);

    // Check if a popup is already showing
    if (stateProvider.dropdownValue) {
      return Future.value(null); // Return null if a popup is already visible
    }

    // Set the state to show popup
    stateProvider.setDropdownValue(true);

    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) {
        return PopScope(  // Use PopScope to handle dismissal
          canPop: dismissible,
          onPopInvoked: (didPop) {
            if (didPop) {
              // Reset the state when popup is dismissed
              stateProvider.setDropdownValue(false);
            }
          },
          child: CustomPopup(
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
          ),
        );
      },
    ).then((value) {
      // Ensure state is reset even if dismissed through other means
      stateProvider.setDropdownValue(false);
      return value;
    });
  }
  }