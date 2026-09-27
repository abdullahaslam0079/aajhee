import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:aajhee/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

class CartState {
  const CartState({
    this.items = const [],
    this.subtotal,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  final List<Map<String, dynamic>> items;
  final String? subtotal;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  int get totalQuantity => items.fold<int>(0, (sum, item) {
        final qty = item['quantity'];
        if (qty is int) return sum + qty;
        if (qty is num) return sum + qty.toInt();
        return sum + 1;
      });

  CartState copyWith({
    List<Map<String, dynamic>>? items,
    String? subtotal,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    bool clearSubtotal = false,
  }) {
    return CartState(
      items: items ?? this.items,
      subtotal: clearSubtotal ? null : (subtotal ?? this.subtotal),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Map<String, dynamic>? itemForProduct(int productId, {int? branchId}) {
    for (final item in items) {
      final product = Map<String, dynamic>.from(item['product'] as Map? ?? {});
      final pid = product['id'] ?? item['product_id'];
      final matchesProduct = pid == productId ||
          (pid is num && pid.toInt() == productId) ||
          pid?.toString() == '$productId';
      if (!matchesProduct) continue;
      if (branchId == null) return item;
      final itemBranch = item['branch_id'];
      if (itemBranch == branchId) return item;
      if (itemBranch is num && itemBranch.toInt() == branchId) return item;
    }
    // Fallback: match product only when branch was requested but missing.
    if (branchId != null) {
      for (final item in items) {
        final product =
            Map<String, dynamic>.from(item['product'] as Map? ?? {});
        final pid = product['id'] ?? item['product_id'];
        final matchesProduct = pid == productId ||
            (pid is num && pid.toInt() == productId) ||
            pid?.toString() == '$productId';
        if (matchesProduct) return item;
      }
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  CommerceApiService get _api => CommerceApiService(DioService.instance);

  @override
  CartState build() {
    Future.microtask(refresh);
    return const CartState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _api.getCart();
    if (!ref.mounted) return;
    result.fold(
      (failure) {
        AppLogger.error('Failed to load cart', failure.message);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (cart) {
        state = state.copyWith(
          items: _parseItems(cart['items']),
          subtotal: cart['subtotal']?.toString(),
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  Future<bool> addProduct({
    required int productId,
    int quantity = 1,
    int? branchId,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    final result = await _api.addToCart(
      productId: productId,
      quantity: quantity,
      branchId: branchId,
    );
    if (!ref.mounted) return false;
    final failed = result.fold((f) => f.message, (_) => null);
    if (failed != null) {
      state = state.copyWith(isUpdating: false, errorMessage: failed);
      return false;
    }
    await refresh();
    if (ref.mounted) state = state.copyWith(isUpdating: false);
    return true;
  }

  Future<bool> setQuantity(int itemId, int quantity) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    final result = await _api.updateCartItem(itemId, quantity);
    if (!ref.mounted) return false;
    final failed = result.fold((f) => f.message, (_) => null);
    if (failed != null) {
      state = state.copyWith(isUpdating: false, errorMessage: failed);
      return false;
    }
    await refresh();
    if (ref.mounted) state = state.copyWith(isUpdating: false);
    return true;
  }

  Future<bool> increase(int itemId, int currentQuantity) =>
      setQuantity(itemId, currentQuantity + 1);

  Future<bool> decrease(int itemId, int currentQuantity) =>
      setQuantity(itemId, currentQuantity - 1);

  Future<bool> remove(int itemId) => setQuantity(itemId, 0);

  static List<Map<String, dynamic>> _parseItems(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
