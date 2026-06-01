import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class SmallLabel extends StatelessWidget {
  final String label;

  const SmallLabel({
    required this.label,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50, 
      child: Align(
        alignment: Alignment.centerRight,
        child: Text('$label:', style: smallStyleBlue,)
      )
    );
  }
}