import 'dart:math';
import 'package:flutter/material.dart';

class SquigglyProgressBar extends StatefulWidget {
  final Duration progress;
  final Duration total;
  final Duration buffered;
  final ValueChanged<Duration>? onSeek;
  final Color baseColor;
  final Color progressColor;
  final Color thumbColor;
  final Color bufferedColor;
  final double strokeWidth;
  final double thumbRadius;
  final bool showTimeLabels;
  final TextStyle? timeLabelTextStyle;

  const SquigglyProgressBar({
    super.key,
    required this.progress,
    required this.total,
    this.buffered = Duration.zero,
    this.onSeek,
    this.baseColor = const Color(0x4DFFFFFF),
    this.progressColor = Colors.white,
    this.thumbColor = Colors.white,
    this.bufferedColor = const Color(0x80FFFFFF),
    this.strokeWidth = 3.0,
    this.thumbRadius = 6.0,
    this.showTimeLabels = true,
    this.timeLabelTextStyle,
  });

  @override
  State<SquigglyProgressBar> createState() => _SquigglyProgressBarState();
}

class _SquigglyProgressBarState extends State<SquigglyProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  bool _dragging = false;
  double _dragFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double get _fraction {
    if (widget.total.inMilliseconds == 0) return 0.0;
    return (widget.progress.inMilliseconds / widget.total.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = widget.timeLabelTextStyle ??
        const TextStyle(color: Colors.white, fontSize: 12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() => _dragging = true);
            final fraction = (details.localPosition.dx / w).clamp(0.0, 1.0);
            setState(() => _dragFraction = fraction);
          },
          onHorizontalDragUpdate: (details) {
            final fraction = (details.localPosition.dx / w).clamp(0.0, 1.0);
            setState(() => _dragFraction = fraction);
          },
          onHorizontalDragEnd: (details) {
            setState(() => _dragging = false);
            if (widget.onSeek != null && widget.total.inMilliseconds > 0) {
              final ms = (_dragFraction * widget.total.inMilliseconds).round();
              widget.onSeek!(Duration(milliseconds: ms));
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    final displayFraction =
                        _dragging ? _dragFraction : _fraction;
                    return CustomPaint(
                      size: Size(w, 30),
                      painter: _SquigglyPainter(
                        fraction: displayFraction,
                        animValue: _anim.value,
                        baseColor: widget.baseColor,
                        progressColor: widget.progressColor,
                        bufferedColor: widget.bufferedColor,
                        bufferedFraction: widget.total.inMilliseconds > 0
                            ? (widget.buffered.inMilliseconds /
                                    widget.total.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        strokeWidth: widget.strokeWidth,
                        thumbRadius: widget.thumbRadius,
                        thumbColor: widget.thumbColor,
                      ),
                    );
                  },
                ),
              ),
              if (widget.showTimeLabels)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(_dragging
                            ? Duration(
                                milliseconds:
                                    (_dragFraction * widget.total.inMilliseconds)
                                        .round())
                            : widget.progress),
                        style: labelStyle,
                      ),
                      Text(
                        _fmt(widget.total),
                        style: labelStyle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SquigglyPainter extends CustomPainter {
  final double fraction;
  final double animValue;
  final Color baseColor;
  final Color progressColor;
  final Color bufferedColor;
  final double bufferedFraction;
  final double strokeWidth;
  final double thumbRadius;
  final Color thumbColor;

  _SquigglyPainter({
    required this.fraction,
    required this.animValue,
    required this.baseColor,
    required this.progressColor,
    required this.bufferedColor,
    required this.bufferedFraction,
    required this.strokeWidth,
    required this.thumbRadius,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final mid = h / 2;
    final amplitude = h * 0.15;
    final waveLength = 60.0;
    final phase = animValue * 2 * pi;

    final basePath = Path();
    final progressPath = Path();
    final bufferedPath = Path();

    final progressX = size.width * fraction;
    final bufferedX = size.width * bufferedFraction;

    for (double x = 0; x <= size.width; x += 0.5) {
      final y = mid + amplitude * sin((x / waveLength) * 2 * pi + phase);

      if (x == 0) {
        basePath.moveTo(x, y);
        progressPath.moveTo(x, y);
        bufferedPath.moveTo(x, y);
      } else {
        basePath.lineTo(x, y);
        if (x <= progressX) {
          progressPath.lineTo(x, y);
        }
        if (x <= bufferedX) {
          bufferedPath.lineTo(x, y);
        }
      }
    }

    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final bufferedPaint = Paint()
      ..color = bufferedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(basePath, basePaint);
    if (bufferedFraction > 0) {
      canvas.drawPath(bufferedPath, bufferedPaint);
    }
    if (fraction > 0) {
      canvas.drawPath(progressPath, progressPaint);
    }

    if (fraction > 0) {
      final thumbY =
          mid + amplitude * sin((progressX / waveLength) * 2 * pi + phase);
      final thumbPaint = Paint()
        ..color = thumbColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(progressX, thumbY), thumbRadius, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SquigglyPainter old) =>
      fraction != old.fraction ||
      animValue != old.animValue ||
      baseColor != old.baseColor ||
      progressColor != old.progressColor ||
      bufferedFraction != old.bufferedFraction;
}
