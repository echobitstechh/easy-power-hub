import 'dart:ui';
import 'package:flutter/material.dart';
import '../../common/app_colors.dart';

class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool disabled;
  final double borderRadius;
  final double height;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool iconIsPrefix;
  final Color? color;

  const GlassButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.disabled = false,
    this.borderRadius = 16,
    this.height = 56,
    this.textStyle,
    this.icon,
    this.iconIsPrefix = true,
    this.color,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isActive = !widget.disabled && !widget.isLoading;
    final baseColor = widget.color ?? kcPrimaryColor;

    return GestureDetector(
      onTapDown: isActive ? _onTapDown : null,
      onTapUp: isActive ? _onTapUp : null,
      onTapCancel: isActive ? _onTapCancel : null,
      onTap: isActive ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.disabled
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : [
                            baseColor,
                            baseColor.withOpacity(0.80),
                          ],
                  ),
                  border: Border.all(
                    color: widget.disabled
                        ? Colors.transparent
                        : baseColor.withOpacity(0.60),
                    width: 1,
                  ),
                  boxShadow: widget.disabled
                      ? []
                      : [
                          BoxShadow(
                            color: baseColor.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : _buildContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final label = Text(
      widget.label,
      style: widget.textStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
    );

    if (widget.icon == null) return label;

    final children = [
      widget.icon!,
      const SizedBox(width: 8),
      label,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.iconIsPrefix ? children : children.reversed.toList(),
    );
  }
}
