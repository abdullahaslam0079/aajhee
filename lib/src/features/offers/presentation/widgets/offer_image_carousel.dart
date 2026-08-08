import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class OfferImageCarousel extends StatefulWidget {
  const OfferImageCarousel({
    super.key,
    required this.imageUrls,
    required this.height,
    this.borderRadius = AppBorders.lg,
    this.debugLabel = 'offer',
    this.onPageChanged,
    this.onImageTap,
  });

  final List<String> imageUrls;
  final double height;
  final BorderRadius borderRadius;
  final String debugLabel;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onImageTap;

  @override
  State<OfferImageCarousel> createState() => _OfferImageCarouselState();
}

class _OfferImageCarouselState extends State<OfferImageCarousel> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _image({
    required String url,
    required String debugLabel,
    required ColorScheme cs,
    required Color muted,
  }) {
    return NetworkImageWithFallback(
      primaryUrl: url,
      debugLabel: debugLabel,
      fit: BoxFit.cover,
      errorWidget: ColoredBox(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.broken_image_outlined, color: muted),
      ),
    );
  }

  Widget _tappable({
    required int index,
    required Widget child,
  }) {
    if (widget.onImageTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onImageTap!(index),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final urls = widget.imageUrls;

    if (urls.isEmpty) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: ColoredBox(
            color: cs.surfaceContainerHighest,
            child: Icon(Icons.local_offer_outlined, color: muted, size: 40),
          ),
        ),
      );
    }

    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: _tappable(
            index: 0,
            child: _image(
              url: urls.first,
              debugLabel: widget.debugLabel,
              cs: cs,
              muted: muted,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: urls.length,
              onPageChanged: (index) {
                setState(() => _index = index);
                widget.onPageChanged?.call(index);
              },
              itemBuilder: (context, index) {
                return _tappable(
                  index: index,
                  child: _image(
                    url: urls[index],
                    debugLabel: '${widget.debugLabel} $index',
                    cs: cs,
                    muted: muted,
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.sm.h,
              child: IgnorePointer(
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
            ),
          ],
        ),
      ),
    );
  }
}
