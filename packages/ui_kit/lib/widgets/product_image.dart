import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'loading_shimmer.dart';
import '../theme/app_colors.dart';

class ProductImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  bool _hovered = false;
  String? get imageUrl => widget.imageUrl;
  double? get width => widget.width;
  double? get height => widget.height;
  BoxFit get fit => widget.fit;
  BorderRadius? get borderRadius => widget.borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder(effectiveRadius);
    }

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
              scale: _hovered && !MediaQuery.disableAnimationsOf(context)
                  ? 1.045
                  : 1,
              duration: Duration(milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 450),
              curve: Curves.easeOutCubic,
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: width,
                height: height,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 200),
                memCacheWidth: (width != null && width! < 1000)
                    ? (width! * 2.5).toInt()
                    : 700,
                memCacheHeight: (height != null && height! < 1000)
                    ? (height! * 2.5).toInt()
                    : 700,
                filterQuality: FilterQuality.medium,
                placeholder: (_, __) => LoadingShimmer(
                  width: width ?? double.infinity,
                  height: height ?? double.infinity,
                  borderRadius: effectiveRadius,
                ),
                errorWidget: (_, __, ___) => _placeholder(effectiveRadius),
              ))),
    );
  }

  Widget _placeholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          color: AppColors.primary.withValues(alpha: 0.25),
          size: 28,
        ),
      ),
    );
  }
}
