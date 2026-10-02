import 'package:go_router/go_router.dart';
import 'package:aajhee/src/features/bottomNavigator/presentation/bottom_navigation_bar.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:aajhee/src/features/notifications/presentation/notification_screen.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/features/settings/presentation/screens/add_address_screen.dart';
import 'package:aajhee/src/features/settings/presentation/screens/addresses_screen.dart';
import 'package:aajhee/src/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:aajhee/src/routing/global_navigator.dart';
import 'package:aajhee/src/routing/app_routes.dart';

import 'package:aajhee/src/features/auth/presentation/models/phone_otp_args.dart';
import 'package:aajhee/src/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:aajhee/src/features/auth/presentation/screens/login_screen.dart';
import 'package:aajhee/src/features/auth/presentation/screens/verify_otp_screen.dart';

import 'package:aajhee/src/features/commerce/presentation/screens/cart_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/orders_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';
import 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:aajhee/src/features/splash/presentation/splash_screen.dart';

/// Firebase Phone Auth reCAPTCHA redirects via a custom URL scheme.
/// GoRouter must ignore those callbacks or it shows "Page Not Found".
/// OTP can only continue with the in-memory verification args.
/// A restore or cold link without them goes back to login.
String? verifyOtpFallback(Object? extra) {
  if (extra is PhoneOtpArgs) return null;
  return AppRoutes.login;
}

/// Store details need the branch that was tapped. Without it, open the shell.
String? businessStoreFallback(Object? extra) {
  if (extra is StoreCatalogArgs || extra is MapBranchModel) return null;
  return AppRoutes.bottomNavigator;
}

/// Edit needs the saved address. Without it, open the address list.
String? editAddressFallback(Object? extra) {
  if (extra is SavedAddress) return null;
  return AppRoutes.addresses;
}

bool _isFirebaseAuthCallback(GoRouterState state) {
  final uri = state.uri;
  if (uri.host == 'firebaseauth') return true;
  if (uri.path == '/link' || uri.path.endsWith('/link')) return true;
  if (uri.scheme.contains('googleusercontent')) return true;
  final raw = uri.toString();
  return raw.contains('firebaseauth/link') ||
      raw.contains('/__/auth/callback') ||
      raw.contains('authType=verifyApp');
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  onException: (context, state, router) {
    if (_isFirebaseAuthCallback(state)) {
      // Stay on the current screen; Firebase Auth consumes the callback.
      return;
    }
    // Unknown routes: go back to a safe screen instead of crashing.
    router.go(AppRoutes.login);
  },
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
      redirect: (context, state) => verifyOtpFallback(state.extra),
      builder: (context, state) {
        return VerifyOtpScreen(args: state.extra! as PhoneOtpArgs);
      },
    ),
    GoRoute(
      path: AppRoutes.completeProfile,
      name: 'completeProfile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.bottomNavigator,
      name: 'bottomNavigator',
      builder: (context, state) => const BottomNavigationBarScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeCommerceScreen(),
    ),
    GoRoute(
      path: AppRoutes.cart,
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.orders,
      name: 'orders',
      builder: (context, state) => const OrdersScreen(),
      routes: [
        GoRoute(
          path: ':publicId',
          name: 'orderDetail',
          builder: (context, state) {
            final id = state.pathParameters['publicId']!;
            return OrderDetailScreen(publicId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/products/:id',
      name: 'productDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        final initial =
            extra is Map<String, dynamic> ? extra : null;
        final branchId = state.uri.queryParameters['branch_id'];
        return ProductDetailScreen(
          productId: id,
          initial: initial,
          branchId: branchId != null ? int.tryParse(branchId) : null,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.businessStore,
      name: 'businessStore',
      redirect: (context, state) => businessStoreFallback(state.extra),
      builder: (context, state) {
        final extra = state.extra;
        if (extra is StoreCatalogArgs) {
          return StoreCatalogScreen(args: extra);
        }
        return StoreCatalogScreen(
          args: StoreCatalogArgs.fromBranch(extra! as MapBranchModel),
        );
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
          redirect: (context, state) => editAddressFallback(state.extra),
          builder: (context, state) {
            return AddAddressScreen(
              addressToEdit: state.extra! as SavedAddress,
            );
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
