import 'package:fpdart/fpdart.dart';

import '../services/internet_connection_service.dart';
import 'error_handler.dart';
import 'failure.dart';
import 'logger.dart';
import 'typedefs.dart';

const _offlineMessage =
    'No internet connection. Please check your connection and try again.';

/// Runs [action] and maps a thrown error to [ServerFailure].
///
/// When [requiresNetwork] is true and the device is offline, [action] is not
/// called and a [NetworkFailure] is returned. Screens decide how to show it.
/// [checkNetwork] is for tests that need a fixed online or offline result.
FutureEither<T> runTask<T>(
  Future<T> Function() action, {
  bool requiresNetwork = false,
  Future<bool> Function()? checkNetwork,
}) async {
  if (requiresNetwork) {
    final hasNetwork =
        await (checkNetwork ?? InternetConnectionService().hasConnection)();

    if (!hasNetwork) {
      AppLogger.warning('Network unavailable for task');
      return left(const NetworkFailure(_offlineMessage));
    }
  }

  try {
    final result = await action();
    return right(result);
  } catch (error, stackTrace) {
    AppLogger.error('Task execution failed $error', error, stackTrace);
    final errorMessage = AppErrorHandler.format(error);
    return left(ServerFailure(errorMessage, error: error));
  }
}
