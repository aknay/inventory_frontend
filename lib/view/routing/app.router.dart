import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/onboarding.service.dart';
import 'package:inventory_frontend/view/auth/custom.sign.in.screen.dart';
import 'package:inventory_frontend/view/items/add.item.screen.dart';
import 'package:inventory_frontend/view/items/items.screen.dart';
import 'package:inventory_frontend/view/main/main.screen.dart';
import 'package:inventory_frontend/view/onboarding/onboarding.error.screen.dart';
import 'package:inventory_frontend/view/onboarding/onboarding.screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app.router.g.dart';

enum AppRoute { items, signIn, main, addItem, onboarding, onboardingError }

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    initialLocation: '/sign_in',
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) async {
      final path = state.uri.path;
      log("path is $path");
      final isLoggedIn = authRepository.isUserLoggedIn;
      if (isLoggedIn) {
        if (path.startsWith('/sign_in')) {
          return '/main';
        }
      }

      if (path.startsWith('/main')) {
        //we need to guard otherwise it will call after '\main'
        final onboardingService = ref.watch(onboardingServiceProvider);
        final teamIdEmptyOrTeamListOrError = await onboardingService.isOnboardingCompleted;

        if (teamIdEmptyOrTeamListOrError.isLeft()) {
          return '/error';
        }
        final teamIdEmptyOrTeamList = teamIdEmptyOrTeamListOrError.toIterable().first;

        if (teamIdEmptyOrTeamList.isNone()) {
          if (path != '/onboarding') {
            return '/onboarding';
          }
        }
      }

      // no need to redirect at all
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        name: AppRoute.signIn.name,
        path: '/sign_in',
        builder: (BuildContext context, GoRouterState state) {
          return const CustomSignInScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) =>  NoTransitionPage(child: OnboardingScreen()
            // child: OnboardingScreen(),
            ),
        // routes: <RouteBase>[
        //   // GoRoute(
        //   //   name: AppRoute.onboardingError.name,
        //   //   path: 'error',
        //   //   builder: (context, state) => const OnboardingErrorScreen(),
        //   // ),
        // ]
      ),
      GoRoute(
        name: AppRoute.onboardingError.name,
        path: '/error',
        builder: (context, state) => const OnboardingErrorScreen(),
      ),
      GoRoute(
        name: AppRoute.main.name,
        path: '/main',
        builder: (BuildContext context, GoRouterState state) {
          return const MainScreen();
        },
      ),
      GoRoute(
          name: AppRoute.items.name,
          path: '/items',
          builder: (BuildContext context, GoRouterState state) {
            return const ItemsScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              name: AppRoute.addItem.name,
              path: 'add',
              builder: (context, state) => const AddItemScreen(),
            ),
          ]),
    ],
  );
}
