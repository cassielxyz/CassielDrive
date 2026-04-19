import 'package:flutter/material.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';

enum LogoVariant {
  natural,
  mono,
}

class ThemedLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final LogoVariant variant;

  const ThemedLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.variant = LogoVariant.natural,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final shouldUseBlueLogo =
        primary.toARGB32() == AppColors.cassielBlue.toARGB32();

    final effectiveVariant = shouldUseBlueLogo ? LogoVariant.natural : LogoVariant.mono;

    if (effectiveVariant == LogoVariant.natural) {
      return Image.asset(
        'assets/cassieldrive.png',
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
      );
    }

    return ColorFiltered(
      colorFilter: _monoFilter,
      child: Image.asset(
        'assets/cassieldrive.png',
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  static const ColorFilter _monoFilter = ColorFilter.matrix(<double>[
    0.299, 0.587, 0.114, 0, 0,
    0.299, 0.587, 0.114, 0, 0,
    0.299, 0.587, 0.114, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}