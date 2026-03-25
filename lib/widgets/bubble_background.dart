import 'dart:math';
import 'package:flutter/material.dart';

const Color kThemeColor = Color(0xFF00C5E8);

/// Light background tint aligned with the theme (under chat bubbles).
const Color kBubbleBackgroundColor = Color(0xFFE0F7FA);

/// Bubble fill color (slightly stronger than background, semi-transparent).
Color get kBubbleColor => kThemeColor.withValues(alpha: 0.25);

class Bubble {
  double x;
  double y;
  double vx;
  double vy;
  final double radius;
  final int id;

  Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
  });
}

class BubbleBackground extends StatefulWidget {
  final Widget child;

  const BubbleBackground({super.key, required this.child});

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Bubble> _bubbles = [];
  Size _size = Size.zero;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _controller.addListener(_tick);
  }

  void _tick() {
    if (!mounted || _bubbles.isEmpty) return;
    _updatePhysics();
  }

  void _updatePhysics() {
    final dt = 0.016;
    for (int i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      b.x += b.vx * dt;
      b.y += b.vy * dt;

      if (b.x - b.radius < 0) {
        b.x = b.radius;
        b.vx = -b.vx;
      }
      if (b.x + b.radius > _size.width) {
        b.x = _size.width - b.radius;
        b.vx = -b.vx;
      }
      if (b.y - b.radius < 0) {
        b.y = b.radius;
        b.vy = -b.vy;
      }
      if (b.y + b.radius > _size.height) {
        b.y = _size.height - b.radius;
        b.vy = -b.vy;
      }
    }

    for (int i = 0; i < _bubbles.length; i++) {
      for (int j = i + 1; j < _bubbles.length; j++) {
        _collide(_bubbles[i], _bubbles[j]);
      }
    }
    setState(() {});
  }

  void _collide(Bubble a, Bubble b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final dist = sqrt(dx * dx + dy * dy);
    final minDist = a.radius + b.radius;
    if (dist < minDist && dist > 0.001) {
      final nx = dx / dist;
      final ny = dy / dist;
      final overlap = minDist - dist;
      a.x -= nx * overlap * 0.5;
      a.y -= ny * overlap * 0.5;
      b.x += nx * overlap * 0.5;
      b.y += ny * overlap * 0.5;

      final dvx = b.vx - a.vx;
      final dvy = b.vy - a.vy;
      final dvn = dvx * nx + dvy * ny;
      if (dvn < 0) {
        final ma = a.radius * a.radius;
        final mb = b.radius * b.radius;
        final totalMass = ma + mb;
        final j = (2 * dvn) / totalMass;
        a.vx += (j * mb * nx);
        a.vy += (j * mb * ny);
        b.vx -= (j * ma * nx);
        b.vy -= (j * ma * ny);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  void _initBubbles(Size size) {
    _size = size;
    _bubbles = List.generate(12, (i) {
      final r = 20.0 + _random.nextDouble() * 35;
      return Bubble(
        id: i,
        x: r + _random.nextDouble() * (size.width - 2 * r),
        y: r + _random.nextDouble() * (size.height - 2 * r),
        vx: ( _random.nextDouble() - 0.5) * 120,
        vy: (_random.nextDouble() - 0.5) * 120,
        radius: r,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_bubbles.isEmpty || _size.width != size.width || _size.height != size.height) {
          _initBubbles(size);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: kBubbleBackgroundColor),
            CustomPaint(
              painter: _BubblePainter(bubbles: _bubbles),
              size: size,
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  _BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      final paint = Paint()
        ..color = kBubbleColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(b.x, b.y), b.radius, paint);
      final strokePaint = Paint()
        ..color = kThemeColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(b.x, b.y), b.radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => true;
}
