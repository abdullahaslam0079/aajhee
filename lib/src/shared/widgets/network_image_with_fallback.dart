import '../../imports/imports.dart';

/// Loads a network image with an optional [primaryUrl] and [fallbackUrl].
///
/// Logs load failures in debug mode and automatically switches to the fallback
/// when the primary URL is missing or fails to load.
class NetworkImageWithFallback extends StatefulWidget {
  const NetworkImageWithFallback({
    super.key,
    this.primaryUrl,
    this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.debugLabel,
    this.errorWidget,
  });

  final String? primaryUrl;
  final String? fallbackUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String? debugLabel;
  final Widget? errorWidget;

  @override
  State<NetworkImageWithFallback> createState() =>
      _NetworkImageWithFallbackState();
}

class _NetworkImageWithFallbackState extends State<NetworkImageWithFallback> {
  String? _failedPrimaryUrl;

  String get _resolvedPrimary => resolveMediaUrl(widget.primaryUrl) ?? '';

  String get _activeUrl {
    final primary = _resolvedPrimary;
    if (primary.isEmpty || primary == _failedPrimaryUrl) {
      return widget.fallbackUrl?.trim() ?? '';
    }
    return primary;
  }

  void _handleImageError(String url, Object error) {
    final primary = _resolvedPrimary;
    if (primary.isEmpty || url != primary || _failedPrimaryUrl == primary) {
      AppLogger.warning(
        '[Image${widget.debugLabel != null ? ' ${widget.debugLabel}' : ''}] '
        'Failed to load url=$url error=$error',
      );
      return;
    }

    AppLogger.warning(
      '[Image${widget.debugLabel != null ? ' ${widget.debugLabel}' : ''}] '
      'Primary failed (404 or network): $primary — using fallback. error=$error',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _failedPrimaryUrl == primary) return;
      setState(() => _failedPrimaryUrl = primary);
    });
  }

  Widget _buildPlaceholder(BuildContext context) {
    return widget.errorWidget ??
        ColoredBox(
          color: context.theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.storefront_outlined,
            color: context.theme.colorScheme.onSurfaceVariant,
            size: 34,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final activeUrl = _activeUrl;
    if (activeUrl.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildPlaceholder(context),
      );
    }

    return CommonImage(
      key: ValueKey(activeUrl),
      imageUrl: activeUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      borderRadius: widget.borderRadius,
      errorWidget: widget.errorWidget ?? _buildPlaceholder(context),
      onError: _handleImageError,
    );
  }
}
