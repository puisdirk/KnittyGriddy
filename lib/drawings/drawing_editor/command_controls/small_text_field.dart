import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class SmallTextField extends StatelessWidget {
  final TextEditingController controller;
  final double width;

  const SmallTextField({
    required this.controller,
    required this.width,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        decoration: InputDecoration(
          constraints: const BoxConstraints.tightFor(height: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),         
        style: smallStyle,
        controller: controller,
      ),
    );
  }
}