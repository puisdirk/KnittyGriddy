import 'package:flutter/material.dart';

class ColourWell extends StatelessWidget {
  final bool selected;
  final Color color;
  final void Function()? onTap;

  static const double kColourWellWidth = 40;
  static const double kColourWellHeight = 30;

  const ColourWell({
    required this.selected,
    required this.color,
    this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: selected ? Colors.green.shade500 : Colors.grey, width: 2)
          ), 
          width: kColourWellWidth, 
          height: kColourWellHeight,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                color: color
              ),
              width: kColourWellWidth - 6,
              height: kColourWellHeight - 6,
            ),
          ),
        ),
      ),
    );
  }
}