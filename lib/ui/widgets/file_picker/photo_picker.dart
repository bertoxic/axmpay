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
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final bool onlyCamera;
  const PhotoPicker({
    super.key,
    required this.context,
    required this.onChange,
    required this.controller,
    this.onlyCamera=false,
    this.validator,
    this.hintText,
    this.labelText,
    this.prefixIcon,
  });

  @override
  _PhotoPickerState createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> with AutomaticKeepAliveClientMixin {
  late UploadPicture picker;
  late TextEditingController _displayController;
  String? _currentFileName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: 'Select an image');
    picker = UploadPicture();
    widget.controller.addListener(_syncDisplayText);
  }

  void _syncDisplayText() {
    if (mounted) {
      setState(() {
        _displayController.text = _currentFileName ?? 'Select an image';
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncDisplayText);
    _displayController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.controller.text.isNotEmpty && _currentFileName == null) {
      _displayController.text = _currentFileName ?? 'Select an image';
    }
  }

  void _updateController(Map<String, String?>? data) {
    if (data != null && mounted) {
      setState(() {
        _currentFileName = data["imageName"];
        _displayController.text = _currentFileName ?? 'Select an image';
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
          backgroundColor: Colors.transparent,
          child: Container(
            height: 520.0.h,
            width: 400.0.w,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: AppText.title(
                      "Upload Image",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOptionButton(
                          icon: Icons.camera_enhance_rounded,
                          text: 'Take Photo',
                          subtext: 'Use your camera to capture a new photo',
                          onTap: _getImageFromCameraBase64,
                          context: context,
                        ),
                        !widget.onlyCamera?_buildOptionButton(
                          icon: Icons.photo_library_rounded,
                          text: 'Choose from Gallery',
                          subtext: 'Select an existing photo from your device',
                          onTap: _getImageFromGalleryBase64,
                          context: context,
                        ):SizedBox(),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                            'Please ensure the image is clear and well-lit',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      minimumSize: Size(double.infinity, 45.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
    required String subtext,
    required Function() onTap,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await onTap();
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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