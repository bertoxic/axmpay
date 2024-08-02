import 'package:fintech_app/main.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ widgets/custom_buttom_navbar.dart';

class MainWrapperPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperPage({super.key, required this.navigationShell});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  late Future<void> _initFuture;
  @override
  void initState() {
    _initFuture = _initializeUserDetails();
    super.initState();
  }

  Future<void>   _initializeUserDetails()async {
      final userprovider =  Provider.of<UserServiceProvider>(context,listen: false);
      final userdat = await userprovider.getUserDetails();
      await userprovider.getBankNames();
      await userprovider.getWalletDetails();
  }
  void goToBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
  void _retryInitialization() {
    setState(() {
      _initFuture = _initializeUserDetails();
    });
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
        child:   FutureBuilder<void>(
    future: _initFuture,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
    );
    } else if (snapshot.hasError) {
      return Scaffold(
        body: Center(child: Text('Error: ${snapshot.error}')),
      );
    } else if (snapshot.connectionState == ConnectionState.done) {
     final  userProvider = Provider.of<UserServiceProvider>(context,listen: false);
      if (userProvider.userdata ==null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Data is null'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }else{
        return widget.navigationShell;
      }

    }else {
    return widget.navigationShell;
    }
    },
    ),

      ),
    );
  }
}
