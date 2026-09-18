import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/notifications/data/services/notification_service.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_preferences_provider.g.dart';

class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.pushEnabled = true,
    this.isLoading = false,
    this.isSaving = false,
  });

  final bool pushEnabled;
  final bool isLoading;
  final bool isSaving;

  NotificationPreferencesState copyWith({
    bool? pushEnabled,
    bool? isLoading,
    bool? isSaving,
  }) {
    return NotificationPreferencesState(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

@Riverpod(keepAlive: true)
class NotificationPreferences extends _$NotificationPreferences {
  NotificationService get _service => ref.read(notificationServiceProvider);

  @override
  NotificationPreferencesState build() {
    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.authenticated) {
        Future.microtask(load);
      } else if (next.status == SessionStatus.unauthenticated) {
        state = const NotificationPreferencesState();
      }
    });

    final session = ref.watch(sessionProvider);
    if (session.status == SessionStatus.authenticated) {
      Future.microtask(load);
    }

    return const NotificationPreferencesState(isLoading: true);
  }

  Future<void> load() async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      state = const NotificationPreferencesState();
      return;
    }

    state = state.copyWith(isLoading: true);
    final result = await _service.fetchPushEnabled();
    result.fold(
      (_) => state = state.copyWith(isLoading: false),
      (enabled) => state = state.copyWith(
        pushEnabled: enabled,
        isLoading: false,
      ),
    );
  }

  Future<void> setPushEnabled(bool enabled) async {
    final previous = state.pushEnabled;
    state = state.copyWith(pushEnabled: enabled, isSaving: true);

    final result = await _service.setPushEnabled(enabled);
    result.fold(
      (_) => state = state.copyWith(pushEnabled: previous, isSaving: false),
      (value) => state = state.copyWith(pushEnabled: value, isSaving: false),
    );
  }
}
