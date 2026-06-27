import '../../imports/imports.dart';
import 'package:flutter_avif/flutter_avif.dart';

/// A multi-purpose image widget that handles network images, SVGs, and local assets.
///
/// Automatically uses [CachedNetworkImage] for standard web images and
/// [AvifImage] for `.avif` URLs.
class CommonImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final void Function(String url, Object error)? onError;

  const CommonImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveMediaUrl(imageUrl);
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      AppLogger.warning('[Image] Empty or invalid url: $imageUrl');
      return errorWidget ?? _buildDefaultErrorWidget(context, width, height);
    }

    if (width != null || height != null) {
      return _buildImage(context, resolvedUrl, width: width, height: height);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildImage(
          context,
          resolvedUrl,
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
        );
      },
    );
  }

  Widget _buildImage(
    BuildContext context,
    String resolvedUrl, {
    double? width,
    double? height,
  }) {
    final adjustedWidth = width?.w;
    final adjustedHeight = height?.h;

    Widget image;

    if (resolvedUrl.startsWith('http') && isAvifUrl(resolvedUrl)) {
      image = AvifImage.network(
        resolvedUrl,
        width: adjustedWidth,
        height: adjustedHeight,
        fit: fit,
        color: color,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildLoadingPlaceholder(context, width, height);
        },
        errorBuilder: (context, error, stackTrace) {
          _reportError(resolvedUrl, error);
          return errorWidget ?? _buildDefaultErrorWidget(context, width, height);
        },
      );
    } else if (resolvedUrl.startsWith('http')) {
      image = AppCachedImage(
        imageUrl: resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        placeholder: placeholder,
        errorWidget: errorWidget ??
            _buildDefaultErrorWidget(context, width, height),
        borderRadius: borderRadius,
        useSkeleton: false,
        onError: (error) => _reportError(resolvedUrl, error),
      );
    } else if (resolvedUrl.endsWith('.svg')) {
      image = SvgPicture.asset(
        resolvedUrl,
        width: adjustedWidth,
        height: adjustedHeight,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else {
      image = Image.asset(
        resolvedUrl,
        width: adjustedWidth,
        height: adjustedHeight,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          _reportError(resolvedUrl, error);
          return errorWidget ??
              _buildDefaultErrorWidget(context, width, height);
        },
      );
    }

    if (borderRadius != null &&
        (!resolvedUrl.startsWith('http') || isAvifUrl(resolvedUrl))) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  void _reportError(String url, Object error) {
    AppLogger.warning('[Image] Failed to load url=$url error=$error');
    final callback = onError;
    if (callback == null) return;

    // AvifImage may invoke errorBuilder synchronously during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback(url, error);
    });
  }

  Widget _buildLoadingPlaceholder(
    BuildContext context,
    double? width,
    double? height,
  ) {
    return Container(
      width: width,
      height: height,
      color: context.theme.colorScheme.surfaceContainerHighest,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultErrorWidget(
    BuildContext context,
    double? width,
    double? height,
  ) {
    return Container(
      width: width,
      height: height,
      color: context.theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: context.theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
