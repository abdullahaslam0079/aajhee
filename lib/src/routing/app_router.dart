import 'package:go_router/go_router.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/bottom_navigation_bar.dart';
import 'package:goluto/src/features/businessStore/presentation/business_store_screen.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:goluto/src/features/notifications/presentation/notification_screen.dart';
import 'package:goluto/src/features/settings/domain/entities/saved_address.dart';
import 'package:goluto/src/features/settings/presentation/screens/add_address_screen.dart';
import 'package:goluto/src/features/settings/presentation/screens/addresses_screen.dart';
import 'package:goluto/src/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:goluto/src/features/offerScanner/presentation/offer_scanner_screen.dart';
import 'package:goluto/src/routing/global_navigator.dart';
import 'package:goluto/src/routing/app_routes.dart';

import 'package:goluto/src/features/auth/presentation/screens/login_screen.dart';
import 'package:goluto/src/features/auth/presentation/screens/verify_otp_screen.dart';

import 'package:goluto/src/features/offers/presentation/screens/home_offers_screen.dart';
import 'package:goluto/src/features/offers/presentation/screens/top_picks_screen.dart';
import 'package:goluto/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:goluto/src/features/searchOffers/presentation/screens/search_offers_screen.dart';
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
      path: AppRoutes.verifyOtp,
      name: 'verifyOtp',
      builder: (context, state) {
        final args = state.extra;
        if (args is! PhoneOtpArgs) {
          throw StateError('VerifyOtpScreen requires PhoneOtpArgs extra.');
        }
        return VerifyOtpScreen(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.bottomNavigator,
      name: 'bottomNavigator',
      builder: (context, state) => const BottomNavigationBarScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeOffersScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessStore,
      name: 'businessStore',
      builder: (context, state) {
        final branch = state.extra is MapBranchModel
            ? state.extra! as MapBranchModel
            : null;
        if (branch == null) {
          throw StateError('BusinessStoreScreen requires a MapBranchModel extra.');
        }
        return BusinessStoreScreen(branch: branch);
      },
    ),
    GoRoute(
      path: AppRoutes.offerScanner,
      name: 'offerScanner',
      builder: (context, state) {
        if (state.extra is OfferScannerSession) {
          final session = state.extra! as OfferScannerSession;
          return OfferScannerScreen(
            offer: session.offer,
            branchId: session.branchId,
            navigateToBranchOnSuccess: session.navigateToBranchOnSuccess,
          );
        }

        final offer =
            state.extra is OfferModel ? state.extra! as OfferModel : null;
        return OfferScannerScreen(offer: offer);
      },
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
      path: AppRoutes.searchOffers,
      name: 'searchOffers',
      builder: (context, state) => const SearchOffersScreen(),
    ),
    GoRoute(
      path: AppRoutes.topPicks,
      name: 'topPicks',
      builder: (context, state) => const TopPicksScreen(),
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
        GoRoute(
          path: 'edit',
          name: 'editAddress',
          builder: (context, state) {
            final address = state.extra as SavedAddress?;
            return AddAddressScreen(addressToEdit: address);
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
