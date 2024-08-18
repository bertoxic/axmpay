import 'package:fintech_app/main.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/global_error_handler.dart';
import '../widgets/custom_buttom_navbar.dart';

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

  Future<void> _initializeUserDetails() async {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
    // try {
      final userData = await userProvider.getUserDetails(context);
      await userProvider.getBankNames(context);
     // await userProvider.getWalletDetails();
    // } catch (e) {
    //   handleGlobalError(context, e);
    // }
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
    // ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //    // handleGlobalError(context, errorDetails.exception);
    //   });
    //
    //   return const Scaffold(
    //     body: Center(
    //       child: Text('An error occurred. Please try again.'),
    //     ),
    //   );
    // };
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
    } else if (snapshot.hasError)
    {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      handleGlobalError(context, snapshot.error);
    }
    );
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text('error: ${snapshot.error} '),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryInitialization,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
