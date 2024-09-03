import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadPicture {
  Future<Map<String,String?>?> pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage != null) {
      final image = File(returnedImage.path);
      final imageName = returnedImage.name;
      final base64Image = base64Encode(await image.readAsBytes());
      return {"base64Bytes":base64Image, "imageName": imageName};
    }
    return null;
  }

  Future<Map<String,String?>?> pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      final image = File(returnedImage.path);
      final imageName = returnedImage.name;
      final base64Image = base64Encode(await image.readAsBytes());
      return {"base64Bytes":base64Image, "imageName": imageName};
    }
    return null;
  }
}
