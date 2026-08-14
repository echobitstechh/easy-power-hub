import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/data/models/ad_media.dart';
import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';

const List<String> _gifList = [
  "assets/gif/easy_power_hub.gif",
  "assets/gif/motion.gif",
];

/// Home hero carousel. Shows admin-managed ad media (image/gif/video)
/// from the backend when available, falling back to the static promo
/// GIFs when there is none active.
class AdsCarousel extends StatefulWidget {
  final DashboardViewModel viewModel;

  const AdsCarousel({super.key, required this.viewModel});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adMedia = widget.viewModel.adMediaList;
    final useAds = adMedia.isNotEmpty;
    final itemCount = useAds ? adMedia.length : _gifList.length;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: itemCount,
          itemBuilder: (context, index, realIndex) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: useAds
                    ? _AdMediaSlide(media: adMedia[index])
                    : Stack(
                        children: [
                          Image.asset(
                            _gifList[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          // Subtle gradient overlay at the bottom
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.22),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
          options: CarouselOptions(
            height: 190,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: useAds ? 6 : 5),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
        ),

        const SizedBox(height: 10),

        // Pill indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCount, (i) {
            final isActive = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? kcPrimaryColor
                    : (isDark
                        ? kcWhiteColor.withOpacity(0.25)
                        : kcMediumGrey.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AdMediaSlide extends StatefulWidget {
  final AdMedia media;

  const _AdMediaSlide({required this.media});

  @override
  State<_AdMediaSlide> createState() => _AdMediaSlideState();
}

class _AdMediaSlideState extends State<_AdMediaSlide> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.media.mediaType == AdMediaType.video) {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.media.mediaUrl));
      _controller = controller;
      controller.initialize().then((_) {
        if (!mounted) return;
        controller
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openLink() async {
    final linkUrl = widget.media.linkUrl;
    if (linkUrl == null || linkUrl.isEmpty) return;
    final uri = Uri.tryParse(linkUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLink,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.media.mediaType == AdMediaType.video)
            _controller != null && _controller!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                : Container(color: Colors.grey[300])
          else
            CachedNetworkImage(
              imageUrl: widget.media.mediaUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey[300]),
            ),
          if (widget.media.title != null || widget.media.description != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.media.title != null)
                  Text(
                    widget.media.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HostGrotesk',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (widget.media.description != null)
                  Text(
                    widget.media.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
