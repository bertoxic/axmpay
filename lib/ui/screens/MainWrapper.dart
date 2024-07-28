import 'package:fintech_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ widgets/custom_buttom_navbar.dart';

class MainWrapperPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperPage({super.key, required this.navigationShell});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {

  void goToBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primaryContainer,
        child:  Icon(Icons.water_drop, color: colorScheme.primary,),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: [
          BottomNavItem(icon: Icons.home, label: "Home"),
          BottomNavItem(icon: Icons.send_and_archive_rounded, label: "transfer"),
          BottomNavItem(icon: Icons.sentiment_dissatisfied, label: "profile"),
          BottomNavItem(icon: Icons.format_align_center, label: "blog"),
        ],
        onItemSelected: (int value) {
          setState(() {
            goToBranch(value);
          });
        },
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: widget.navigationShell,
      ),
    );
  }
}
