import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

Future<void> showFullScreenImageGallery(
  BuildContext context, {
  required List<String> imageUrls,
  int initialIndex = 0,
}) {
  if (imageUrls.isEmpty) return Future.value();

  final safeIndex = initialIndex.clamp(0, imageUrls.length - 1);

  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: FullScreenImageGallery(
            imageUrls: imageUrls,
            initialIndex: safeIndex,
          ),
        );
      },
    ),
  );
}

class FullScreenImageGallery extends StatefulWidget {
  const FullScreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: NetworkImageWithFallback(
                    primaryUrl: urls[index],
                    debugLabel: 'fullscreen gallery $index',
                    fit: BoxFit.contain,
                    errorWidget: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: topInset + AppSpacing.sm.h,
            left: AppSpacing.ms.w,
            right: AppSpacing.ms.w,
            child: Row(
              children: [
                IconButton(
                  onPressed: _close,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
                const Spacer(),
                if (urls.length > 1)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm.w,
                      vertical: AppSpacing.xxs.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: AppBorders.full,
                    ),
                    child: Text(
                      '${_index + 1} / ${urls.length}',
                      style: context.theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset + AppSpacing.md.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (index) {
                  final active = index == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: active ? 18.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: AppBorders.full,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
