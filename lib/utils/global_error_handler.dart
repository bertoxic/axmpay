import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

bool _showingErrorDialog = false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void handleGlobalError(BuildContext context, dynamic error) {
  if (!_showingErrorDialog) {
    _showingErrorDialog = true;

    if (error is TokenExpiredException) {

      showReloginDialog(context);
    } else if (error.type == DioExceptionType.connectionError) {
      showConnectionErrorDialog(context);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      showConnectionErrorDialog(context);
    }else if (error.type == DioExceptionType.receiveTimeout) {
      showConnectionErrorDialog(context);
    } else if (error.type == DioExceptionType.badResponse) {
      showConnectionErrorDialog(context);
    } else {
      showGeneralErrorDialog(context, error);
    }

    // Reset the flag after the dialog is dismissed
    Future.delayed(Duration.zero, () {
      _showingErrorDialog = false;
    });
  }
}

class TokenExpiredException implements Exception {
  final String? message;

  TokenExpiredException({this.message});

  @override
  String toString() {
    return message ?? 'Token expired';
  }
}
void showConnectionErrorDialog(BuildContext context) {
  showDialog(
    context: navigatorKey.currentContext ?? context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.primary.withOpacity(0.3),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Timeout'),
                Icon(Icons.info_outlined, color: colorScheme.primaryContainer,)
              ],
            )),
        content: const Text('Timeout. Please check your network connection'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showGeneralErrorDialog(BuildContext context, dynamic error) {
  showDialog(
    context: navigatorKey.currentContext ?? context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.primary.withOpacity(0.3),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Error'),
                Icon(Icons.info_outlined, color: colorScheme.primaryContainer,)
              ],
            )),
        content: Text(error.toString()),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
void showReloginDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
    return AlertDialog(
      title:Container(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.primary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Session Expired'),
            Icon(Icons.info_outlined, color: colorScheme.primaryContainer,)

          ],
        ),
      ),
      content: const Text('Your session has expired. Please log in again.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Relogin'),
          onPressed: () {
            // Implement relogin logic here
            // Navigator.of(context).pushReplacementNamed('/login');
            Navigator.of(context).pop();
            context.goNamed("/login");

          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }, );
  }
