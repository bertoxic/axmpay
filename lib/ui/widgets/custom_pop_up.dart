import 'package:flutter/material.dart';
import 'package:AXMPAY/providers/Custom_Widget_State_Provider.dart';

class ScrollablePopup extends StatelessWidget {
  final Widget child;
  final bool isDismissible;
  final double maxWidth;
  final double maxHeight;
  final double borderRadius;
  final CustomWidgetStateProvider widgetStateProvider;

  const ScrollablePopup({
    super.key,
    required this.child,
    required this.widgetStateProvider,
    this.isDismissible = true,
    this.maxWidth = 0.8,
    this.maxHeight = 0.8,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widgetStateProvider.setDropdownValue(false);
        return true;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            if (isDismissible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    widgetStateProvider.setDropdownValue(false);
                    Navigator.of(context).pop();
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from propagating to background
                child: Container(
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
                      buildDragHandle(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDragHandle() {
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
    required CustomWidgetStateProvider widgetStateProvider,
    bool isDismissible = true,
    double maxWidth = 0.8,
    double maxHeight = 0.8,
    double borderRadius = 12.0,
  }) {

    // Only show if no popup is currently displayed
    if (!widgetStateProvider.dropdownValue) {
      widgetStateProvider.setDropdownValue(true);

      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          return ScrollablePopup(
            isDismissible: isDismissible,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            borderRadius: borderRadius,
            widgetStateProvider: widgetStateProvider,
            child: child,
          );
        },
      ).whenComplete(() {
        // Ensure dropdown value is reset when dialog is dismissed
        // This handles ALL dismissal cases including:
        // - Back button
        // - Outside tap
        // - Navigator.pop()
        // - Any other dismissal method
        widgetStateProvider.setDropdownValue(false);
      });
    }
    return Future.value(null);
  }
}