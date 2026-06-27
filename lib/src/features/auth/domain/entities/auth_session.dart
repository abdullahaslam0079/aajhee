import 'package:equatable/equatable.dart';

import 'package:goluto/src/features/auth/domain/entities/user.dart';
import 'package:goluto/src/features/settings/domain/entities/saved_address.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    this.addresses = const [],
  });

  final AppUser user;
  final List<SavedAddress> addresses;

  bool get hasSavedAddress => addresses.isNotEmpty;

  @override
  List<Object?> get props => [user, addresses];
}
