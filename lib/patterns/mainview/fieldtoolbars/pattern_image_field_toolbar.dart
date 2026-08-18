import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';

class PatternImageFieldToolbar extends StatefulWidget {
  final PatternImageField field;
  final void Function(PatternImageField newField) onChanged;
  
  const PatternImageFieldToolbar({
    required this.field,
    required this.onChanged,
    super.key
  });

  @override
  State<PatternImageFieldToolbar> createState() => _PatternImageFieldToolbarState();
}

class _PatternImageFieldToolbarState extends State<PatternImageFieldToolbar> {
  late PatternImageField field;

  @override
  void initState() {
    field = widget.field;

    super.initState();
  }

  void _updateField(PatternImageField newField) {
    setState(() => field = newField);
    widget.onChanged(newField);
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      Size res = ImageSizeGetter.getSizeResult(MemoryInput(imageData)).size;
      double aspectRatio = res.height / res.width;
      if (res.needRotate) {
        aspectRatio = res.width / res.height;
      }

      _updateField(field.copyWith(height: field.width * aspectRatio, imageData: imageData));
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          preferBelow: false,
          message: 'Set image',
          child: IconButton(
            onPressed: () async => await _selectImage(), 
            icon: const Icon(Icons.photo_camera),
          ),
        ),
      ],
    );
  }
}