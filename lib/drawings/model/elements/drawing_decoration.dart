
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/elements/drawing_element.dart';

@immutable
abstract class DrawingDecoration extends DrawingElement {

  const DrawingDecoration({
    required super.label,
  });

}