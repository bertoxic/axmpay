  import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
    const UserProfileScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return  Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 30, left: 0,
            child: Container(
              height: 400.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade700
              ),
              child: Text("obey"),
            ),
          ),
          Positioned(
            top: 400.h, left: 0,
            child: Container(
              height: 400.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200
              ),
              child: Text("helo"),
            ),
          )
        ],
      );
    }
  }
