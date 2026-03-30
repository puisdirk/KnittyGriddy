
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';

class AddStitchColumnIndicator extends StatefulWidget {
  
  final void Function() onTap;
  
  const AddStitchColumnIndicator({
    required this.onTap,
    super.key
  });

  @override
  State<AddStitchColumnIndicator> createState() => _AddStitchColumnIndicatorState();
}

class _AddStitchColumnIndicatorState extends State<AddStitchColumnIndicator> {
  
  bool transparent = true;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: stitchCellWidth,
      height: stitchCellHeight,
      child: MouseRegion(
        onHover: (_) { if (transparent) {setState(() => transparent = false);}},
        onExit: (_) => setState(() => transparent = true),
        child: IconButton.outlined(
          onPressed: transparent ? null : widget.onTap,
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}