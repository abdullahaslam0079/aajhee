import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/data/repositories/commerce_repository_impl.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  return CommerceRepositoryImpl(CommerceApiService(DioService.instance));
});
