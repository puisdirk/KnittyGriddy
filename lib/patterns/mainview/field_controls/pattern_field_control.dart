import 'dart:async';
import 'dart:math';

import 'package:fitted_scale/fitted_scale.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_chart_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_drawing_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_image_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_panel_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_text_editor_field_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';

class PatternFieldControl extends StatefulWidget {
  final KnittingPattern knittingPattern;
  final PatternField field;
  final ChangeNotifier? fieldChangeNotifier;
  final bool selected;
  final bool viewMode;
  final void Function() onSelect;
  final void Function() onDelete;
  final void Function(PatternField changedField) onChanged;

  const PatternFieldControl({
    required this.knittingPattern,
    required this.field,
    required this.fieldChangeNotifier,
    required this.selected,
    required this.viewMode,
    required this.onSelect,
    required this.onDelete,
    required this.onChanged,
    super.key
  });

  @override
  State<PatternFieldControl> createState() => _PatternFieldControlState();
}

class _PatternFieldControlState extends State<PatternFieldControl> {

  static const double kDraggerHeight = 20;
  static const double kResizerShortSide = 5;
  static const double kCornerResizerSize = 50;

  late double positionX;
  late double positionY;
  late double width;
  late double height;
  late double aspect;
  late bool isFixedAspect;
  late double minimumWidth;
  late double minimumHeight;

  @override
  void initState() {
    positionX = widget.field.positionX;
    positionY = widget.field.positionY;
    width = widget.field.width;
    height = widget.field.height;
    aspect = height / width;
    isFixedAspect = widget.field.fixedAspectRatio;
    minimumWidth = widget.field.minimumWidth;
    minimumHeight = widget.field.minimumHeight;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternFieldControl oldWidget) {
    positionX = widget.field.positionX;
    positionY = widget.field.positionY;
    width = widget.field.width;
    height = widget.field.height;
    aspect = height / width;
    isFixedAspect = widget.field.fixedAspectRatio;
    minimumWidth = widget.field.minimumWidth;
    minimumHeight = widget.field.minimumHeight;

    super.didUpdateWidget(oldWidget);
  }
  

  Widget createPatternFieldControl() {
    switch (widget.field.fieldType) {
      case PatternFieldType.texteditor:
        return PatternTextEditorFieldControl(
          knittingPattern: widget.knittingPattern,
          field: widget.field as PatternTextEditorField,
          fleatherController: widget.fieldChangeNotifier as FleatherController,
          selected: widget.selected,
          viewMode: widget.viewMode,
          onChanged: widget.onChanged,
          onSelect: widget.onSelect,
        );
      case PatternFieldType.knittingchart:
        return PatternChartFieldControl(
          opacity: widget.field.opacity.toDouble(),
          chart: (widget.field as PatternChartField).chart,
          viewSettings: (widget.field as PatternChartField).viewSettings,
          selected: widget.selected,
          onSelect: widget.onSelect,
        );
      case PatternFieldType.drawing: {
        Drawing? drawing = (widget.field as PatternDrawingField).drawing;
        if (drawing != null && !drawing.validated) {
          drawing = drawing.validate();
        }
        return PatternDrawingFieldControl(
          opacity: widget.field.opacity.toDouble(),
          drawing: drawing, 
          selected: widget.selected, 
          onSelect: widget.onSelect
        );
      }
      case PatternFieldType.image:
        return PatternImageFieldControl(
          imageData: (widget.field as PatternImageField).imageData, 
          opacity: widget.field.opacity.toDouble(), 
          onSelect: widget.onSelect
        );
      case PatternFieldType.panel:
        return PatternPanelFieldControl(
          panelStyle: (widget.field as PatternPanelField).style,
          onSelect: widget.onSelect,
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Positioned(
      left: positionX,
      top: positionY,
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: widget.viewMode ? Colors.transparent : widget.selected ? Colors.greenAccent.shade700 : Colors.grey,
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top drag region
              MouseRegion(
                cursor: widget.viewMode ? SystemMouseCursors.basic : SystemMouseCursors.grab,
                child: Draggable(
                  feedback: Container(
                    color: Colors.transparent,
                    child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                  ),
                  onDragStarted: () => widget.onSelect(),
                  onDragUpdate: (details) {
                    setState(() {
                      positionX = max(positionX + details.delta.dx, 0);
                      positionY = max(positionY + details.delta.dy, 0);
                    });
                  },
                  onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(
                      positionX: positionX, 
                      positionY: positionY
                    )),
                  child: Visibility(
                    visible: !widget.viewMode,maintainSize: true,maintainAnimation: true,maintainState: true,
                    child: GestureDetector(
                      onTap: widget.onSelect,
                      child: SizedBox(
                        width: width,
                        height: kDraggerHeight,
                        child: Container(
                          color: Colors.grey.shade400.withAlpha(50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.field.fieldType != PatternFieldType.panel)
                              Material(
                                child: FittedScale(
                                  scale: .5,
                                  child: Slider(
                                    min: 0,
                                    max: 255,
                                    value: widget.field.opacity as double, 
                                    onChanged: (value) {
                                      widget.onChanged(widget.field.abstractCopyWith(opacity: value.toInt()));
                                    }
                                  ),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onSelect();
                                    Timer(const Duration(milliseconds: 10), () => widget.onDelete());
                                  },
                                  child: const Icon(Icons.delete_outlined, size: 16,)
                                )
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onSelect,
                  child: Stack(
                    children: [
                      // Pattern control
                      Positioned(
                        left: kResizerShortSide,
                        child: SizedBox(
                          width: width - (2 * kResizerShortSide),
                          height: height - kDraggerHeight - kResizerShortSide,
                          child: createPatternFieldControl()
                        )
                      ),
                      // right-side resizer
                      Positioned(
                        right: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeLeftRight,
                          child: SizedBox(
                            width: kResizerShortSide, 
                            height: height - kCornerResizerSize - kDraggerHeight, 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newWidth = max(width + details.delta.dx, minimumWidth);
                                double newHeight = height;
                                if (isFixedAspect) {
                                  newHeight += aspect * details.delta.dx;
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            )
                          ),
                        )
                      ),
                      // left-side resizer
                      Positioned(
                        left: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeLeftRight,
                          child: SizedBox(
                            width: kResizerShortSide, 
                            height: widget.field.height - kCornerResizerSize - kDraggerHeight, 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newWidth = max(width - details.delta.dx, minimumWidth);
                                double newPositionX = positionX + details.delta.dx;
                                double newHeight = height;
                                if (isFixedAspect) {
                                  newHeight -= aspect * details.delta.dx;
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                  positionX = newPositionX;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionX: positionX, width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            ),
                          )
                        )
                      ),
                      // bottom resizer
                      Positioned(
                        bottom: 0,
                        left: kCornerResizerSize, 
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeUpDown,
                          child: SizedBox(
                            height: kResizerShortSide, 
                            width: width - (2 * kCornerResizerSize), 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newHeight = max(height + details.delta.dy, minimumHeight);
                                double newWidth = width;
                                if (isFixedAspect) {
                                  newWidth += aspect * details.delta.dy;
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            ),
                          )
                        )
                      ),
                      // bottom-left resizer
                      Positioned(
                        bottom: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeUpRightDownLeft,
                          child: SizedBox(
                            height: kCornerResizerSize, 
                            width: kResizerShortSide, 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newWidth = max(width - details.delta.dx, minimumWidth);
                                double newPositionX = positionX + details.delta.dx;
                                double newHeight = height;
                                if (isFixedAspect) {
                                  newHeight -= aspect * details.delta.dx;
                                } else {
                                  newHeight = max(height + details.delta.dy, minimumHeight);
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                  positionX = newPositionX;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionX: positionX, width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            ),
                          ),
                        )
                      ),
                      // left-bottom resizer
                      Positioned(
                        bottom: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeUpRightDownLeft,
                          child: SizedBox(
                            width: kCornerResizerSize, 
                            height: kResizerShortSide, 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newWidth = max(width - details.delta.dx, minimumWidth);
                                double newPositionX = positionX + details.delta.dx;
                                double newHeight = height;
                                if (isFixedAspect) {
                                  newHeight -= aspect * details.delta.dx;
                                } else {
                                  newHeight = max(height + details.delta.dy, minimumHeight);
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                  positionX = newPositionX;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionX: positionX, width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            ),
                          ),
                        )
                      ),
                      // bottom-right resizer
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeUpLeftDownRight,
                          child: SizedBox(
                            height: kCornerResizerSize, 
                            width: kResizerShortSide, 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newWidth = max(width + details.delta.dx, minimumWidth);
                                double newHeight = height;
                                if (isFixedAspect) {
                                  newHeight += aspect * details.delta.dx;
                                } else {
                                  newHeight = max(height + details.delta.dy, minimumHeight);
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            ),
                          ),
                        )
                      ),
                      // right-bottom resizer
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeUpLeftDownRight,
                          child: SizedBox(
                            width: kCornerResizerSize, 
                            height: kResizerShortSide, 
                            child: Draggable(
                              feedback: Container(
                                color: Colors.transparent,
                                child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                              ),
                              onDragStarted: () => widget.onSelect(),
                              onDragUpdate: (details) {
                                double newWidth = max(width + details.delta.dx, minimumWidth);
                                double newHeight = height;
                                if (isFixedAspect) {
                                  newHeight += aspect * details.delta.dx;
                                } else {
                                  newHeight = max(height + details.delta.dy, minimumHeight);
                                }
                                setState(() {
                                  width = newWidth;
                                  height = newHeight;
                                });
                              },
                              onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(width: width, height: height)),
                              child: Container(color: Colors.transparent,)
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),
        ),
      ));
  }
}