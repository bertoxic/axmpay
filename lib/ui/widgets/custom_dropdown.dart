import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';

import 'custom_textfield.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(T) itemBuilder;
  final Widget Function(T) selectedItemBuilder;
  final String hintText;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  const CustomDropdown({
    super.key,
    required this.items,
    this.onChanged,
    required this.itemBuilder,
    required this.selectedItemBuilder,
    this.initialValue,
    this.hintText = 'Select an item',
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> with SingleTickerProviderStateMixin {
  late T? _currentValue;
  late final AnimationController _animationController;
  late final ScrollController _scrollController;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController = ScrollController();
    _currentValue = widget.initialValue;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDisposed) return;

    if (_isOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }

    if (mounted) {
      setState(() {
        _isOpen = !_isOpen;
      });
    }

    if (!_isDisposed) {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  void _createOverlay() {
    if (_isDisposed || !mounted) return;

    _overlayEntry = _customDropdownOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _customDropdownOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final theme = Theme.of(context);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 8.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(4.0.w, size.height + 4),
          child: Material(
            color: widget.backgroundColor ?? theme.cardColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            elevation: 8,
            shadowColor: Colors.black26,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final isSelected = _currentValue == widget.items[index];
                    return InkWell(
                      onTap: () {
                        if (mounted && !_isDisposed) {
                          setState(() {
                            _currentValue = widget.items[index];
                          });
                          if (widget.onChanged != null) {
                            widget.onChanged!(_currentValue);
                          }
                        }
                        _toggleDropdown();
                      },
                      child: Container(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        child: widget.itemBuilder(widget.items[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = _currentValue != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50.h,
          decoration: BoxDecoration(
            color: _isOpen
                ? (widget.backgroundColor ?? theme.cardColor).withOpacity(0.95)
                : widget.backgroundColor ?? theme.cardColor,
            border: Border.all(
              color: _isOpen
                  ? widget.borderColor ?? theme.primaryColor
                  : widget.borderColor ?? Colors.grey.shade300,
              width: _isOpen ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isOpen
                ? [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              hasValue
                  ? widget.selectedItemBuilder(_currentValue as T)
                  : Text(
                widget.hintText,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_animationController),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.iconColor ?? theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownTextField<T> extends StatefulWidget {
  final Function(T?) onChange;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<T> options;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final String fieldName;
  final String Function(T) displayStringForOption;
  final Color? backgroundColor;
  final Color? accentColor;

  const DropdownTextField({
    Key? key,
    required this.onChange,
    required this.controller,
    required this.options,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.fieldName,
    required this.displayStringForOption,
    this.validator,
    this.backgroundColor,
    this.accentColor,
  }) : super(key: key);

  @override
  _DropdownTextFieldState<T> createState() => _DropdownTextFieldState<T>();
}

class _DropdownTextFieldState<T> extends State<DropdownTextField<T>> with SingleTickerProviderStateMixin {
  T? _selectedOption;
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  OverlayEntry? _backgroundOverlay;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    if (_backgroundOverlay != null) {
      _backgroundOverlay?.remove();
      _backgroundOverlay = null;
    }

    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isMenuOpen = false;
      });

      if (!_isDisposed) {
        _animationController.reverse();
      }
    }
  }

  void _toggleDropdown() {
    if (_isDisposed) return;

    if (_isMenuOpen) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    if (_isDisposed || !mounted) return;

    final RenderBox textFieldBox = context.findRenderObject() as RenderBox;
    final size = textFieldBox.size;
    final theme = Theme.of(context);

    if (mounted) {
      setState(() {
        _isMenuOpen = true;
      });
    }

    if (!_isDisposed) {
      _animationController.forward();
    }

    // Create background overlay for handling outside taps
    _backgroundOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            color: widget.backgroundColor ?? theme.cardColor,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    final isSelected = _selectedOption == option;

                    return InkWell(
                      onTap: () {
                        if (mounted && !_isDisposed) {
                          setState(() {
                            _selectedOption = option;
                            widget.controller.text = widget.displayStringForOption(option);
                          });
                          widget.onChange(option);
                        }
                        _removeOverlay();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (widget.accentColor ?? theme.primaryColor).withOpacity(0.1)
                              : null,
                          border: index != widget.options.length - 1
                              ? Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.5,
                            ),
                          )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.displayStringForOption(option),
                              style: TextStyle(
                                color: isSelected
                                    ? widget.accentColor ?? theme.primaryColor
                                    : null,
                                fontWeight: isSelected ? FontWeight.w500 : null,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: widget.accentColor ?? theme.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlays in the correct order
    Overlay.of(context).insert(_backgroundOverlay!);
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomTextField(
        controller: widget.controller,
        labelText: widget.labelText,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: _isMenuOpen
              ? widget.accentColor ?? theme.primaryColor
              : Colors.grey.shade600,
        ),
        suffixIcon: RotationTransition(
          turns: Tween(begin: 0.0, end: 0.5).animate(_animationController),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _isMenuOpen
                ? widget.accentColor ?? theme.primaryColor
                : Colors.grey.shade600,
          ),
        ),
        hintText: _selectedOption != null
            ? widget.displayStringForOption(_selectedOption!)
            : widget.hintText,
        readOnly: true,
        onTap: _toggleDropdown,
        validator: widget.validator,
        fieldName: widget.fieldName,
      ),
    );
  }
}