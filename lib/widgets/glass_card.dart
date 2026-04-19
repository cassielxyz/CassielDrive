import 'dart:ui';
import 'package:flutter/material.dart';

/// True glassmorphism card — translucent frosted glass effect.
/// Dark mode: white tint over backdrop blur on black background.
/// Light mode: white tint over backdrop blur on white background.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurSigma = 20,
    this.borderColor,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // True glassmorphism: translucent tint over blurred background
    final surfaceColor = isDark
        ? Colors.white.withAlpha(20)   // ~8% white tint on dark bg
        : Colors.white.withAlpha(180); // ~70% white on light bg

    final effectiveBorder = borderColor ??
        (isDark
            ? Colors.white.withAlpha(30)   // ~12% white border
            : Colors.white.withAlpha(200)); // near-white border on light

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: width,
              height: height,
              padding: padding ?? const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: effectiveBorder, width: 0.5),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
