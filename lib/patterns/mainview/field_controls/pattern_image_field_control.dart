import 'dart:typed_data';

import 'package:flutter/material.dart';

class PatternImageFieldControl extends StatefulWidget {
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
  State<PatternImageFieldControl> createState() => _PatternImageFieldControlState();
}

class _PatternImageFieldControlState extends State<PatternImageFieldControl> {
  late Image? image;

  @override
  void initState() {
    if (widget.imageData != null && widget.imageData!.isNotEmpty) {
      image = Image.memory(widget.imageData!);
    } else {
      image = null;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternImageFieldControl oldWidget) {
    if (widget.imageData != oldWidget.imageData) {
      if (widget.imageData != null && widget.imageData!.isNotEmpty) {
        image = Image.memory(widget.imageData!);
      } else {
        image = null;
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return image == null ? GestureDetector(onTap: widget.onSelect, child: Container(color: Colors.transparent,)) :
    GestureDetector(
      onTap: widget.onSelect,
        child: Opacity(
          opacity: widget.opacity == 0 ? 0 : widget.opacity / 255,
          child: image
      ),
    )
    ;
  }
}