part of 'package:aajhee/src/features/commerce/presentation/screens/orders_screen.dart';

mixin OrdersScreenController
    on
        WidgetsBindingObserver,
        PeriodicRefreshMixin<OrdersScreen>,
        ConsumerState<OrdersScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  List<OrderSummary> _orders = const [];
  bool _loading = true;
  String? _error;
  OrderStatusGroup _statusGroup = OrderStatusGroup.active;
  int _lastRealtimeTick = 0;

  @override
  void initState() {
    super.initState();
    _load();
    startPeriodicRefresh();
  }

  @override
  void dispose() {
    stopPeriodicRefresh();
    super.dispose();
  }

  @override
  Future<void> onPeriodicRefresh() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await _api.getOrders(
      statusGroup: _statusGroup.apiValue,
    );
    if (!mounted) return;
    result.fold(
      (f) {
        if (silent) return;
        setState(() {
          _loading = false;
          _error = f.message;
        });
      },
      (items) {
        setState(() {
          _orders = items;
          _loading = false;
          _error = null;
        });
        if (_statusGroup == OrderStatusGroup.active) {
          ref.invalidate(activeOrdersBadgeProvider);
        }
      },
    );
  }

  void _selectGroup(OrderStatusGroup group) {
    if (group == _statusGroup) return;
    setState(() => _statusGroup = group);
    _load();
  }
}
