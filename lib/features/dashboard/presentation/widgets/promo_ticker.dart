import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../ui/common/app_colors.dart';

const List<String> _tickerMessages = [
  '🚚 Free Delivery on qualifying orders',
  '🛡️ Warranty on All Products',
  '💳 Pay on Delivery Available',
  '⚡ Premium Solar & Smart Home Ecosystem',
];

/// Small auto-cycling banner mirroring web's scrolling ticker — cycles a
/// fixed set of value-prop messages above the home content.
class PromoTicker extends StatefulWidget {
  const PromoTicker({super.key});

  @override
  State<PromoTicker> createState() => _PromoTickerState();
}

class _PromoTickerState extends State<PromoTicker> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _tickerMessages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kcPrimaryColor,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Text(
            _tickerMessages[_index],
            key: ValueKey(_index),
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'HostGrotesk',
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
