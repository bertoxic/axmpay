import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

 handleGlobalError(BuildContext context, dynamic error) {
  if (error is TokenExpiredException) {
    showReloginDialog(context);
  }else if(
  error is TimeoutException
  ) {
    showDialog(
      context: navigatorKey.currentContext ?? context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Timeout'),
          content: Text('Timeout. Please check your network connection .${error.toString()}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }else {
    // Handle other types of errors
    showDialog(
      context: navigatorKey.currentContext ?? context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('${error.toString()}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class TokenExpiredException {
  final String? message;
  TokenExpiredException({this.message});
}

void showReloginDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Session Expired'),
        content: Text('Your session has expired. Please log in again.'),
        actions: <Widget>[
          TextButton(
            child: Text('Relogin'),
            onPressed: () {
              // Implement relogin logic here
             // Navigator.of(context).pushReplacementNamed('/login');
              Navigator.of(context).pop();
              context.goNamed("/login");

            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}