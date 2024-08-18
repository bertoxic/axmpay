import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class CustomBottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final ValueChanged<int> onItemSelected;
  final int initialIndex;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double height;
  final double iconSize;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool showLabels;
  final bool enableAnimation;
  final Curve animationCurve;
  final Duration animationDuration;
  final bool? extendBody;

  const CustomBottomNavBar({
    Key? key,
    required this.items,
    required this.onItemSelected,
    this.initialIndex = 0,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height = 56.0,
    this.iconSize = 24.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showLabels = true,
    this.enableAnimation = true,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.extendBody,
  })  : assert(items.length >= 2 && items.length <= 5),
        assert(initialIndex >= 0 && initialIndex < items.length),
        super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animations = List.generate(
      widget.items.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index / widget.items.length,
            (index + 1) / widget.items.length,
            curve: widget.animationCurve,
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      widget.onItemSelected(index);
      if (widget.enableAnimation) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).bottomAppBarColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          return _buildNavItem(index);
        }),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = index == _selectedIndex;
    final Color itemColor = isSelected
        ? widget.selectedItemColor ?? Theme.of(context).primaryColor
        : widget.unselectedItemColor ?? Theme.of(context).unselectedWidgetColor;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, isSelected ? -8 * _animations[index].value : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(widget.items[index].icon, itemColor, index),
                if (widget.showLabels) ...[
                  const SizedBox(height: 4),
                  _buildLabel(widget.items[index].label, itemColor, isSelected),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: vector.radians(360 * _animations[index].value),
          child: Icon(
            icon,
            color: color,
            size: widget.iconSize,
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label, Color color, bool isSelected) {
    return AnimatedDefaultTextStyle(
      duration: widget.animationDuration,
      style: isSelected
          ? widget.selectedLabelStyle ??
          TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)
          : widget.unselectedLabelStyle ??
          TextStyle(color: color, fontSize: 12),
      child: Text(label),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}