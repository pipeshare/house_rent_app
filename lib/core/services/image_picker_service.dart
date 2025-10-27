// lib/core/services/image_picker_service.dart
import 'dart:io';
import 'package:house_rent_app/core/errors/app_exception.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw AppException('Failed to pick image: ${e.toString()}');
    }
  }
}
