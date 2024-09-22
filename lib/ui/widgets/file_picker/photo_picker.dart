import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';
import 'package:AXMPAY/ui/widgets/file_picker/photo_picker_controller.dart';
import 'package:flutter/material.dart';

class PhotoPicker extends StatefulWidget {
  final BuildContext context;
  final Function(String?) onChange;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String?  hintText;
  final String?  labelText;
  final Widget?  prefixIcon;

  const PhotoPicker({
    super.key,
    required this.context,
    required this.onChange,
    required this.controller,
    this.validator, this.hintText, this.labelText, this.prefixIcon,
  });

  @override
  _PhotoPickerState createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  late UploadPicture picker;
  String _displayText = 'Select an image';

  late TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: 'Select an image');
    picker = UploadPicture();
  }

  void _updateController(Map<String, String?>? data) {
    if (data != null) {
      setState(() {
        _displayController.text = data["imageName"] ?? 'Image selected';
        widget.controller.text = data["base64Bytes"] ?? '';
      });
      widget.onChange(widget.controller.text);
    }
  }

  Future<void> _getImageFromGalleryBase64() async {
    final data = await picker.pickImageFromGallery();
    _updateController(data);
  }

  Future<void> _getImageFromCameraBase64() async {
    final data = await picker.pickImageFromCamera();
    _updateController(data);
  }


  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 340.0.h,
            width: 400.0.w,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppText.title("UPLOAD FILES"),
                SizedBox(height: 40.0.h),
                _buildOptionButton(
                  icon: Icons.camera_enhance_sharp,
                  text: 'Select Image from Camera',
                  onTap: _getImageFromCameraBase64,
                ),
                SizedBox(height: 20.0.h),
                _buildOptionButton(
                  icon: Icons.photo_camera_back_sharp,
                  text: 'Select Image from Gallery',
                  onTap: _getImageFromGalleryBase64,
                ),
                SizedBox(height: 20.0.h),
                const Text('Please ensure the image is clear.'),
                SizedBox(height: 20.0.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border.all(width: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () async {
          await onTap();
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: widget.hintText,
      labelText: widget.labelText,
      prefixIcon: widget.prefixIcon,
      controller: _displayController,
      fieldName: "fieldName",
      readOnly: true,
      onTap: () => _showCustomDialog(context),
      obscureText: false,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.controller.text)
          : null,
    );
  }
}