import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/features/auth/data/models/user_model.dart';
import 'package:aajhee/src/utils/utils.dart';

class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  Dio get _dio => AppConfig.dio;

  FutureEither<UserModel> fetchProfile() async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/user/profile',
      );
      return UserModel.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<UserModel> updateProfile({required String name}) async {
    return runTask(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/user/profile',
        data: {'name': name.trim()},
      );
      return UserModel.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }
}
