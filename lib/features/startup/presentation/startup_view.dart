import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import '../../../ui/common/app_colors.dart';
import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: kcDarkBgGradient,
          ),
        ),
        child: Stack(
          children: [
            // Amber glow — top right
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [kcGlowAmberStrong, Colors.transparent],
                  ),
                ),
              ),
            ),
            // Blue glow — bottom left
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: _LogoWithRing(isDone: viewModel.isComplete),
            ),
          ],
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => viewModel.runStartupLogic(),
      );
}

// ── Logo + integrated progress ring ──────────────────────────────────────────

class _LogoWithRing extends StatefulWidget {
  final bool isDone;
  const _LogoWithRing({required this.isDone});

  @override
  State<_LogoWithRing> createState() => _LogoWithRingState();
}

class _LogoWithRingState extends State<_LogoWithRing>
    with TickerProviderStateMixin {
  // Continuous slow rotation of the indeterminate arc
  late AnimationController _spinController;

  // Completion: arc fills to 1.0 then the logo scales + fades
  late AnimationController _doneController;
  late Animation<double> _fillAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Tracks fill value so CustomPaint can access it independently of scale
  double _fillValue = 0.0;

  static const double _containerSize = 136.0; // glass circle diameter
  static const double _ringSize = 136.0;      // ring traces the same circle
  static const double _strokeWidth = 3.5;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _doneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Arc fills from 0 → 1 in first 55% of the animation
    _fillAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _doneController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    )..addListener(() => setState(() => _fillValue = _fillAnim.value));

    // Logo scales up gently in last 60%
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(
        parent: _doneController,
        curve: const Interval(0.40, 1.0, curve: Curves.easeOut),
      ),
    );

    // Everything fades out in last 30%
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _doneController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void didUpdateWidget(_LogoWithRing old) {
    super.didUpdateWidget(old);
    if (widget.isDone && !old.isDone) {
      _spinController.stop();
      _doneController.forward();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _doneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_spinController, _doneController]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SizedBox(
              width: _containerSize,
              height: _containerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glass logo circle
                  Container(
                    width: _containerSize,
                    height: _containerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kcGlassSurfaceDark,
                      border: Border.all(
                        color: kcGlassBorderDark,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kcGlowAmber,
                          blurRadius: widget.isDone ? 64 : 40,
                          spreadRadius: widget.isDone ? 12 : 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/easy_ph_logo.png',
                        height: 68,
                        width: 68,
                      ),
                    ),
                  ),

                  // Progress ring — perfectly circumscribes the glass circle
                  SizedBox(
                    width: _ringSize,
                    height: _ringSize,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: _fillValue,
                        sweepAngle: widget.isDone
                            ? null
                            : _spinController.value,
                        strokeWidth: _strokeWidth,
                        color: kcSecondaryColor,
                        trackColor: kcGlassBorderDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;   // 0–1, used when filling on completion
  final double? sweepAngle; // null = fill mode; 0–1 = spin head position
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  const _RingPainter({
    required this.progress,
    required this.sweepAngle,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Faint track circle
    canvas.drawCircle(center, radius, trackPaint);

    if (sweepAngle != null) {
      // Indeterminate: a 120° arc that rotates continuously
      const arcLength = 2.094; // 120° in radians
      final startAngle = sweepAngle! * 2 * 3.14159265 - 1.5707963; // offset so arc top starts at top
      canvas.drawArc(rect, startAngle, arcLength, false, arcPaint);
    } else {
      // Fill mode: arc grows from top (−π/2) around clockwise
      final sweep = progress * 2 * 3.14159265;
      if (sweep > 0) {
        canvas.drawArc(rect, -1.5707963, sweep, false, arcPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.sweepAngle != sweepAngle ||
      old.color != color;
}
