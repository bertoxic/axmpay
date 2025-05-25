import 'dart:convert';

import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/ui/screens/MainWrapper.dart';
import 'package:AXMPAY/ui/screens/Mobile_top_up/top_up_screen.dart';
import 'package:AXMPAY/ui/screens/contact_us_page.dart';
import 'package:AXMPAY/ui/screens/informational_screens/frequently_asked_questions.dart';
import 'package:AXMPAY/ui/screens/informational_screens/privacy_policy_screen.dart';
import 'package:AXMPAY/ui/screens/informational_screens/terms_and_conditions.dart';
import 'package:AXMPAY/ui/screens/registration/verify_newUser_email_otp_screen.dart';
import 'package:AXMPAY/ui/screens/registration/update_user_details_page.dart';
import 'package:AXMPAY/ui/screens/forgot_password/input_Email_Recovery_screen.dart';
import 'package:AXMPAY/ui/screens/forgot_password/token_verification_screen.dart';
import 'package:AXMPAY/ui/screens/transaction_screen/transaction_history.dart';
import 'package:AXMPAY/ui/screens/transaction_screen/transaction_page.dart';
import 'package:AXMPAY/ui/screens/profile/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


import '../models/transaction_model.dart';
import '../ui/screens/passcode_screen/passcode_screen.dart';
import '../ui/screens/passcode_screen/passcode_set_up.dart';
import '../ui/screens/splash_screen/splash_screen.dart';
import '../ui/screens/transaction_screen/detailed_transaction_page.dart';
import '../ui/screens/forgot_password/change_password_screen.dart';
import '../ui/screens/homeScreen/home_screen.dart';
import '../ui/screens/login_page.dart';
import '../ui/screens/registration/register_page.dart';
import '../ui/screens/settings_page.dart';
import '../ui/screens/transaction_screen/success_receipt_screen.dart';
import '../ui/screens/upgrade_account/upgrade_account_form.dart';

final  _rootNavigatorKey = GlobalKey<NavigatorState>();
final  _rootNavigatorHome= GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final  _rootNavigatorSettings= GlobalKey<NavigatorState>(debugLabel: 'shellSetting');
final  _rootNavigatorProfile= GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
final  _rootNavigatorFinance= GlobalKey<NavigatorState>(debugLabel: 'shellFinance');
final  _rootNavigatorTransfer= GlobalKey<NavigatorState>(debugLabel: 'shellTransfer');
final  _rootNavigatorUserProfile= GlobalKey<NavigatorState>(debugLabel: 'shellUserProfile');
final  _rootNavigatorTransactionHistory= GlobalKey<NavigatorState>(debugLabel: 'shellUserTransactionHistory');
final GoRouter  _router = GoRouter(
  initialLocation: '/splash_screen',
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
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
              name: 'home',
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
          navigatorKey: _rootNavigatorTransactionHistory,
          initialLocation: "/transaction_history_page",
          routes: [
            GoRoute(
              path: '/transaction_history_page',
              name: '/transaction_history_page',
              builder: (BuildContext context, GoRouterState state) {
                return   TransactionHistoryPage(
                  key: state.pageKey,
                );

              },
            )

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
          // StatefulShellBranch(
          //     initialLocation: "/settings",
          //     navigatorKey: _rootNavigatorProfile,
          //     routes: [
          //       GoRoute(
          //         path: '/settings',
          //         name: '/settings',
          //         builder: (BuildContext context, GoRouterState state) {
          //           return   SettingsPage(
          //             key: state.pageKey,
          //           );
          //
          //         },
          //       ),]),


    ]),
    // GoRoute(
    //   path: '/home',
    //   name: 'home',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return   HomePage();
    //   },
    // ),
    // GoRoute(
    //   path: '/transaction_history_page',
    //   name: '/transaction_history_page',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return   TransactionHistoryPage(
    //       key: state.pageKey,
    //     );
    //
    //   },
    // ),
    GoRoute(
      path: '/upgrade_account_page',
      name: 'upgrade_account_page',
      builder: (BuildContext context, GoRouterState state) {
        return   UpgradeAccountPage(
          key: state.pageKey,
        );

      },
    ),
    GoRoute(
      path: '/splash_screen',
      name: 'splash_screen',
      builder: (BuildContext context, GoRouterState state) {
        return   FustPaySplashScreen();

      },
    ),
    GoRoute(
      path: '/user_details_page',
      name: 'user_details_page',
      builder: (BuildContext context, GoRouterState state) {
        return   UpdateUserDetailsPage(
          key: state.pageKey,
        );
      },
    ),
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
      path: '/verify_new_user_email_screen/:preRegistrationString',
      name: 'verify_new_user_email_screen',
      builder: (BuildContext context, GoRouterState state) {
        final String? jsonString = state.pathParameters["preRegistrationString"];
        final PreRegisterDetails? details = jsonString != null
            ? PreRegisterDetails.fromJSON(jsonDecode(jsonString))
            : null;
        return  NewUserOTPVerificationScreen(preRegisterDetails: details!,);
      },
    ),

    GoRoute(
      path: '/forgot_password_otp/:email',
      name: '/forgot_password_otp',
      builder: (BuildContext context, GoRouterState state) {
        final String? email = state.pathParameters["email"];
        return   OTPVerificationScreen(email: email??"",);
      },
    ),
    GoRoute(
      path: '/change_password_screen/:email/:otp',
      name: 'change_password_screen',
      builder: (BuildContext context, GoRouterState state) {
        final String? otp = state.pathParameters['otp'];
        final String? email = state.pathParameters['email'];
        return   ChangePasswordScreen(email: email!, otp: otp!,);
      },
    ),
    GoRoute(
      path: '/top_up_success',
      name: 'top_up_success',
      builder: (BuildContext context, GoRouterState state) {
        final ReceiptData? receiptData = state.extra as ReceiptData?;
        return TopUpSuccessScreen(receiptData: receiptData);
      },
    ),
    GoRoute(
      path: '/mobile_top_up',
      name: 'top_up',
      builder: (BuildContext context, GoRouterState state) {
        return MobileTopUp();
      },
    ),  GoRoute(
      path: '/passcode_input_screen',
      name: 'passcode_input_screen',
      builder: (BuildContext context, GoRouterState state) {
        return PasscodeInputScreen();
      },
    ),
    GoRoute(
      path: '/passcode_setup_screen/:email',
      name: 'passcode_setup_screen',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.pathParameters['email'];
        return PasscodeSetupScreen(email: email!);
      },
    ),

    GoRoute(
      path: '/forgot_password_input_mail',
      name: 'forgot_password_input_mail',
      builder: (BuildContext context, GoRouterState state) {
        return    const InputEmailRecovery();
      },
    ),

    GoRoute(
      path: '/earnings_dashboard',
      name: 'earnings_dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return  FAQs();
      },
    ),

    GoRoute(
      path: '/frequently_asked_questions',
      name: 'frequently_asked_questions',
      builder: (BuildContext context, GoRouterState state) {
        return  FAQs();
      },
    ),

    GoRoute(
      path: '/terms_and_conditions',
      name: 'terms_and_conditions',
      builder: (BuildContext context, GoRouterState state) {
        return  TermsAndConditions();
      },
    ),
    GoRoute(
      path: '/privacy_policy',
      name: 'privacy_policy',
      builder: (BuildContext context, GoRouterState state) {
        return  PrivacyPolicyScreen();
      },
    ),

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) {
        return   LoginPage();
      },
    ),

    GoRoute(
      path: '/contact_us',
      name: 'contact_us',
      builder: (BuildContext context, GoRouterState state) {
        return   ContactPage();
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