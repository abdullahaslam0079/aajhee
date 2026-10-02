import 'package:aajhee/src/features/commerce/domain/entities/cart_line.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

class CartState {
  const CartState({
    this.items = const [],
    this.subtotal,
    this.isLoading = false,
    this.isUpdating = false,
    this.updatingItemId,
    this.errorMessage,
  });

  final List<CartLine> items;
  final String? subtotal;
  final bool isLoading;
  final bool isUpdating;
  final int? updatingItemId;
  final String? errorMessage;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartLine>? items,
    String? subtotal,
    bool? isLoading,
    bool? isUpdating,
    int? updatingItemId,
    String? errorMessage,
    bool clearError = false,
    bool clearSubtotal = false,
    bool clearUpdatingItem = false,
  }) {
    return CartState(
      items: items ?? this.items,
      subtotal: clearSubtotal ? null : (subtotal ?? this.subtotal),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      updatingItemId: clearUpdatingItem
          ? null
          : (updatingItemId ?? this.updatingItemId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  CartLine? lineForProduct(int productId, {int? branchId}) {
    return CartSnapshot(items: items, subtotal: subtotal)
        .lineForProduct(productId, branchId: branchId);
  }
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  CommerceRepository get _commerce => ref.read(commerceRepositoryProvider);

  /// Bumped on every refresh and mutation. A response applies only if no
  /// newer cart operation started while it was in flight.
  int _generation = 0;

  /// Mutations and refreshes run one at a time so a slow refresh cannot
  /// overwrite a quantity change that started after it.
  Future<void> _tail = Future<void>.value();

  @override
  CartState build() {
    _generation = 0;
    _tail = Future<void>.value();
    Future.microtask(refresh);
    return const CartState(isLoading: true);
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final run = _tail.then((_) => action());
    _tail = run.then((_) {}, onError: (Object _, StackTrace __) {});
    return run;
  }

  Future<void> refresh({bool silent = false}) {
    return _enqueue(() => _refresh(silent: silent));
  }

  Future<void> _refresh({required bool silent}) async {
    final generation = ++_generation;
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    final result = await _commerce.getCart();
    if (!ref.mounted || generation != _generation) return;
    result.fold(
      (failure) {
        AppLogger.error('Failed to load cart', failure.message);
        state = state.copyWith(
          isLoading: false,
          isUpdating: false,
          clearUpdatingItem: true,
          errorMessage: failure.message,
        );
      },
      (cart) {
        state = state.copyWith(
          items: cart.items,
          subtotal: cart.subtotal,
          isLoading: false,
          isUpdating: false,
          clearUpdatingItem: true,
          clearError: true,
        );
      },
    );
  }

  Future<bool> addProduct({
    required int productId,
    int quantity = 1,
    int? branchId,
  }) {
    return _enqueue(
      () => _addProduct(
        productId: productId,
        quantity: quantity,
        branchId: branchId,
      ),
    );
  }

  Future<bool> _addProduct({
    required int productId,
    required int quantity,
    int? branchId,
  }) async {
    final generation = ++_generation;
    state = state.copyWith(isUpdating: true, clearError: true);
    final result = await _commerce.addToCart(
      productId: productId,
      quantity: quantity,
      branchId: branchId,
    );
    if (!ref.mounted || generation != _generation) return false;
    final failed = result.fold((f) => f.message, (_) => null);
    if (failed != null) {
      state = state.copyWith(isUpdating: false, errorMessage: failed);
      return false;
    }
    await _refresh(silent: true);
    return true;
  }

  Future<bool> setQuantity(int itemId, int quantity) {
    return _enqueue(() => _setQuantity(itemId, quantity));
  }

  Future<bool> _setQuantity(int itemId, int quantity) async {
    final generation = ++_generation;
    final previousItems = List<CartLine>.from(state.items);

    if (quantity < 1) {
      state = state.copyWith(
        items: state.items.where((item) => item.id != itemId).toList(),
        isUpdating: true,
        updatingItemId: itemId,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        items: state.items
            .map(
              (item) => item.id == itemId
                  ? item.copyWith(quantity: quantity)
                  : item,
            )
            .toList(),
        isUpdating: true,
        updatingItemId: itemId,
        clearError: true,
      );
    }

    final result = await _commerce.updateCartItem(itemId, quantity);
    if (!ref.mounted || generation != _generation) return false;
    final failed = result.fold((f) => f.message, (_) => null);
    if (failed != null) {
      state = state.copyWith(
        items: previousItems,
        isUpdating: false,
        clearUpdatingItem: true,
        errorMessage: failed,
      );
      return false;
    }
    await _refresh(silent: true);
    return true;
  }

  Future<bool> increase(int itemId, int currentQuantity) =>
      setQuantity(itemId, currentQuantity + 1);

  Future<bool> decrease(int itemId, int currentQuantity) =>
      setQuantity(itemId, currentQuantity - 1);

  Future<bool> remove(int itemId) => setQuantity(itemId, 0);
}
