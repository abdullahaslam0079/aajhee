part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _BottomCartBar extends StatelessWidget {
  const _BottomCartBar({
    required this.inCart,
    required this.quantity,
    required this.busy,
    required this.priceLabel,
    required this.onAdd,
    required this.onViewCart,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final bool inCart;
  final int quantity;
  final bool busy;
  final String priceLabel;
  final VoidCallback? onAdd;
  final VoidCallback onViewCart;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      elevation: 8,
      color: cs.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: inCart
              ? Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
                          borderRadius: AppBorders.button,
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            _QtyIconButton(
                              icon: quantity <= 1
                                  ? Icons.delete_outline_rounded
                                  : Icons.remove_rounded,
                              onPressed: quantity <= 1 ? onRemove : onDecrease,
                              tone: quantity <= 1 ? cs.error : cs.onSurface,
                            ),
                            Expanded(
                              child: Text(
                                '$quantity',
                                textAlign: TextAlign.center,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _QtyIconButton(
                              icon: Icons.add_rounded,
                              onPressed: onIncrease,
                              tone: cs.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: onViewCart,
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(48.h),
                        ),
                        child: const Text('View cart'),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton(
                    onPressed: onAdd,
                    child: busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: cs.onPrimary,
                            ),
                          )
                        : Text(
                            'Add to cart · $priceLabel',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
        ),
      ),
    );
  }
}
