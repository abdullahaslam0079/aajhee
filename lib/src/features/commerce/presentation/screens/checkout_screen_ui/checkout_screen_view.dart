part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with CheckoutScreenController {
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ref.watch(userProfileProvider).profile;
    final address = ref.watch(savedAddressesProvider).selectedAddress;
    final canvas = homeCanvasOf(context);

    ref.listen(savedAddressesProvider, (previous, next) {
      final address = next.selectedAddress;
      if (address?.id != _lastAddressId) {
        _applyAddressFields(address);
      }
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('Checkout'),
      ),
      bottomNavigationBar: _loading || _error != null || _groups.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rs ${_money(_grandTotal)}',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _placing ? null : _placeOrder,
                        child: _placing
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text('Place order · Rs ${_money(_grandTotal)}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: _loading
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
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  children: [
                    _SectionCard(
                      title: 'Your details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(
                            icon: Icons.person_outline_rounded,
                            label: profile.displayName,
                          ),
                          if (profile.email.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _DetailRow(
                              icon: Icons.mail_outline_rounded,
                              label: profile.email,
                            ),
                          ],
                          SizedBox(height: 12.h),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Mobile number',
                              hintText: '03XX-XXXXXXX',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_needsDelivery) ...[
                      SizedBox(height: 12.h),
                      _SectionCard(
                        title: 'Delivery address',
                        trailing: TextButton(
                          onPressed: () =>
                              showDeliveryAddressPicker(context, ref),
                          child: Text(address == null ? 'Add' : 'Change'),
                        ),
                        child: address == null
                            ? Text(
                                'Add an address for delivery orders.',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.shortLabel.isNotEmpty
                                        ? address.shortLabel
                                        : address.formattedAddress,
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  if (address.deliveryInstructions
                                      .trim()
                                      .isNotEmpty) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Note: ${address.deliveryInstructions.trim()}',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 12.h),
                                  TextField(
                                    controller: _houseController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'House / flat number',
                                      hintText: 'e.g. Flat 4B',
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    controller: _landmarkController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Landmark',
                                      hintText: 'e.g. Near Liberty Market',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                    for (var groupIndex = 0;
                        groupIndex < _groups.length;
                        groupIndex++) ...[
                      SizedBox(height: 12.h),
                      _SectionCard(
                        title: _groups[groupIndex].storeName,
                        child: Builder(
                          builder: (context) {
                            final group = _groups[groupIndex];
                            final proof = _paymentProofs[groupIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final item in group.items) ...[
                                  _CheckoutItemRow(item: item),
                                  if (item != group.items.last)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.h,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: cs.outlineVariant,
                                      ),
                                    ),
                                ],
                                SizedBox(height: 16.h),
                                Text(
                                  'Fulfillment',
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                for (final option in group.options)
                                  _SelectableTile(
                                    selected: group.fulfillmentType ==
                                        option.fulfillmentType,
                                    title: option.label.isNotEmpty
                                        ? option.label
                                        : labelFulfillment(
                                            option.fulfillmentType,
                                          ),
                                    subtitle: 'Fee: Rs ${_money(option.fee)}',
                                    onTap: () => _setFulfillment(
                                      group,
                                      option.fulfillmentType,
                                    ),
                                  ),
                                SizedBox(height: 14.h),
                                Text(
                                  'Payment method',
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                for (final method
                                    in group.availablePaymentMethods())
                                  _SelectableTile(
                                    selected: group.paymentMethod == method,
                                    title: labelPayment(method),
                                    subtitle: _paymentSubtitle(group, method),
                                    onTap: () => setState(
                                      () => group.paymentMethod = method,
                                    ),
                                  ),
                                if (requiresPaymentProof(
                                  group.paymentMethod,
                                )) ...[
                                  _PaymentInstructionsDetails(
                                    method: group.paymentMethod,
                                    payments: group.payments,
                                  ),
                                  SizedBox(height: 8.h),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickPaymentProof(groupIndex),
                                    icon: Icon(
                                      proof == null
                                          ? Icons.upload_file_outlined
                                          : Icons.check_circle_outline,
                                    ),
                                    label: Text(
                                      proof == null
                                          ? 'Upload payment receipt'
                                          : proof.name,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _SectionCard(
                      title: 'Order notes',
                      child: TextField(
                        controller: _notesController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Optional note for the store',
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _SectionCard(
                      title: 'Order summary',
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Items',
                            value: 'Rs ${_money(_itemsTotal)}',
                          ),
                          SizedBox(height: 8.h),
                          _SummaryRow(
                            label: 'Delivery fee',
                            value: 'Rs ${_money(_feesTotal)}',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Divider(
                              height: 1,
                              color: cs.outlineVariant,
                            ),
                          ),
                          _SummaryRow(
                            label: 'Total',
                            value: 'Rs ${_money(_grandTotal)}',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
