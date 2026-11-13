import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'product_image.dart';

/// Swipeable images with keyboard-focusable, labelled image selectors.
class MarsProductGallery extends StatefulWidget {
  final List<String> images;
  final String label;
  const MarsProductGallery(
      {super.key, required this.images, required this.label});
  @override
  State<MarsProductGallery> createState() => _MarsProductGalleryState();
}

class _MarsProductGalleryState extends State<MarsProductGallery> {
  final _pages = PageController();
  int _index = 0;
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.isEmpty ? 1 : widget.images.length;
    return SizedBox(
        height: 380,
        child: Stack(children: [
          Positioned.fill(
              child: PageView.builder(
            controller: _pages,
            itemCount: count,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) => Semantics(
                image: true,
                label: '${widget.label}, image ${index + 1} of $count',
                child: ProductImage(
                    imageUrl:
                        widget.images.isEmpty ? null : widget.images[index],
                    width: double.infinity,
                    height: 380,
                    borderRadius: BorderRadius.circular(24))),
          )),
          if (count > 1)
            Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Center(
                    child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.onyx.withValues(alpha: .85),
                      borderRadius: BorderRadius.circular(24)),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        for (var i = 0; i < count; i++)
                          Semantics(
                              selected: _index == i,
                              child: IconButton(
                                tooltip: 'Show image ${i + 1}',
                                onPressed: () {
                                  if (MediaQuery.disableAnimationsOf(context)) {
                                    _pages.jumpToPage(i);
                                  } else {
                                    _pages.animateToPage(i,
                                        duration:
                                            const Duration(milliseconds: 350),
                                        curve: Curves.easeOutCubic);
                                  }
                                },
                                icon: AnimatedContainer(
                                    duration: Duration(
                                        milliseconds:
                                            MediaQuery.disableAnimationsOf(
                                                    context)
                                                ? 0
                                                : 180),
                                    height: 6,
                                    width: _index == i ? 18 : 6,
                                    decoration: BoxDecoration(
                                        color: _index == i
                                            ? AppColors.linen
                                            : AppColors.textHint,
                                        borderRadius:
                                            BorderRadius.circular(8))),
                              )),
                      ])),
                ))),
        ]));
  }
}
