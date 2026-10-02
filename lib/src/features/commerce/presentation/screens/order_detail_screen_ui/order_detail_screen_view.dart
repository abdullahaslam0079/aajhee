part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen>
    with
        WidgetsBindingObserver,
        PeriodicRefreshMixin,
        OrderDetailScreenController {
  Widget build(BuildContext context) {
    final tick = ref.watch(commerceRealtimeTickProvider);
    if (tick != _lastRealtimeTick) {
      _lastRealtimeTick = tick;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load(silent: true);
      });
    }

    final order = _order;
    final canvas = homeCanvasOf(context);
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('Order details'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order not found',
                  subtitle: 'This order may have been removed.',
                  actionLabel: 'Back to orders',
                  onAction: () => context.pop(),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _buildDetail(context, order),
                ),
    );
  }

  Widget _buildDetail(BuildContext context, OrderDetail order) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = order.status;
    final fulfillment = order.fulfillmentType;
    final paymentMethod = order.paymentMethod;
    final paymentStatus = order.paymentStatus;
    final customerPhone = order.customerPhone;
    final isPickup = isPickupFulfillment(fulfillment);
    final branchName = order.branchName;
    final customerNotes = order.customerNotes;
    final deliveryFee = order.deliveryFee;
    final addressText = order.deliveryAddressText;
    final houseNumber = order.deliveryHouseNumber;
    final landmark = order.deliveryLandmark;
    final bankInstructions = order.paymentInstructionsText;
    final placedAt = formatCommerceDateTime(order.placedAt);
    final orderNumber = formatOrderNumber(order.publicId);
    final (statusColor, statusBg) = orderStatusColors(context, status);
    final items = order.lines;
    final proofs = order.paymentProofs;
    final canUploadProof = requiresPaymentProof(paymentMethod) &&
        (status == 'awaiting_payment' ||
            status == 'accepted' ||
            status == 'payment_submitted');
    final timelineIndex = orderTimelineIndex(
      status,
      fulfillmentType: fulfillment,
    );
    final addressParts = [
      if (houseNumber.isNotEmpty) houseNumber,
      if (landmark.isNotEmpty) landmark,
      if (addressText.isNotEmpty) addressText,
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: AppBorders.sm,
                ),
                child: Text(
                  labelStatus(status),
                  style: tt.titleSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                order.businessName.isEmpty ? 'Store' : order.businessName,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              if (branchName.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  branchName,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              SizedBox(height: 10.h),
              _MetaLine(
                icon: Icons.tag_rounded,
                label: orderNumber.isEmpty ? 'Order' : 'Order $orderNumber',
              ),
              if (placedAt != '—') ...[
                SizedBox(height: 6.h),
                _MetaLine(
                  icon: Icons.schedule_rounded,
                  label: 'Placed $placedAt',
                ),
              ],
            ],
          ),
        ),
        if (timelineIndex >= 0) ...[
          SizedBox(height: 12.h),
          _SectionCard(
            title: 'Status',
            child: _OrderTimeline(
              fulfillmentType: fulfillment,
              currentIndex: timelineIndex,
            ),
          ),
        ],
        SizedBox(height: 12.h),
        _SectionCard(
          title: isPickup ? 'Pickup' : 'Delivery',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: 'Method',
                value: labelFulfillment(fulfillment),
              ),
              if (fulfillment == 'local_same_day') ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Promised by',
                  value: () {
                    final promised = formatCommerceDateTime(order.promisedBy);
                    if (promised == '—' || promised.isEmpty) {
                      return 'End of day';
                    }
                    return 'End of day · $promised';
                  }(),
                ),
              ],
              if (!isPickup && addressParts.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Address',
                  value: addressParts.join('\n'),
                  multiline: true,
                ),
              ],
              if (isPickup && branchName.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Pickup from',
                  value: branchName,
                ),
              ],
              if (customerPhone.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Phone',
                  value: customerPhone,
                ),
              ],
              if (customerNotes.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Your notes',
                  value: customerNotes,
                  multiline: true,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _SectionCard(
          title: 'Payment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: 'Method',
                value: labelPayment(paymentMethod),
              ),
              if (paymentStatus.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Status',
                  value: labelPaymentStatus(paymentStatus),
                ),
              ],
              if (bankInstructions.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
                    borderRadius: AppBorders.md,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        switch (paymentMethod) {
                          'stripe' => 'Card payment details',
                          'jazzcash' => 'JazzCash details',
                          _ => 'Bank transfer details',
                        },
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        bankInstructions,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _SectionCard(
          title: items.length == 1 ? '1 item' : '${items.length} items',
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _OrderItemTile(
                  item: items[i],
                  imageUrl:
                      _productImages[items[i].productId] ?? items[i].imageUrl,
                  orderStatus: status,
                  onRate: status == 'completed' && items[i].canReview
                      ? () async {
                          final ok = await showRateProductSheet(
                            context: context,
                            api: _api,
                            orderPublicId: widget.publicId,
                            item: items[i],
                          );
                          if (ok && mounted) _load();
                        }
                      : null,
                ),
                if (i != items.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(height: 1, color: cs.outlineVariant),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _SectionCard(
          title: 'Order summary',
          child: Column(
            children: [
              _SummaryRow(
                label: 'Subtotal',
                value: 'Rs ${order.subtotal}',
              ),
              if (_hasFee(deliveryFee)) ...[
                SizedBox(height: 8.h),
                _SummaryRow(
                  label: 'Delivery fee',
                  value: 'Rs $deliveryFee',
                ),
              ],
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(height: 1, color: cs.outlineVariant),
              ),
              _SummaryRow(
                label: 'Total',
                value: 'Rs ${order.total}',
                emphasize: true,
              ),
            ],
          ),
        ),
        if (status == 'cancelled') ...[
          SizedBox(height: 12.h),
          _CancelledInfoCard(order: order),
        ],
        if (proofs.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _SectionCard(
            title: 'Payment receipts',
            child: Column(
              children: [
                for (var i = 0; i < proofs.length; i++) ...[
                  _PaymentProofTile(proof: proofs[i]),
                  if (i != proofs.length - 1) SizedBox(height: 10.h),
                ],
              ],
            ),
          ),
        ],
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _contactStore,
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Contact store'),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _reporting ? null : _reportProblem,
            icon: const Icon(Icons.flag_outlined),
            label: Text(_reporting ? 'Reporting…' : 'Report a problem'),
          ),
        ),
        SizedBox(height: 8.h),
        _CancelSection(
          order: order,
          cancelling: _cancelling,
          onCancel: _cancelOrder,
          pendingBlockedReason: _pendingCancelBlockedReason(order),
        ),
        if (canUploadProof) ...[
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _uploadProof,
              child: const Text('Upload payment receipt'),
            ),
          ),
        ],
      ],
    );
  }
}
