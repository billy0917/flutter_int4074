import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    try {
      final XFile? xfile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (_) {
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final XFile? xfile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (_) {
      return null;
    }
  }

  /// Save image to app documents directory and return new path
  Future<String?> saveImageLocally(File imageFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newFile = await imageFile.copy('${imagesDir.path}/$fileName');
      return newFile.path;
    } catch (_) {
      return null;
    }
  }
}
