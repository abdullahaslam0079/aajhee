import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Count of active orders for the bottom-nav Orders badge.
final activeOrdersBadgeProvider = FutureProvider<int>((ref) async {
  final api = CommerceApiService(DioService.instance);
  final result = await api.getOrders(statusGroup: 'active');
  return result.fold((_) => 0, (orders) => orders.length);
});
