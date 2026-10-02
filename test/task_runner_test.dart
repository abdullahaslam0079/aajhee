import 'package:aajhee/src/utils/failure.dart';
import 'package:aajhee/src/utils/task_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an offline task returns a network failure', () async {
    var ran = false;
    final result = await runTask<int>(
      () async {
        ran = true;
        return 1;
      },
      requiresNetwork: true,
      checkNetwork: () async => false,
    );

    expect(ran, isFalse);
    result.fold(
      (failure) {
        expect(failure, isA<NetworkFailure>());
        expect(
          failure.message,
          'No internet connection. Please check your connection and try again.',
        );
      },
      (_) => fail('expected a network failure'),
    );
  });

  test('a thrown error becomes a server failure', () async {
    final result = await runTask<int>(() async => throw StateError('boom'));

    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, isNotEmpty);
      },
      (_) => fail('expected a server failure'),
    );
  });
}
