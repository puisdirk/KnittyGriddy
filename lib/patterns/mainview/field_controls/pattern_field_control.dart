import 'dart:async';
import 'dart:math';

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
import 'package:knitty_griddy/utils/constants.dart';

class PatternFieldControl extends StatefulWidget {
  final KnittingPattern knittingPattern;
  final PatternField field;
  final ChangeNotifier? fieldChangeNotifier;
  final GlobalKey? editorKey;
  final bool selected;
  final bool viewMode;
  final void Function() onSelect;
  final void Function() onDelete;
  final void Function(PatternField changedField) onChanged;

  const PatternFieldControl({
    required this.knittingPattern,
    required this.field,
    required this.fieldChangeNotifier,
    this.editorKey,
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

  static const double kCornerResizerSize = 50;

  late double positionX;
  late double positionY;
  late double width;
  late double height;
  late double aspect;
  late bool isFixedAspect;
  late double minimumWidth;
  late double minimumHeight;
  late double patternWidth;
  late double patternHeight;
  late bool draggerAtBottom;

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
    patternWidth = widget.knittingPattern.pageLayout.pagewidth;
    patternHeight = widget.knittingPattern.pageLayout.pageheight * widget.knittingPattern.pageLayout.numberOfPages;

    draggerAtBottom = widget.field.positionY < kDraggerHeight;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternFieldControl oldWidget) {
    positionX = widget.field.positionX;
    positionY = widget.field.positionY;
    width = widget.field.width;
    height = widget.field.height;
    aspect = widget.field.height / widget.field.width;
    isFixedAspect = widget.field.fixedAspectRatio;
    minimumWidth = widget.field.minimumWidth;
    minimumHeight = widget.field.minimumHeight;
    patternWidth = widget.knittingPattern.pageLayout.pagewidth;
    patternHeight = widget.knittingPattern.pageLayout.pageheight * widget.knittingPattern.pageLayout.numberOfPages;

    draggerAtBottom = widget.field.positionY < kDraggerHeight;

    super.didUpdateWidget(oldWidget);
  }
  
  Widget createPatternFieldControl() {
    switch (widget.field.fieldType) {
      case PatternFieldType.texteditor:
        return PatternTextEditorFieldControl(
          knittingPattern: widget.knittingPattern,
          field: widget.field as PatternTextEditorField,
          fleatherController: widget.fieldChangeNotifier as FleatherController,
          editorKey: widget.editorKey as GlobalKey<EditorState>?,
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
          opacity: widget.field.opacity.toDouble(),
          onSelect: widget.onSelect,
        );
    }
  }

  Widget get _draggerRegion {
    return MouseRegion(
      cursor: widget.viewMode ? SystemMouseCursors.basic : SystemMouseCursors.grab,
      child: Draggable(
        feedback: Container(
          color: Colors.transparent,
          child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
        ),
        onDragStarted: () => widget.onSelect(),
        onDragUpdate: (details) {
          setState(() {
            positionX = min(max(positionX + details.delta.dx, 0), patternWidth - width);
            positionY = min(max(positionY + details.delta.dy, 0), patternHeight - height);
          });
        },
        onDragEnd: (_) {
          if (positionY < kDraggerHeight && !draggerAtBottom) {
            setState(() => draggerAtBottom = true);
          } else if (positionY > kDraggerHeight && draggerAtBottom) {
            setState(() => draggerAtBottom = false);
          }

          widget.onChanged(widget.field.abstractCopyWith(
            positionX: positionX, 
            positionY: positionY
          ));
        },
        child: Visibility(
          visible: !widget.viewMode, maintainSize: true,maintainAnimation: true,maintainState: true,
          child: GestureDetector(
            onTap: widget.onSelect,
            child: SizedBox(
              width: width,
              height: kDraggerHeight,
              child: Container(
                color: widget.selected ? Colors.green.shade700.withAlpha(50) : Colors.grey.shade400.withAlpha(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    hspacing,
                    if (widget.field.fieldType == PatternFieldType.drawing && (widget.field as PatternDrawingField).drawing != null && !(widget.field as PatternDrawingField).drawing!.valid)
                      const Tooltip(
                        message: 'Drawing is not valid',
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.warning_amber, size: 16, color: Colors.red,),
                        )
                      ),
                    const Spacer(),
                    if (width > 102)
                      Text(widget.field.fieldType.label),
                    const Spacer(),
                    if (widget.field.fieldType == PatternFieldType.drawing && (widget.field as PatternDrawingField).drawing != null && !(widget.field as PatternDrawingField).drawing!.valid)
                      const Spacer(),
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
                    hspacing,
                  ]
                ),
              ),
            ),
          ),
        )
      ),
    );
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
            ),
          ),
          child: GestureDetector(
            onTap: widget.onSelect,
            child: Stack(
              children: [
                // Pattern control
                Positioned(
                  left: widget.field.leftpadding + widget.field.contentOffsetX,
                  top: widget.field.contentOffsetY,
                  child: SizedBox(
                    width: width - (2 * widget.field.padding),
                    height: height - widget.field.bottompadding,
                    child: createPatternFieldControl()
                  )
                ),
                // top-side resizer
                Positioned(
                  left: kCornerResizerSize,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    child: SizedBox(
                      width: width - (2 * kCornerResizerSize),
                      height: kResizerShortSide,
                      child: Draggable(
                        feedback: Container(
                          color: Colors.transparent,
                          child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                        ),
                        onDragStarted: () => widget.onSelect(),
                        onDragUpdate: (details) {
                          double newPositionY = max(positionY + details.delta.dy, 0);
                          double newHeight = max((positionY + height) - newPositionY, minimumHeight);

                          double newWidth = width;
                          if (isFixedAspect) {
                            newWidth = min(aspect * newHeight, patternWidth);
                            newHeight = aspect * newWidth;
                          }

                          setState(() {
                            height = newHeight;
                            positionY = newPositionY;
                            width = newWidth;
                          });
                        },
                        onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionY: positionY, height: height, width: width)),
                        child: Container(color: Colors.transparent,),
                      ),
                    ),
                  )
                ),
                // Top-left resizer
                Positioned(
                  top: 0, left: 0,
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
                        onDragStarted: () => widget.onSelect,
                        onDragUpdate: (details) {
                          double newPositionX = max(positionX + details.delta.dx, 0);
                          double newPositionY = max(positionY + details.delta.dy, 0);
                          double newWidth = max((positionX + width) - newPositionX, minimumWidth);
                          double newHeight = max((positionY + height) - newPositionY, minimumHeight);

                          if (isFixedAspect) {
                            newHeight = aspect * newWidth;
                          }

                          if (newPositionX + newWidth > patternWidth) {
                            newPositionX = patternWidth - newWidth;
                          }

                          if (positionY + newHeight > patternHeight) {
                            newPositionY = patternHeight - newHeight;
                          }

                          setState(() {
                            positionX = newPositionX;
                            positionY = newPositionY;
                            width = newWidth;
                            height = newHeight;
                          });
                        },
                        onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionX: positionX, positionY: positionY, width: width, height: height)),
                        child: Container(color: Colors.transparent,),
                      ),
                    ),
                  )
                ),
                // Left-top resizer
                Positioned(
                  top: 0, left: 0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpLeftDownRight,
                    child: SizedBox(
                      width: kResizerShortSide,
                      height: kCornerResizerSize,
                      child: Draggable(
                        feedback: Container(
                          color: Colors.transparent,
                          child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                        ),
                        onDragStarted: () => widget.onSelect,
                        onDragUpdate: (details) {
                          double newPositionX = max(positionX + details.delta.dx, 0);
                          double newPositionY = max(positionY + details.delta.dy, 0);
                          double newWidth = max((positionX + width) - newPositionX, minimumWidth);
                          double newHeight = max((positionY + height) - newPositionY, minimumHeight);

                          if (isFixedAspect) {
                            newHeight = aspect * newWidth;
                          }

                          if (newPositionX + newWidth > patternWidth) {
                            newPositionX = patternWidth - newWidth;
                          }

                          if (positionY + newHeight > patternHeight) {
                            newPositionY = patternHeight - newHeight;
                          }

                          setState(() {
                            positionX = newPositionX;
                            positionY = newPositionY;
                            width = newWidth;
                            height = newHeight;
                          });
                        },
                        onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionX: positionX, positionY: positionY, width: width, height: height)),
                        child: Container(color: Colors.transparent,),
                      ),
                    ),
                  )                  
                ),
                // Top-right resizer
                Positioned(
                  top: 0, right: 0,
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
                        onDragStarted: () => widget.onSelect,
                        onDragUpdate: (details) {
                          double newWidth = max(width + details.delta.dx, minimumWidth);
                          double newPositionY = max(positionY + details.delta.dy, 0);
                          double newHeight = max((positionY + height) - newPositionY, minimumHeight);

                          if (isFixedAspect) {
                            newWidth = aspect * newHeight;
                          }

                          if (positionX + newWidth > patternWidth) {
                            newWidth = patternWidth - positionX;
                            if (isFixedAspect) {
                              newHeight = aspect * newWidth;
                            }
                          }

                          if (positionY + newHeight > patternHeight) {
                            newPositionY = patternHeight - newHeight;
                          }

                          setState(() {
                            width = newWidth;
                            height = newHeight;
                            positionY = newPositionY;
                          });
                        },
                        onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionY: positionY, width: width, height: height)),
                        child: Container(color: Colors.transparent,),
                      ),
                    ),
                  )
                ),
                // Right-top resizer
                Positioned(
                  top: 0, right: 0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpRightDownLeft,
                    child: SizedBox(
                      width: kResizerShortSide,
                      height: kCornerResizerSize,
                      child: Draggable(
                        feedback: Container(
                          color: Colors.transparent,
                          child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                        ),
                        onDragStarted: () => widget.onSelect,
                        onDragUpdate: (details) {
                          double newWidth = max(width + details.delta.dx, minimumWidth);
                          double newPositionY = max(positionY + details.delta.dy, 0);
                          double newHeight = max((positionY + height) - newPositionY, minimumHeight);

                          if (isFixedAspect) {
                            newWidth = aspect * newHeight;
                          }

                          if (positionX + newWidth > patternWidth) {
                            newWidth = patternWidth - positionX;
                            if (isFixedAspect) {
                              newHeight = aspect * newWidth;
                            }
                          }
                          if (positionY + newHeight > patternHeight) {
                            newPositionY = patternHeight - newHeight;
                          }

                          setState(() {
                            width = newWidth;
                            height = newHeight;
                            positionY = newPositionY;
                          });
                        },
                        onDragEnd: (_) => widget.onChanged(widget.field.abstractCopyWith(positionY: positionY, width: width, height: height)),
                        child: Container(color: Colors.transparent,),
                      ),
                    ),
                  )                  
                ),
                // right-side resizer
                Positioned(
                  right: 0,
                  top: kCornerResizerSize,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: SizedBox(
                      width: kResizerShortSide, 
                      height: height - (2 * kCornerResizerSize), 
                      child: Draggable(
                        feedback: Container(
                          color: Colors.transparent,
                          child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                        ),
                        onDragStarted: () => widget.onSelect(),
                        onDragUpdate: (details) {
                          double newWidth = min(max(width + details.delta.dx, minimumWidth), patternWidth - positionX);
                          double newHeight = height;
                          if (isFixedAspect) {
                            newHeight = min(aspect * newWidth, patternHeight - positionY);
                            newWidth = aspect * newHeight;
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
                  top: kCornerResizerSize,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: SizedBox(
                      width: kResizerShortSide, 
                      height: widget.field.height - (2 * kCornerResizerSize), 
                      child: Draggable(
                        feedback: Container(
                          color: Colors.transparent,
                          child: const SizedBox(width: kResizerShortSide, height: kResizerShortSide,),
                        ),
                        onDragStarted: () => widget.onSelect(),
                        onDragUpdate: (details) {
                          double newWidth = max(width - details.delta.dx, minimumWidth);
                          double newPositionX = min(positionX + details.delta.dx, patternWidth - newWidth);
                          double newHeight = height;
                          if (isFixedAspect) {
                            newHeight = aspect * newWidth;
                          }
                          if (newPositionX < 0) {
                            newWidth += newPositionX;
                            newPositionX = 0;
                            if (isFixedAspect) {
                              newHeight = aspect * newWidth;
                            }
                          }
          
                          if (positionY + newHeight > patternHeight) {
                            newHeight = patternHeight - positionY;
                            if (isFixedAspect) {
                              newWidth = aspect * newHeight;
                            }
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
                          double newHeight = min(max(height + details.delta.dy, minimumHeight), patternHeight - positionY);
                          double newWidth = width;
                          if (isFixedAspect) {
                            newWidth = min(aspect * newHeight, patternWidth);
                            newHeight = aspect * newWidth;
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
                            newHeight = aspect * newWidth;
                          } else {
                            newHeight = max(height + details.delta.dy, minimumHeight);
                          }
          
                          if (newPositionX < 0) {
                            newWidth += newPositionX;
                            newPositionX = 0;
                            if (isFixedAspect) {
                              newHeight = aspect * newWidth;
                            }
                          }
          
                          if (positionY + newHeight > patternHeight) {
                            newHeight = patternHeight - positionY;
                            if (isFixedAspect) {
                              newWidth = aspect * newHeight;
                            }
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
                            newHeight = aspect * newWidth;
                          } else {
                            newHeight = max(height + details.delta.dy, minimumHeight);
                          }
          
                          if (newPositionX < 0) {
                            newWidth += newPositionX;
                            newPositionX = 0;
                            if (isFixedAspect) {
                              newHeight = aspect * newWidth;
                            }
                          }
          
                          if (positionY + newHeight > patternHeight) {
                            newHeight = patternHeight - positionY;
                            if (isFixedAspect) {
                              newWidth = aspect * newHeight;
                            }
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
                          double newWidth = min(max(width + details.delta.dx, minimumWidth), patternWidth - positionX);
                          double newHeight = height;
                          if (isFixedAspect) {
                            newHeight = aspect * newWidth;
                          } else {
                            newHeight = max(height + details.delta.dy, minimumHeight);
                          }
          
                          if (newHeight > patternHeight - positionY) {
                            newHeight = patternHeight - positionY;
                            if (isFixedAspect) {
                              newWidth = aspect * newHeight;
                            }
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
                          double newWidth = min(max(width + details.delta.dx, minimumWidth), patternWidth - positionX);
                          double newHeight = height;
                          if (isFixedAspect) {
                            newHeight = aspect * newWidth;
                          } else {
                            newHeight = max(height + details.delta.dy, minimumHeight);
                          }
          
                          if (newHeight > patternHeight - positionY) {
                            newHeight = patternHeight - positionY;
                            if (isFixedAspect) {
                              newWidth = aspect * newHeight;
                            }
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
                // drag region
                Positioned(
                  top: draggerAtBottom ? null : kResizerShortSide,
                  bottom: draggerAtBottom ? kResizerShortSide : null,
                  left: kResizerShortSide,
                  right: kResizerShortSide,
                  child: _draggerRegion
                )
              ],
            ),
          ),
        ),
      ));
  }
}