import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker imagePicker = ImagePicker();

  Future<List<XFile>> selectImages(List<XFile>? imageFileList) async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length: ${imageFileList!.length}");
    return imageFileList;
  }
}
