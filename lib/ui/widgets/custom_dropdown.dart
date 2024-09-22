import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';

import 'custom_textfield.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(T) itemBuilder;
  final Widget Function(T) selectedItemBuilder;

  const CustomDropdown({
    super.key,
    required this.items,
    this.onChanged,
    required this.itemBuilder,
    required this.selectedItemBuilder,
    this.initialValue,
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

  @override
  void initState(){
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
    _animationController.dispose();
    _scrollController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
    _animationController.status == AnimationStatus.completed
        ? _animationController.reverse()
        : _animationController.forward();
  }

  void _createOverlay() {
    _overlayEntry = _customDropdownOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _customDropdownOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width-8.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(4.0.w, size.height +4),
          child: Material(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
            elevation: 8,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.2,
                ),
                child: ListView.builder(

                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentValue = widget.items[index];
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(_currentValue);
                        }
                        _toggleDropdown();
                      },

                      child: widget.itemBuilder(widget.items[index]),
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height:  40.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.initialValue != null
                  ? widget.selectedItemBuilder(_currentValue as T)
                  : const Text('select an item'),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_animationController),
                child: const Icon(Icons.arrow_drop_down),
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
  }) : super(key: key);

  @override
  _DropdownTextFieldState<T> createState() => _DropdownTextFieldState<T>();
}

class _DropdownTextFieldState<T> extends State<DropdownTextField<T>> {
  T? _selectedOption;

  void _showDropdown() async {
    final RenderBox textFieldBox = context.findRenderObject() as RenderBox;
    final textFieldPosition = textFieldBox.localToGlobal(Offset.zero);

    final T? selectedOption = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        textFieldPosition.dx,
        textFieldPosition.dy + textFieldBox.size.height,
        textFieldPosition.dx + textFieldBox.size.width,
        textFieldPosition.dy + textFieldBox.size.height,
      ),
      items: widget.options.map((T option) {
        return PopupMenuItem<T>(
          value: option,
          child: Text(widget.displayStringForOption(option)),
        );
      }).toList(),
    );

    if (selectedOption != null) {
      setState(() {
        _selectedOption = selectedOption;
        widget.controller.text = widget.displayStringForOption(selectedOption);
        widget.onChange(selectedOption);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      prefixIcon: Icon(widget.prefixIcon),
      suffixIcon: Icon(Icons.arrow_drop_down),
      hintText: _selectedOption != null
          ? widget.displayStringForOption(_selectedOption!)
          : widget.hintText,
      readOnly: true,
      onTap: _showDropdown,
      validator: widget.validator,
      fieldName: widget.fieldName,
    );
  }
}