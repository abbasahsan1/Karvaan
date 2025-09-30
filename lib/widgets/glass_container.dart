import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

/// A reusable frosted glass container with subtle border and blur.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(AppTheme.glassBorderOpacity),
          width: 1,
        ),
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.glassBlurSigma,
            sigmaY: AppTheme.glassBlurSigma,
          ),
          child: Material(
            color: Colors.white.withOpacity(0.02),
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onTap,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated gradient background with softly glowing blobs.
class KarvaanBackground extends StatefulWidget {
  const KarvaanBackground({super.key});

  @override
  State<KarvaanBackground> createState() => _KarvaanBackgroundState();
}

class _KarvaanBackgroundState extends State<KarvaanBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E3A8A)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: lerpDouble(-120, 40, t)!,
                left: lerpDouble(-100, 80, 1 - t)!,
                child: _GlowingBlob(
                  diameter: 320,
                  colors: const [Color(0xFF22D3EE), Color(0xAA38BDF8)],
                ),
              ),
              Positioned(
                bottom: lerpDouble(-160, 20, 1 - t)!,
                right: lerpDouble(-140, 60, t)!,
                child: _GlowingBlob(
                  diameter: 360,
                  colors: const [Color(0xFF6366F1), Color(0xAA7C3AED)],
                ),
              ),
              Positioned(
                bottom: lerpDouble(80, 140, t)!,
                left: lerpDouble(-60, 40, t)!,
                child: _GlowingBlob(
                  diameter: 220,
                  colors: const [Color(0xFF0EA5E9), Color(0xAA0F172A)],
                ),
              ),
              if (child != null) child,
            ],
          ),
        );
      },
    );
  }
}

class _GlowingBlob extends StatelessWidget {
  const _GlowingBlob({
    required this.diameter,
    required this.colors,
  });

  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colors.first.withOpacity(0.55),
              colors.last.withOpacity(0.08),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper for wrapping screens with the animated background.
class KarvaanScaffoldShell extends StatelessWidget {
  const KarvaanScaffoldShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const KarvaanBackground(),
        Positioned.fill(
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ],
    );
  }
}
