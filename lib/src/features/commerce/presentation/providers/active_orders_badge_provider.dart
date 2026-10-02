import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Count of active orders for the bottom-nav Orders badge.
final activeOrdersBadgeProvider = FutureProvider<int>((ref) async {
  final result = await ref
      .watch(commerceRepositoryProvider)
      .getOrders(statusGroup: 'active');
  return result.fold((_) => 0, (orders) => orders.length);
});
