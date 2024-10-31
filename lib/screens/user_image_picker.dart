import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({required this.selectImage, super.key});
  final void Function(File file) selectImage;

  @override
  State<StatefulWidget> createState() => _UserImagePicker();
}

class _UserImagePicker extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker()
        .pickImage(source: source, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImage = File(pickedImage.path);
    });
    widget.selectImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              label: Text(
                "Take picture",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              icon: const Icon(Icons.image),
            ),
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              label: Text(
                "select image",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              icon: const Icon(Icons.image),
            )
          ],
        ),
      ],
    );
  }
}
