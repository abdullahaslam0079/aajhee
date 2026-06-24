import 'package:go_router/go_router.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/bottom_navigation_bar.dart';
import 'package:goluto/src/features/businessStore/presentation/business_store_screen.dart';
import 'package:goluto/src/features/home/presentation/screens/item_detail_screen.dart';
import 'package:goluto/src/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:goluto/src/features/notifications/presentation/notification_screen.dart';
import 'package:goluto/src/features/settings/presentation/screens/add_address_screen.dart';
import 'package:goluto/src/features/settings/presentation/screens/addresses_screen.dart';
import 'package:goluto/src/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:goluto/src/features/offerScanner/presentation/offer_scanner_screen.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';
import 'package:goluto/src/routing/global_navigator.dart';
import 'package:goluto/src/routing/app_routes.dart';

import 'package:goluto/src/features/auth/presentation/screens/login_screen.dart';
import 'package:goluto/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:goluto/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:goluto/src/features/home/presentation/screens/home_page.dart';
import 'package:goluto/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:goluto/src/features/splash/presentation/splash_screen.dart';


final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.bottomNavigator,
      name: 'bottomNavigator',
      builder: (context, state) => const BottomNavigationBarScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.itemDetail,
      name: 'itemDetail',
      builder: (context, state) {
        final item = state.extra is ItemModel
            ? state.extra! as ItemModel
            : dummyBerlinItems.first;
        return ItemDetailScreen(item: item);
      },
    ),
    GoRoute(
      path: AppRoutes.businessStore,
      name: 'businessStore',
      builder: (context, state) => const BusinessStoreScreen(),
    ),
    GoRoute(
      path: AppRoutes.offerScanner,
      name: 'offerScanner',
      builder: (context, state) => const OfferScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.favorites,
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      name: 'addresses',
      builder: (context, state) => const AddressesScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'addAddress',
          builder: (context, state) {
            final isOnboarding =
                state.uri.queryParameters['onboarding'] == 'true';
            return AddAddressScreen(isOnboardingFlow: isOnboarding);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
);
