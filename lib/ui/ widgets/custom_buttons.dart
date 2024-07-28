import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonType { elevated, outlined, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final Widget? customChild;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.elevated,
    this.size = ButtonSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledColor,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.customChild,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Color defaultBackgroundColor = widget.type == ButtonType.elevated
        ? colorScheme.primary
        : Colors.transparent;
    final Color defaultForegroundColor = widget.type == ButtonType.elevated
        ? colorScheme.onPrimary
        : colorScheme.primary;

    final Color backgroundColor = widget.backgroundColor ?? defaultBackgroundColor;
    final Color foregroundColor = widget.foregroundColor ?? defaultForegroundColor;
    final Color disabledColor = widget.disabledColor ?? theme.disabledColor;

    final ButtonStyle buttonStyle = _getButtonStyle(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledColor: disabledColor,
    );

    final Widget buttonChild = widget.customChild ?? _buildButtonContent();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: _buildButton(buttonStyle, buttonChild),
          ),
        );
      },
    );
  }

  Widget _buildButton(ButtonStyle buttonStyle, Widget buttonChild) {
    switch (widget.type) {
      case ButtonType.elevated:
        return ElevatedButton(
          onPressed: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }
  }

  ButtonStyle _getButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color disabledColor,
  }) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          // if (states.contains(MaterialState.disabled)) {
          //   return disabledColor;
          // }
          return backgroundColor;
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(foregroundColor),
      overlayColor: MaterialStateProperty.all<Color>(foregroundColor.withOpacity(0.1)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(_getPadding()),
      minimumSize: MaterialStateProperty.all<Size>(_getSize()),
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  Size _getSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return Size(widget.width ?? 80, widget.height ?? 32);
      case ButtonSize.medium:
        return Size(widget.width ?? 120, widget.height ?? 40);
      case ButtonSize.large:
        return Size(widget.width ?? 160, widget.height ?? 48);
    }
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.foregroundColor ?? Colors.white),
        ),
      );
    }

    final List<Widget> children = [];

    if (widget.prefixIcon != null) {
      children.add(Icon(widget.prefixIcon, size: 18));
      children.add(SizedBox(width: 8));
    }

    children.add(
      Text(
        widget.text,
        style: widget.textStyle ?? _getDefaultTextStyle(),
      ),
    );

    if (widget.suffixIcon != null) {
      children.add(SizedBox(width: 8));
      children.add(Icon(widget.suffixIcon, size: 18));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  TextStyle _getDefaultTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return TextStyle(fontSize: 12);
      case ButtonSize.medium:
        return TextStyle(fontSize: 14);
      case ButtonSize.large:
        return TextStyle(fontSize: 16);
    }
  }
}