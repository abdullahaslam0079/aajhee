part of 'package:aajhee/src/features/commerce/presentation/screens/orders_screen.dart';

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with WidgetsBindingObserver, PeriodicRefreshMixin, OrdersScreenController {
  @override
  Widget build(BuildContext context) {
    final tick = ref.watch(commerceRealtimeTickProvider);
    if (tick != _lastRealtimeTick) {
      _lastRealtimeTick = tick;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load(silent: true);
      });
    }

    final canvas = homeCanvasOf(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('My orders'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: OrderStatusGroup.values.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final group = OrderStatusGroup.values[index];
                  final selected = group == _statusGroup;
                  final bg = selected ? cs.primary : cs.surfaceContainerLowest;
                  final fg = selected ? cs.onPrimary : cs.onSurfaceVariant;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectGroup(group),
                      borderRadius: AppBorders.md,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: AppBorders.md,
                          border: selected
                              ? null
                              : Border.all(color: cs.outlineVariant),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Center(
                            child: Text(
                              group.label,
                              style: tt.labelMedium?.copyWith(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: fg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _orders.isEmpty
                        ? AppEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title:
                                'No ${_statusGroup.label.toLowerCase()} orders',
                            subtitle:
                                'When you place an order, it will show up here.',
                            actionLabel: 'Continue shopping',
                            onAction: () {
                              ref
                                  .read(bottomNavBarControllerProvider.notifier)
                                  .selectedIndex = 0;
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                0,
                                16.w,
                                kHomeFeedBottomInset +
                                    MediaQuery.paddingOf(context).bottom +
                                    16.h,
                              ),
                              itemCount: _orders.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return _OrderListCard(
                                  order: order,
                                  onTap: () async {
                                    await context.push(
                                      AppRoutes.orderDetail(
                                        order.publicId,
                                      ),
                                    );
                                    if (mounted) _load();
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
