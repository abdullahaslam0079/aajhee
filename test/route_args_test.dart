import 'package:aajhee/src/features/auth/presentation/models/phone_otp_args.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/routing/app_router.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verify OTP without args returns to login', () {
    expect(verifyOtpFallback(null), AppRoutes.login);
    expect(verifyOtpFallback('not-args'), AppRoutes.login);
    expect(
      verifyOtpFallback(
        const PhoneOtpArgs(phoneNumber: '+923001234567', verificationId: 'abc'),
      ),
      isNull,
    );
  });

  test('store route without a branch opens the shell', () {
    expect(businessStoreFallback(null), AppRoutes.bottomNavigator);
    expect(businessStoreFallback('branch'), AppRoutes.bottomNavigator);
    expect(businessStoreFallback(const StoreCatalogArgs()), isNull);
  });

  test('edit address without a saved address opens the list', () {
    expect(editAddressFallback(null), AppRoutes.addresses);
    expect(editAddressFallback(Object()), AppRoutes.addresses);
    expect(
      editAddressFallback(
        const SavedAddress(
          id: '1',
          street: 'Mall Road',
          houseNumber: '12',
          postalCode: '54000',
          city: 'Lahore',
          latitude: 31.5,
          longitude: 74.3,
          formattedAddress: '12 Mall Road, Lahore',
        ),
      ),
      isNull,
    );
  });
}
