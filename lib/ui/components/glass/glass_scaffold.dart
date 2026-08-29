import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/app_colors.dart';

/// Wraps a screen with the app's gradient background. Drop-in replacement for
/// Scaffold when the gradient bg is needed (auth, onboarding, success screens).
class GlassScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;

  const GlassScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark ? kcDarkBgGradient : kcLightBgGradient;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          body: body,
        ),
      ),
    );
  }
}
