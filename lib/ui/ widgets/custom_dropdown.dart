import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(T) itemBuilder;
  final Widget Function(T) selectedItemBuilder;

  const CustomDropdown({
    Key? key,
    required this.items,
      this.onChanged,
    required this.itemBuilder,
    required this.selectedItemBuilder,
    this.initialValue,
  }) : super(key: key);

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
          offset: Offset(4.0.w, size.height),
          child: Material(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
            elevation: 4,
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