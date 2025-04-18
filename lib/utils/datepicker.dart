import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../ui/widgets/custom_textfield.dart';

class DatePickerTextField extends StatefulWidget {
  final BuildContext context;
  final Function(String?) onChange;
  final DateFormat? dateFormat;
  final TextEditingController dateController;
  final String? Function(String?)? validator;

  const DatePickerTextField({
    super.key,
    required this.context,
    required this.onChange,
    this.dateFormat,
    required this.dateController,
    this.validator,
  });

  @override
  State<DatePickerTextField> createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  DateTime? _selectedDate;

  DateFormat get _dateFormat => widget.dateFormat ?? DateFormat('dd/MM/yyyy');

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: colorScheme.onSurface,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.dateController.text = _dateFormat.format(_selectedDate!);
        widget.onChange(widget.dateController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.dateController,
      labelText: 'Date of Birth',
      prefixIcon: const Icon(Icons.calendar_today),
      suffixIcon: const Icon(Icons.arrow_drop_down),
      hintText: 'DD/MM/YYYY',
      readOnly: true,
      onTap: _selectDate,
      validator: widget.validator,
      fieldName: 'date_of_birth',
    );
  }
}

// class DropdownTextField<T> extends StatefulWidget {
//   final Function(T?) onChange;
//   final TextEditingController controller;
//   final String? Function(String?)? validator;
//   final List<T> options;
//   final String labelText;
//   final String hintText;
//   final IconData prefixIcon;
//   final String fieldName;
//   final String Function(T) displayStringForOption;
//
//   const DropdownTextField({
//     Key? key,
//     required this.onChange,
//     required this.controller,
//     required this.options,
//     required this.labelText,
//     required this.hintText,
//     required this.prefixIcon,
//     required this.fieldName,
//     required this.displayStringForOption,
//     this.validator,
//   }) : super(key: key);
//
//   @override
//   _DropdownTextFieldState<T> createState() => _DropdownTextFieldState<T>();
// }
//
// class _DropdownTextFieldState<T> extends State<DropdownTextField<T>> {
//   T? _selectedOption;
//   final FocusNode _focusNode = FocusNode();
//   OverlayEntry? _overlayEntry;
//   final LayerLink _layerLink = LayerLink();
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         _showDropdownOverlay();
//       } else {
//         _hideDropdownOverlay();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _showDropdownOverlay() {
//     final RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;
//
//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: Offset(0.0, size.height),
//           child: Material(
//             elevation: 4.0,
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               height: min(200, widget.options.length * 48.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListView.builder(
//                 padding: EdgeInsets.zero,
//                 shrinkWrap: true,
//                 itemCount: widget.options.length,
//                 itemBuilder: (context, index) {
//                   final option = widget.options[index];
//                   return InkWell(
//                     onTap: () {
//                       setState(() {
//                         _selectedOption = option;
//                         widget.controller.text = widget.displayStringForOption(option);
//                         widget.onChange(option);
//                       });
//                       _focusNode.unfocus();
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       child: Text(
//                         widget.displayStringForOption(option),
//                         style: TextStyle(
//                           color: colorScheme.onSurface,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//   }
//
//   void _hideDropdownOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: CustomTextField(
//         controller: widget.controller,
//         labelText: widget.labelText,
//         prefixIcon: Icon(widget.prefixIcon),
//         suffixIcon: Icon(Icons.arrow_drop_down),
//         hintText: _selectedOption != null
//             ? widget.displayStringForOption(_selectedOption!)
//             : widget.hintText,
//         readOnly: true,
//         focusNode: _focusNode,
//         onTap: () {
//           if (_focusNode.hasFocus) {
//             _focusNode.unfocus();
//           } else {
//             _focusNode.requestFocus();
//           }
//         },
//         validator: widget.validator,
//         fieldName: widget.fieldName,
//       ),
//     );
//   }
// }