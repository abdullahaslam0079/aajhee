part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({
    required this.fulfillmentType,
    required this.currentIndex,
  });

  final String fulfillmentType;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final steps = orderTimelineSteps(fulfillmentType: fulfillmentType);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= currentIndex
                          ? cs.primary
                          : cs.surfaceContainerHighest,
                      border: Border.all(
                        color:
                            i <= currentIndex ? cs.primary : cs.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: i < currentIndex
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: cs.onPrimary,
                          )
                        : i == currentIndex
                            ? Center(
                                child: Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.onPrimary,
                                  ),
                                ),
                              )
                            : null,
                  ),
                  if (i != steps.length - 1)
                    Container(
                      width: 2,
                      height: 22.h,
                      color: i < currentIndex ? cs.primary : cs.outlineVariant,
                    ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h, bottom: 8.h),
                  child: Text(
                    steps[i].label,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight:
                          i <= currentIndex ? FontWeight.w700 : FontWeight.w500,
                      color:
                          i <= currentIndex ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
