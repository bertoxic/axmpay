import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class CustomBottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final ValueChanged<int> onItemSelected;
  final int initialIndex;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final double height;
  final double iconSize;

  const CustomBottomNavBar({
    Key? key,
    required this.items,
    required this.onItemSelected,
    this.initialIndex = 0,
    this.selectedItemColor = const Color(0xff462eb4),
    this.unselectedItemColor = Colors.grey,
    this.height = 60.0,
    this.iconSize = 24.0,
  })  : assert(items.length >= 2 && items.length <= 5),
        assert(initialIndex >= 0 && initialIndex < items.length),
        super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _positionAnimation;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _positionAnimation = Tween<double>(begin: widget.initialIndex.toDouble(), end: widget.initialIndex.toDouble()).animate(_animation);
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 1.0), weight: 1),
    ]).animate(_animation);
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _positionAnimation = Tween<double>(
          begin: _selectedIndex.toDouble(),
          end: index.toDouble(),
        ).animate(_animation);
        _selectedIndex = index;
      });
      widget.onItemSelected(index);
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.0),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth;
                final itemWidth = containerWidth / widget.items.length;
                final circleSize = widget.height * 0.8;
                final horizontalPadding = (itemWidth - circleSize) / 2;

                return Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          left: _positionAnimation.value * itemWidth + horizontalPadding,
                          top: (widget.height - circleSize) / 2,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                color: widget.selectedItemColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(widget.items.length, (index) {
                        return _buildNavItem(index);
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem(int index) {
    final bool isSelected = index == _selectedIndex;
    final Color itemColor = isSelected ? widget.selectedItemColor : widget.unselectedItemColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: SizedBox(
          height: widget.height,
          child: Icon(
            widget.items[index].icon,
            color: itemColor,
            size: widget.iconSize,
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;

  BottomNavItem({required this.icon});
}