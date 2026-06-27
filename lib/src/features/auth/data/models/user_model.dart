import 'package:json_annotation/json_annotation.dart';

import 'package:goluto/src/features/auth/domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @JsonKey(fromJson: _idFromJson)
  final String id;
  @JsonKey(fromJson: _emailFromJson)
  final String email;
  final String? name;
  final String? photoUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        name: name,
        photoUrl: photoUrl,
      );

  factory UserModel.fromEntity(AppUser user) => UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        photoUrl: user.photoUrl,
      );

  static String _idFromJson(dynamic value) => value?.toString() ?? '';

  static String _emailFromJson(dynamic value) => value as String? ?? '';
}
