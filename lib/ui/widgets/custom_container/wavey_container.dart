import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWavyBackgroundContainer extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final double? height;
  final double? width;
  final Decoration? decoration;
  final BorderRadius? borderRadius;

  AnimatedWavyBackgroundContainer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.purple,
    this.height,
    this.width,
    this.decoration,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(30),  // Add bottom radius
      bottomRight: Radius.circular(30), // Add bottom radius
    ),
  }) : super(key: key);

  @override
  _AnimatedWavyBackgroundContainerState createState() => _AnimatedWavyBackgroundContainerState();
}

class _AnimatedWavyBackgroundContainerState extends State<AnimatedWavyBackgroundContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: widget.decoration,
      child: Stack(
        children: [
          // Border painter, placed at the base
          Positioned.fill(
            child: CustomPaint(
              painter: BorderPainter(borderRadius: widget.borderRadius),
            ),
          ),
          // First wave layer (translucent and smaller waves)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: widget.borderRadius!,
              child: ClipPath(
                clipper: AnimatedWaveClipper(_animation.value, waveHeight: 30, waveLengthDiv: 2.5),
                child: Container(
                  color: widget.backgroundColor.withOpacity(0.6), // Slightly translucent
                ),
              ),
            ),
          ),
          // Second wave layer (stronger waves)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: widget.borderRadius!,
              child: ClipPath(
                clipper: AnimatedWaveClipper(_animation.value + pi, waveHeight: 50, waveLengthDiv: 2),
                child: Container(
                  color: widget.backgroundColor.withOpacity(0.8), // Slightly less translucent
                ),
              ),
            ),
          ),
          // Third wave layer (strong, opaque waves)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: widget.borderRadius!,
              child: ClipPath(
                clipper: AnimatedWaveClipper(_animation.value + pi / 2, waveHeight: 70, waveLengthDiv: 1.5),
                child: Container(
                  color: widget.backgroundColor, // Opaque main background
                ),
              ),
            ),
          ),
          // The child widget content
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

// Custom Painter to paint the border
class BorderPainter extends CustomPainter {
  final BorderRadius? borderRadius;

  BorderPainter({this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint border
    final paint = Paint()
      ..color = Colors.grey.shade300 // Border color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Border thickness

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius?.toRRect(rect) ?? RRect.fromRectAndRadius(rect, Radius.zero);
    canvas.drawRRect(rrect, paint); // Draw the border
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom clipper for the animated wave
class AnimatedWaveClipper extends CustomClipper<Path> {
  final double waveOffset;
  final double waveHeight;
  final double waveLengthDiv;

  AnimatedWaveClipper(this.waveOffset, {this.waveHeight = 20.0, this.waveLengthDiv = 2.0});

  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height * 0.75);

    double waveLength = size.width / waveLengthDiv; // Length of one wave cycle

    for (double i = 0; i <= size.width; i++) {
      double y = size.height * 0.75 + sin((i / waveLength + waveOffset)) * waveHeight;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
