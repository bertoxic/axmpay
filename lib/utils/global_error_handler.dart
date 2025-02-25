import 'package:AXMPAY/providers/Custom_Widget_State_Provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

CustomWidgetStateProvider widgetStateProvider = CustomWidgetStateProvider();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleGlobalError(BuildContext context, dynamic error) {
  if (!widgetStateProvider.dropdownValue) {
    Map<String, dynamic> errorMap = getErrorMessage(error);

    if (error is TokenExpiredException) {
      showReloginDialog(context);
    } else if (error is DioException) {
      showErrorDialog(context, errorMap);
    } else {
      showGeneralErrorDialog(context, error);
    }
  }
}

class TokenExpiredException implements Exception {
  final String? message;
  TokenExpiredException({this.message});
  @override
  String toString() => message ?? 'Token expired';
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => message;
}

void showErrorDialog(BuildContext context, Map<String, dynamic> errorMap) {
  if (!widgetStateProvider.dropdownValue) {
    _showPopup(
      context,
      CustomAlertDialog(
        title: errorMap["title"],
        message: errorMap["message"],
        icon: Icons.error_outline,
      ),
    );
  }
}

void showGeneralErrorDialog(BuildContext context, dynamic error) {
  if (!widgetStateProvider.dropdownValue) {
    _showPopup(
      context,
      CustomAlertDialog(
        title: 'Error',
        message: error.toString(),
        icon: Icons.warning_amber_rounded,
      ),
    );
  }
}

void showReloginDialog(BuildContext context) {
  if (!widgetStateProvider.dropdownValue) {
    _showPopup(
      context,
      CustomAlertDialog(
        title: 'Session Expired',
        message: 'Your session has expired. Please log in again.',
        icon: Icons.login,
        actions: [
          TextButton(
            child: Text('Relogin', style: TextStyle(color: colorScheme.primary)),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              context.goNamed("login");
            },
          ),
          TextButton(
            child: Text('Cancel', style: TextStyle(color: colorScheme.secondary)),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }
}

void _showPopup(BuildContext context, Widget dialog) {
  if (!widgetStateProvider.dropdownValue) {
    widgetStateProvider.setDropdownValue(true);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async {
          widgetStateProvider.setDropdownValue(false);
          return true;
        },
        child: dialog,
      ),
    ).whenComplete(() {
      // Ensure dropdown value is reset when dialog is dismissed
      // This handles ALL dismissal cases
      widgetStateProvider.setDropdownValue(false);
    });
  }
}

Map<String, String> getErrorMessage(dynamic error) {
  String title;
  String message;

  if (error is TokenExpiredException) {
    title = 'Session Expired';
    message = 'Your session has expired. Please log in again.';
  } else if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        title = 'Connection Error';
        message = 'Failed to connect to the server. Please check your internet connection and try again.';
        break;
      case DioExceptionType.connectionTimeout:
        title = 'Connection Timeout';
        message = 'The connection timed out. Please try again later.';
        break;
      case DioExceptionType.receiveTimeout:
        title = 'Timeout';
        message = 'The server took too long to respond. Please try again later.';
        break;
      case DioExceptionType.badResponse:
        title = 'Bad Response';
        message = 'The server returned an unexpected response. Please try again later.';
        break;
      default:
        title = 'Error';
        message = 'An unexpected error occurred. Please try again.';
        break;
    }
  } else {
    title = 'Error';
    message = 'An unexpected error occurred. Please try again.';
  }

  return {'title': title, 'message': message};
}

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<Widget>? actions;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Icon(icon, color: colorScheme.onPrimary),
          ],
        ),
      ),
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onSurface),
      ),
      actions: actions ??
          [
            TextButton(
              child: Text('OK', style: TextStyle(color: colorScheme.primary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
      backgroundColor: colorScheme.surface,
      elevation: 8,
    );
  }
}