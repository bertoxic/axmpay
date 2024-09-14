import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';

import 'global_error_handler.dart';

class GlobalErrorHandler extends StatelessWidget {
  final Widget child;

  const GlobalErrorHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         handleGlobalError(context, errorDetails.exception);
      });
      return Scaffold(
        body: Center(
          child: Container( height: 800.h, width:  double.maxFinite,
              color: Colors.red,
              child: Text('An error occurred. Please try again.${errorDetails.exception.toString()}')),
        ),
      );
    };
    return child;
  }
}