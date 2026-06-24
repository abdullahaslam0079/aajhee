import 'dart:async';

import 'package:goluto/src/features/auth/domain/entities/user.dart';
import 'package:goluto/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:goluto/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_provider.g.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState {
  final SessionStatus status;
  final AppUser? user;

  const SessionState({this.status = SessionStatus.unknown, this.user});

  SessionState copyWith({SessionStatus? status, AppUser? user}) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateStream(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.onAuthStateChanged;
}

@Riverpod(keepAlive: true)
class Session extends _$Session {
  StreamSubscription<AppUser?>? _authSub;

  @override
  SessionState build() {
    final repository = ref.read(authRepositoryProvider);

    ref.onDispose(() {
      _authSub?.cancel();
    });

    _initialize(repository);
    return const SessionState();
  }

  Future<void> _initialize(AuthRepository repository) async {
    final result = await repository.checkAuthState();
    result.fold(
      (_) => state = const SessionState(status: SessionStatus.unauthenticated),
      (user) {
        if (user != null) {
          state =
              SessionState(status: SessionStatus.authenticated, user: user);
        } else {
          state = const SessionState(status: SessionStatus.unauthenticated);
        }
      },
    );

    _authSub = repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        state = SessionState(status: SessionStatus.authenticated, user: user);
      } else {
        state = const SessionState(status: SessionStatus.unauthenticated);
      }
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}
