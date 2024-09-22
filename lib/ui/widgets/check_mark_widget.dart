import 'dart:math';
import 'package:flutter/material.dart';

class CheckmarkWithSpots extends StatefulWidget {
  final double size;
  final Color color;
  final int spotCount;

  const CheckmarkWithSpots({
    Key? key,
    this.size = 200,
    this.color = Colors.green,
    this.spotCount = 8,
  }) : super(key: key);

  @override
  _CheckmarkWithSpotsState createState() => _CheckmarkWithSpotsState();
}

class _CheckmarkWithSpotsState extends State<CheckmarkWithSpots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Spot> spots;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    spots = List.generate(widget.spotCount, (index) => Spot(widget.size));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          ...spots.map((spot) => AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: spot.x + sin(_controller.value * 2 * pi + spot.offset) * 10,
                top: spot.y + cos(_controller.value * 2 * pi + spot.offset) * 10,
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: spot.size,
                    height: spot.size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          )),
          Center(
            child: Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: widget.size * 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Spot {
  final double x;
  final double y;
  final double size;
  final double offset;

  Spot(double maxSize)
      : x = Random().nextDouble() * maxSize,
        y = Random().nextDouble() * maxSize,
        size = Random().nextDouble() * 10 + 5,
        offset = Random().nextDouble() * 2 * pi;
}