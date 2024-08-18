import 'package:fintech_app/ui/screens/MainWrapper.dart';
import 'package:fintech_app/ui/screens/details.dart';
import 'package:fintech_app/ui/screens/forgot_password/input_password_screen.dart';
import 'package:fintech_app/ui/screens/forgot_password/token_verification_screen.dart';
import 'package:fintech_app/ui/screens/transaction_history.dart';
import 'package:fintech_app/ui/screens/transaction_page.dart';
import 'package:fintech_app/ui/screens/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


import '../models/user_model.dart';
import '../ui/screens/detailed_transaction_page.dart';
import '../ui/screens/forgot_password/change_password_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_page.dart';
import '../ui/screens/register_page.dart';
import '../ui/screens/settings_page.dart';

final  _rootNavigatorKey = GlobalKey<NavigatorState>();
final  _rootNavigatorHome= GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final  _rootNavigatorSettings= GlobalKey<NavigatorState>(debugLabel: 'shellSetting');
final  _rootNavigatorProfile= GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
final  _rootNavigatorFinance= GlobalKey<NavigatorState>(debugLabel: 'shellFinance');
final  _rootNavigatorTransfer= GlobalKey<NavigatorState>(debugLabel: 'shellTransfer');
final  _rootNavigatorUserProfile= GlobalKey<NavigatorState>(debugLabel: 'shellUserProfile');
final  _rootNavigatorTransactionHistory= GlobalKey<NavigatorState>(debugLabel: 'shellUserTransactionHistory');
final GoRouter  _router = GoRouter(
  initialLocation: '/register',
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (BuildContext context, GoRouterState state) {
        return RegisterPage();
      },
    ),
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell ){
          return MainWrapperPage(navigationShell: navigationShell,);
        },

        branches:  <StatefulShellBranch>[
      StatefulShellBranch(
          navigatorKey: _rootNavigatorHome,
          initialLocation: "/home",
          routes: [
            GoRoute(
              path: '/home',
              name: '/home',
              builder: (BuildContext context, GoRouterState state) {
                return   HomePage(
                  key: state.pageKey,
                );

              },
            ),

      ]),
          StatefulShellBranch(
              navigatorKey: _rootNavigatorTransfer,
              initialLocation: "/transferPage",
              routes: [
                GoRoute(
                  path: '/transferPage',
                  name: '/transferPage',
                  builder: (BuildContext context, GoRouterState state) {
                    return   TransferScreen(
                      key: state.pageKey,
                    );
                  },
                ),

              ]),

          StatefulShellBranch(
              navigatorKey: _rootNavigatorUserProfile,
              initialLocation: "/user_profile_page",
              routes: [
                GoRoute(
                  path: '/user_profile_page',
                  name: '/user_profile_page',
                  builder: (BuildContext context, GoRouterState state) {
                    return   UserProfileScreen(
                      key: state.pageKey,
                    );
                  },
                ),

              ]),
      StatefulShellBranch(
          navigatorKey: _rootNavigatorSettings,
          initialLocation: "/user_details_page",
          routes: [
            GoRoute(
              path: '/user_details_page',
              name: '/user_details_page',
              builder: (BuildContext context, GoRouterState state) {
                return   DetailsPage(
                  key: state.pageKey,
                );
              },
            ),

      ]),

          StatefulShellBranch(
              initialLocation: "/settings",
              navigatorKey: _rootNavigatorProfile,
              routes: [
                GoRoute(
                  path: '/settings',
                  name: '/settings',
                  builder: (BuildContext context, GoRouterState state) {
                    return   SettingsPage(
                      key: state.pageKey,
                    );

                  },
                ),]),
          StatefulShellBranch(
              initialLocation: "/transaction_history_page",
              navigatorKey: _rootNavigatorTransactionHistory,
              routes: [
                GoRoute(
                  path: '/transaction_history_page',
                  name: '/transaction_history_page',
                  builder: (BuildContext context, GoRouterState state) {
                    return   TransactionHistoryPage(
                      key: state.pageKey,
                    );

                  },
                ),]),

    ]),
    // GoRoute(
    //   path: '/home',
    //   name: '/home',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return   HomePage();
    //   },
    // ),
    GoRoute(
      path: '/transaction_details/:trxID',
      name: 'transaction_details',
      builder: (BuildContext context, GoRouterState state) {
        final SpecificTransactionData? transaction = state.extra as SpecificTransactionData?;
        return TransactionDetailScreen(
          key: state.pageKey,
          transaction: transaction!,
        );
      },
    ),

    GoRoute(
      path: '/forgot_password_otp',
      name: '/forgot_password_otp',
      builder: (BuildContext context, GoRouterState state) {
        return   OTPVerificationScreen();
      },
    ),
    GoRoute(
      path: '/change_password_screen',
      name: '/change_password_screen',
      builder: (BuildContext context, GoRouterState state) {
        return   ChangePasswordScreen();
      },
    ),

    GoRoute(
      path: '/forgot_password_input_mail',
      name: '/forgot_password_input_mail',
      builder: (BuildContext context, GoRouterState state) {
        return    InputEmailRecovery();
      },
    ),

    GoRoute(
      path: '/login',
      name: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return   LoginPage();
      },
    ),
    // GoRoute(
    //   path: '/user_details_page',
    //   name: '/user_details_page',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return   DetailsPage();
    //   },
    // ),
  ],
);

get route {
  return _router;
}