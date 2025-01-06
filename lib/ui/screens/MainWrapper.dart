import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
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
    super.initState();
    // Set up error builder for this widget's subtree
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'An error occurred: ${details.exception}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryInitialization,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    };

    _initFuture = _initializeUserDetails();
  }

  Future<void> _initializeUserDetails() async {
    try {
      if (!mounted) return;

      final userProvider = Provider.of<UserServiceProvider>(
          context,
          listen: false
      );

      await userProvider.getUserDetails(context);
      if (!mounted) return;

      await userProvider.getBankNames(context);
      if (!mounted) return;

      await userProvider.getUserDetails(context);
    } catch (error) {
      if (mounted) {
        handleGlobalError(context, error);
      }
      rethrow;
    }
  }

  void _retryInitialization() {
    setState(() {
      _initFuture = _initializeUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: FutureBuilder<void>(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    handleGlobalError(context, snapshot.error);
                  });

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('An error occurred. Please try again.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retryInitialization,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final userProvider = Provider.of<UserServiceProvider>(
                    context,
                    listen: false
                );

                if (userProvider.userdata == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    handleGlobalError(
                        context,
                        'User data is not available. Please try again.'
                    );
                  });

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Please retry loading your data'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retryInitialization,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return widget.navigationShell;
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            child: CustomBottomNavBar(
              items: [
                BottomNavItem(icon: Icons.home),
                BottomNavItem(icon: Icons.send_and_archive_rounded),
                BottomNavItem(icon: Icons.format_align_center),
                BottomNavItem(icon: Icons.person),
              ],
              onItemSelected: (int value) {
                setState(() {
                  goToBranch(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> goToBranch(int index) async {
    try {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
      await _refreshUserDetails(index);
    } catch (error) {
      if (mounted) {
        handleGlobalError(context, error);
      }
    }
  }

  Future<void> _refreshUserDetails(int index) async {
    try {
      final userProvider = Provider.of<UserServiceProvider>(
          context,
          listen: false
      );

      switch(index) {
        case 0:
          await userProvider.getUserDetails(context);
          if (!mounted) return;
          context.goNamed("/home");
          break;
        case 3:
          await userProvider.fetchTransactionHistory(context);
          break;
      }
    } catch (error) {
      if (mounted) {
        handleGlobalError(context, error);
      }
    }
  }
}
