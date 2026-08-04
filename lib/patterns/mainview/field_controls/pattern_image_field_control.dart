import 'dart:typed_data';

import 'package:flutter/material.dart';

class PatternImageFieldControl extends StatelessWidget {
  final Uint8List? imageData;
  final double opacity;
  final void Function() onSelect;
  
  const PatternImageFieldControl({
    required this.imageData,
    required this.opacity,
    required this.onSelect,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return imageData == null || imageData!.isEmpty ? GestureDetector(onTap: onSelect, child: Container(color: Colors.transparent,)) :
    Builder(
      builder: (context) {
        Image image = Image.memory(imageData!);
        return GestureDetector(
          onTap: onSelect,
          child: FittedBox(
            child: SizedBox(
              width: image.width,
              height: image.height,
              child: Opacity(
                opacity: opacity == 0 ? 0 : opacity / 255,
                child: image
              ),
            ),
          ),
        );
      }
    )
    ;
  }
}