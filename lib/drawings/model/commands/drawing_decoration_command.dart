
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';

@immutable
abstract class DrawingDecorationCommand extends DrawingCommand {

  const DrawingDecorationCommand({
    required super.id,
    required super.label,
    super.errors = const[],
  });

}