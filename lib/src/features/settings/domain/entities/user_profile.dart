import 'package:equatable/equatable.dart';

import 'package:aajhee/src/features/auth/domain/entities/user.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.email,
    this.phone,
  });

  final String name;
  final String email;
  final String? phone;

  static const empty = UserProfile(
    name: '',
    email: '',
  );

  String get displayName {
    if (name.isNotEmpty) return name;
    if (phone != null && phone!.isNotEmpty) return phone!;
    if (email.isNotEmpty && !email.endsWith('@phone.aajhee.local')) {
      return email.split('@').first;
    }
    return 'Your profile';
  }

  factory UserProfile.fromAppUser(AppUser user) {
    return UserProfile(
      name: user.name?.trim() ?? '',
      email: user.email,
      phone: user.phone,
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final storedName = json['name'] as String?;
    if (storedName != null) {
      return UserProfile(
        name: storedName,
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
      );
    }

    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final parts = [firstName.trim(), lastName.trim()]
        .where((part) => part.isNotEmpty);

    return UserProfile(
      name: parts.join(' '),
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, email, phone];
}
