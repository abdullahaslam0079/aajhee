import 'dart:ui';
import '../../imports/imports.dart';

/// Shows a highly customizable bottom sheet with premium features like backdrop blur.
///
/// This helper uses the [rootNavigatorKey] to display the sheet
/// without needing a local [BuildContext].
Future<T?> showAppSheet<T>({
  required Widget child,
  bool hasBlur = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool isDismissible = true,
}) {
  final context = rootContext;
  if (context == null) return Future.value(null);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: context.theme.indicatorColor.withValues(alpha: 0.35),
    elevation: 0,
    useSafeArea: useSafeArea,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    shape: const RoundedRectangleBorder(
      borderRadius: AppBorders.bottomSheet,
    ),
    builder: (sheetContext) {
      final content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: hasBlur ? 3 : 0,
          sigmaY: hasBlur ? 3 : 0,
        ),
        child: child,
      );

      // isScrollControlled sheets can fill the route; an opaque detector without
      // onTap was swallowing taps on the area above the sheet. Dismiss on those
      // taps, and absorb taps that land on the sheet body itself.
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isDismissible
            ? () => Navigator.of(sheetContext).maybePop()
            : null,
        child: GestureDetector(
          onTap: () {},
          child: content,
        ),
      );
    },
  );
}
