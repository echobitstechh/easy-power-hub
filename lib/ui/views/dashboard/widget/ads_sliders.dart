import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBanner extends StatefulWidget {
  const VideoBanner({super.key});

  @override
  State<VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<VideoBanner> {

  final List<String> _videos = const [
    'assets/videos/easy_ad_1.mp4',
    'assets/videos/easy_ad_2.mp4',
    'assets/videos/easy_ad_3.mp4',
    'assets/videos/easy_ad_4.mp4',

  ];

  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (final v in _videos) {
      final c = VideoPlayerController.asset(v)
        ..setLooping(true)
        ..setVolume(0.0);
      _controllers.add(c);
      c.initialize().then((_) {
        if (mounted) setState(() {});
        c.play();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double kHeight = 200;

    return CarouselSlider.builder(
      itemCount: _controllers.length,
      itemBuilder: (context, index, realIndex) {
        final c = _controllers[index];
        return RepaintBoundary(
          child: Container(
            height: kHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            clipBehavior: Clip.hardEdge,
            child: c.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            )
                : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      },
      options: CarouselOptions(
        height: kHeight,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: true, // Carousel auto-advances; videos loop individually
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 350),
        enableInfiniteScroll: true,
        pauseAutoPlayOnTouch: true,
        padEnds: false,
      ),
    );
  }
}
