import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';

class GalaxyStorageWidget extends StatefulWidget {
  final Map<String, int> categoryStats;
  final int totalFiles;
  final double size;

  const GalaxyStorageWidget({
    super.key,
    required this.categoryStats,
    this.totalFiles = 0,
    this.size = 280,
  });

  @override
  State<GalaxyStorageWidget> createState() => _GalaxyStorageWidgetState();
}

class _GalaxyStorageWidgetState extends State<GalaxyStorageWidget>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbitController, _pulseAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: _GalaxyPainter(
              categoryStats: widget.categoryStats,
              totalFiles: widget.totalFiles,
              orbitProgress: _orbitController.value,
              pulseValue: _pulseAnimation.value,
              isDark: Theme.of(context).brightness == Brightness.dark,
              primaryColor: Theme.of(context).primaryColor,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class _GalaxyPainter extends CustomPainter {
  final Map<String, int> categoryStats;
  final int totalFiles;
  final double orbitProgress;
  final double pulseValue;
  final bool isDark;
  final Color primaryColor;

  _GalaxyPainter({
    required this.categoryStats,
    required this.totalFiles,
    required this.orbitProgress,
    required this.pulseValue,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw orbit rings
    _drawOrbitRings(canvas, center, size);

    // Draw center star (total storage)
    _drawCenterStar(canvas, center);

    // Draw orbiting planets
    _drawPlanets(canvas, center, size);

    // Draw center text
    _drawCenterText(canvas, center, size);
  }

  void _drawOrbitRings(Canvas canvas, Offset center, Size size) {
    final radii = [size.width * 0.22, size.width * 0.32, size.width * 0.42];

    for (final radius in radii) {
      final paint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withAlpha(15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawCenterStar(Canvas canvas, Offset center) {
    // Core
    final corePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, corePaint);

    // Bright core
    final brightCore = Paint()
      ..color = Colors.white.withAlpha(179)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, brightCore);
  }

  void _drawPlanets(Canvas canvas, Offset center, Size size) {
    final categories = [
      _PlanetInfo('Images', AppColors.imageColor, size.width * 0.22, 0.0),
      _PlanetInfo('Videos', AppColors.videoColor, size.width * 0.22, 0.5),
      _PlanetInfo('Documents', AppColors.documentColor, size.width * 0.32, 0.25),
      _PlanetInfo('Audio', AppColors.audioColor, size.width * 0.32, 0.75),
      _PlanetInfo('Archives', AppColors.archiveColor, size.width * 0.42, 0.15),
      _PlanetInfo('Code', AppColors.codeColor, size.width * 0.42, 0.65),
    ];

    for (final planet in categories) {
      final count = categoryStats[planet.name] ?? 0;
      if (count == 0 && totalFiles > 0) continue;

      final angle = (planet.startAngle + orbitProgress) * 2 * pi;
      final x = center.dx + cos(angle) * planet.orbitRadius;
      final y = center.dy + sin(angle) * planet.orbitRadius;

      // Calculate planet size based on file count
      final maxSize = 12.0;
      final minSize = 5.0;
      final ratio = totalFiles > 0 ? count / totalFiles : 0.2;
      final planetSize = minSize + (maxSize - minSize) * ratio;

      // Planet glow
      final glowPaint = Paint()
        ..color = planet.color.withAlpha(51)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), planetSize + 4, glowPaint);

      // Planet body
      final planetPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            planet.color,
            planet.color.withAlpha(179),
          ],
        ).createShader(
            Rect.fromCircle(center: Offset(x, y), radius: planetSize));
      canvas.drawCircle(Offset(x, y), planetSize, planetPaint);

      // Highlight
      final highlight = Paint()
        ..color = Colors.white.withAlpha(77)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(x - planetSize * 0.3, y - planetSize * 0.3),
          planetSize * 0.3,
          highlight);
    }
  }

  void _drawCenterText(Canvas canvas, Offset center, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$totalFiles',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) =>
      orbitProgress != oldDelegate.orbitProgress ||
      pulseValue != oldDelegate.pulseValue;
}

class _PlanetInfo {
  final String name;
  final Color color;
  final double orbitRadius;
  final double startAngle;

  _PlanetInfo(this.name, this.color, this.orbitRadius, this.startAngle);
}
