import 'package:flutter/material.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';

class StorageBar extends StatefulWidget {
  final double usedPercentage;
  final String usedLabel;
  final String totalLabel;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const StorageBar({
    super.key,
    required this.usedPercentage,
    required this.usedLabel,
    required this.totalLabel,
    this.height = 10,
    this.color,
    this.backgroundColor,
  });

  @override
  State<StorageBar> createState() => _StorageBarState();
}

class _StorageBarState extends State<StorageBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.usedPercentage)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(StorageBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usedPercentage != widget.usedPercentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.usedPercentage,
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = widget.color ?? _getColor(widget.usedPercentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.usedLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
            ),
            Text(
              widget.totalLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    (isDark
                        ? Colors.white.withAlpha(26)
                        : Colors.black.withAlpha(20)),
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            barColor,
                            barColor.withAlpha(179),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withAlpha(102),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getColor(double percentage) {
    if (percentage > 0.9) return AppColors.error;
    if (percentage > 0.7) return AppColors.warning;
    return Theme.of(context).primaryColor;
  }
}
