import 'dart:io';

import 'package:esolar_app/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentWidget extends StatelessWidget {
  final List<File> images;
  final ValueChanged<List<File>> onChanged;
  final ImagePicker pickerImage;
  final label;

  AttachmentWidget({
    super.key,
    required this.images,
    required this.label,
    required this.onChanged,
    ImagePicker? pickerImage,
  }) : pickerImage = pickerImage ?? ImagePicker();

  Future<void> selectImageGalery() async {
    final XFile? image = await pickerImage.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final newImages = List<File>.from(images);
      newImages.add(File(image.path));
      onChanged(newImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...images.map(
                  (image) => GestureDetector(
                    onTap: () {
                      final newImages = List<File>.from(images);
                      newImages.remove(image);
                      onChanged(newImages);
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(right: 5),
                      child: Image.file(image, fit: BoxFit.cover),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: selectImageGalery,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: 100,
                    height: 100,
                    child: Icon(Icons.add_photo_alternate_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Text(
            'Clique na imagem para a remover.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
