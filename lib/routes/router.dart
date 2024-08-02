import 'package:fintech_app/ui/screens/MainWrapper.dart';
import 'package:fintech_app/ui/screens/details.dart';
import 'package:fintech_app/ui/screens/transaction_page.dart';
import 'package:fintech_app/ui/screens/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


import '../ui/screens/home_screen.dart';
import '../ui/screens/login_page.dart';
import '../ui/screens/register_page.dart';
import '../ui/screens/profile_page.dart';

final  _rootNavigatorKey = GlobalKey<NavigatorState>();
final  _rootNavigatorHome= GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final  _rootNavigatorSettings= GlobalKey<NavigatorState>(debugLabel: 'shellSetting');
final  _rootNavigatorProfile= GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
final  _rootNavigatorFinance= GlobalKey<NavigatorState>(debugLabel: 'shellFinance');
final  _rootNavigatorTransfer= GlobalKey<NavigatorState>(debugLabel: 'shellTransfer');
final  _rootNavigatorUserProfile= GlobalKey<NavigatorState>(debugLabel: 'shellUserProfile');
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
              initialLocation: "/profile",
              navigatorKey: _rootNavigatorProfile,
              routes: [
                GoRoute(
                  path: '/profile',
                  name: '/profile',
                  builder: (BuildContext context, GoRouterState state) {
                    return   Profile(
                      key: state.pageKey,
                    );

                  },
                ),]),
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


    ]),
    // GoRoute(
    //   path: '/home',
    //   name: '/home',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return   HomePage();
    //   },
    // ),

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