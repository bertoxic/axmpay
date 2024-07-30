import 'dart:math';

import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';

class ScrollablePopup extends StatelessWidget {
  final Widget child;
  final bool isDismissible;
  final double maxWidth;
  final double maxHeight;
  final double borderRadius;

  const ScrollablePopup({
    Key? key,
    required this.child,
    this.isDismissible = true,
    this.maxWidth = 0.8,
    this.maxHeight = 0.8,
    this.borderRadius = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child:  Stack(
          children: [
          // This GestureDetector covers the full screen and dismisses the popup when tapped
          if (isDismissible)
        Positioned.fill(
    child: GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Container(color: Colors.transparent),
    ),
    ),
    Center(
        child: GestureDetector(
          onTap: () {
           Navigator.pop(context); //dismiss when tapped
          }, // Prevents taps inside from dismissing
          child: Container(
            // width: 300,
            // height: 300,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * maxWidth,
              maxHeight: MediaQuery.of(context).size.height * maxHeight,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),])
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    double maxWidth = 0.8,
    double maxHeight = 0.8,
    double borderRadius = 12.0,
  }) {
    return showDialog<T>(

      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return ScrollablePopup(
          child: child,
          isDismissible: isDismissible,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          borderRadius: borderRadius,
        );
      },
    );
  }
}


  // Method to get a random color from the list

