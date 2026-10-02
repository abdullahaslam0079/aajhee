import 'package:aajhee/src/features/auth/data/models/user_model.dart';
import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/settings/data/services/user_profile_service.dart';
import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/utils/failure.dart';
import 'package:aajhee/src/utils/typedefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('profile updates use the injected service', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final fake = _FakeUserProfileService();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWithValue(
          const SessionState(status: SessionStatus.unauthenticated),
        ),
        userProfileServiceProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    container.read(userProfileProvider);
    await pumpEventQueue();

    await expectLater(
      container.read(userProfileProvider.notifier).updateProfile(name: 'Ada'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('nope'),
        ),
      ),
    );
    expect(fake.names, ['Ada']);
  });
}

class _FakeUserProfileService extends UserProfileService {
  final names = <String>[];

  @override
  FutureEither<UserModel> updateProfile({
    required String name,
    String? phone,
  }) async {
    names.add(name);
    return left(const ServerFailure('nope'));
  }
}
