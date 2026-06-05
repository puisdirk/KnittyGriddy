import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class SmallLabel extends StatelessWidget {
  final String label;
  final double width;

  const SmallLabel({
    required this.label,
    this.width = 50,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, 
      child: Align(
        alignment: Alignment.centerRight,
        child: Text('$label:', style: smallStyleBlue,)
      )
    );
  }
}