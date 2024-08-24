import 'package:fintech_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimationBack extends StatefulWidget {
  const AnimationBack({super.key});
  @override
  _AnimationBackState createState() => _AnimationBackState();
}

class _AnimationBackState extends State<AnimationBack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complex Stack Widget Example')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          CustomPaint(
            painter: BackgroundPainter(),
          ),

          // Animated circles
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: 150 * math.sin((_controller.value * 2 * math.pi) + index),
                  top: 150 * math.cos((_controller.value * 2 * math.pi) + index),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.5),
                    ),
                  ),
                );
              },
            );
          }),

          // Draggable overlay
          Positioned(
            left: _dragPosition,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition += details.delta.dx;
                  _dragPosition = _dragPosition.clamp(0, MediaQuery.of(context).size.width - 100);
                });
              },
              child: Container(
                width: 100,
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'Drag me!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Positioned text
          const Positioned(
            bottom: 20,
            right: 20,
            child: Text(
              'Complex Stack Example',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(5.0, 5.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
      // ..shader = LinearGradient(
      //   colors: [Colors.blue[800]!, Colors.purple[800]!],
      // ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  paint.color= colorScheme.primary;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}