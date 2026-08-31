import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/arrow_painter.dart';
import 'package:knitty_griddy/drawings/model/commands/colour_reference.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/common/pick_colour_reference_dialog.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:material_symbols_icons/symbols.dart';

class StylingCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final StylingCommand command;
  final bool sorting;
  final bool editing;
  final void Function(StylingCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(StylingCommand newCommand) onChanged;

  const StylingCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<StylingCommandControl> createState() => _StylingCommandControlState();
}

class _StylingCommandControlState extends State<StylingCommandControl> {

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      // No need to tell others, so no need to call onChangeLabel
      widget.onChanged(widget.command.copyWith(label: newText));
    }
  }

  Widget createViewContent() {
    String partLabels = '';

    if (widget.command.commandIds.isNotEmpty) {
      for (String id in widget.command.commandIds) {
        partLabels += widget.drawing.commandLabelIncluded(id);
        partLabels += ', ';
      }
    }

    return Row(
      children: [
        const Icon(Symbols.palette, weight: 500,),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold),
                TextSpan(text: partLabels.isEmpty ? ' for ???' : ' for $partLabels', style: smallStyle,)
              ]  
            ),
          )
        )
      ],
    );
  }

  Widget createEditContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.palette, weight: 500,),
            hspacing,
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label', width: 60,),
            hspacing,
            SmallTextField(
              key: ValueKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: labelChanged,
            ),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Colour', width: 60,),
            hspacing,
            GestureDetector(
              onTap: () async {
                ColourReference? newColorRef = await showDialog(
                  context: context,
                  builder: (context) {
                    return PickColourReferenceDialog(
                      drawing: widget.drawing,
                      initialColor: widget.command.colorRef,
                      knownColours: widget.drawing.knownColours,
                    );
                  }
                );
                if (newColorRef != null && newColorRef != widget.command.colorRef) {
                  widget.onChanged(widget.command.copyWith(colorRef: newColorRef));
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)), 
                        border: Border.all(color: Colors.grey)
                      ), 
                      width: 40, 
                      height: 30,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                            color: widget.command.color
                          ),
                          width: 34,
                          height: 24,
                        ),
                      ),
                    ),
                    hspacing,
                    if (widget.command.colorRef.measurementId.isNotEmpty)
                      Text('@${widget.command.colorRef.measurementLabel}', style: smallStyle,)
                  ],
                ),
              ),
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Line width', width: 60,),
            hspacing,
            SizedBox(
              width: 180,
              child: SpinBox(
                key: ValueKey('${widget.command.id}-linewidth'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.thickness) {
                    widget.onChanged(widget.command.copyWith(thickness: value));
                  }
                },
                min: 0.1,
                max: 10,
                decimals: 1,
                step: 0.1,
                value: widget.command.thickness,
              ),
            )
          ],
        ),
        vspacing,
        Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const SmallLabel(label: 'Line style', width: 60,),
                    hspacing,
                    DropdownButton<DashStyle>(
                      key: ValueKey('${widget.command.id}-dashstyle'),
                      icon: SizedBox(width: 60, height: 20, child: CustomPaint(painter: DashStylePainter(dashStyle: widget.command.dashStyle, command: widget.command),),),
                      isDense: true,
                      autofocus: false,
                      style: smallStyle,
                      itemHeight: kMinInteractiveDimension,
                      focusColor: Colors.transparent,
                      underline: Container(),
                      items: [
                        for (DashStyle ds in DashStyle.values)
                          DropdownMenuItem(
                            value: ds, 
                            child: SizedBox(
                              width: 60,
                              height: 20,
                              child: CustomPaint(painter: DashStylePainter(dashStyle: ds, command: widget.command),),
                            ),
                          ),
                      ], 
                      onChanged: (value) {
                        if (value != null && value != widget.command.dashStyle) {
                          widget.onChanged(widget.command.copyWith(dashStyle: value));
                        }
                      }
                    ),
                  ],
                ),
                vspacing,
                Row(
                  children: [
                    const SmallLabel(label: 'Start arrow', width: 60,),
                    hspacing,
                    DropdownButton<ArrowType>(
                      key: ValueKey('${widget.command.id}-startArrow'),
                      icon: SizedBox(width: 60, height: 20, child: CustomPaint(painter: ArrowChooserPainter(atStart: true, arrowType: widget.command.startArrow, command: widget.command),),),
                      isDense: true,
                      autofocus: false,
                      style: smallStyle,
                      itemHeight: kMinInteractiveDimension,
                      focusColor: Colors.transparent,
                      underline: Container(),
                      items: [
                        for (ArrowType arrow in ArrowType.values)
                          DropdownMenuItem(
                            value: arrow, 
                            child: SizedBox(
                              width: 60,
                              height: 20,
                              child: CustomPaint(painter: ArrowChooserPainter(atStart: true, arrowType: arrow, command: widget.command),),
                            ),
                          ),
                      ], 
                      onChanged: (value) {
                        if (value != null && value != widget.command.startArrow) {
                          widget.onChanged(widget.command.copyWith(startArrow: value));
                        }
                      }
                    ),
                  ]
                ),
                vspacing,
                Row(
                  children: [
                    const SmallLabel(label: 'End arrow', width: 60,),
                    hspacing,
                    DropdownButton<ArrowType>(
                      key: ValueKey('${widget.command.id}-endArrow'),
                      icon: SizedBox(width: 60, height: 20, child: CustomPaint(painter: ArrowChooserPainter(atStart: false, arrowType: widget.command.endArrow, command: widget.command),),),
                      isDense: true,
                      autofocus: false,
                      style: smallStyle,
                      itemHeight: kMinInteractiveDimension,
                      focusColor: Colors.transparent,
                      underline: Container(),
                      items: [
                        for (ArrowType arrow in ArrowType.values)
                          DropdownMenuItem(
                            value: arrow, 
                            child: SizedBox(
                              width: 60,
                              height: 20,
                              child: CustomPaint(painter: ArrowChooserPainter(atStart: false, arrowType: arrow, command: widget.command),),
                            ),
                          ),
                      ], 
                      onChanged: (value) {
                        if (value != null && value != widget.command.endArrow) {
                          widget.onChanged(widget.command.copyWith(endArrow: value));
                        }
                      }
                    ),
                  ],
                ),
              ],
            ),
            const Column(
              children: [ SizedBox(height: 100, width: 50, child: VerticalDivider(),)],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Arrow size:', style: smallStyle,),
                vspacing,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (ArrowSize arrowSize in ArrowSize.values)
                      FittedScale(
                        scale: 0.75,
                        child: Row(
                          children: [
                            Radio(
                              value: arrowSize, 
                              groupValue: widget.command.arrowSize, 
                              onChanged: (value) {
                                if (value != null && value != widget.command.arrowSize) {
                                  widget.onChanged(widget.command.copyWith(arrowSize: value));
                                }
                              },
                            ),
                            Text(arrowSize.label),
                          ],
                        ),
                      )
                  ],
                )
              ],
            )
          ],
        ),

        vspacing,
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SmallLabel(label: 'Elements'),
            vspacing,
            SizedBox(
              width: 320, height: 180,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(5))
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      DropdownButton<DrawingCommand>(
                        key: ValueKey('${widget.command.id}-chooser'),
                        isDense: true,
                        autofocus: false,
                        style: smallStyle,
                        itemHeight: kMinInteractiveDimension,
                        focusColor: Colors.transparent,
                        underline: Container(),
                        items: [
                          for (DrawingCommand cmd in widget.drawing.linesCurvesTapesAndRepeatsIncluded.where((c) => !widget.command.commandIds.contains(c.id)))
                            DropdownMenuItem(value: cmd, child: Text(cmd.label)),
                        ], 
                        onChanged: (value) {
                          if (value != null) {
                            widget.onChanged(widget.command.copyWith(commandIds: {...widget.command.commandIds, value.id}));
                          }
                        }
                      ),
                      for (String id in widget.command.commandIds)
                        Chip(
                          label: Text(widget.drawing.commandLabelIncluded(id), style: smallStyle,),
                          onDeleted: () => widget.onChanged(
                            widget.command.copyWith(commandIds: widget.command.commandIds.where((c) => c != id).toSet())
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}

class DashStylePainter extends CustomPainter {
  final DashStyle dashStyle;
  final StylingCommand command;

  const DashStylePainter({
    required this.dashStyle,
    required this.command
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = command.color..style = PaintingStyle.stroke..strokeWidth = command.thickness;
    if (dashStyle == DashStyle.full) {
      canvas.drawLine(Offset(4, size.height / 2) , Offset(size.width - 4, size.height / 2), p);
    } else {
      Path path = Path()..moveTo(4, size.height / 2)..lineTo(size.width - 4, size.height / 2);
      DashedPainter.pattern(dashPattern: dashStyle.dashPattern).paint(canvas, path, p);
    }
  }

  @override
  bool shouldRepaint(covariant DashStylePainter oldDelegate) {
    return oldDelegate.command != command || dashStyle != oldDelegate.dashStyle;
  }

}

class ArrowChooserPainter extends CustomPainter {
  final ArrowType arrowType;
  final StylingCommand command;
  final bool atStart;

  const ArrowChooserPainter({
    required this.arrowType, 
    required this.command, 
    required this.atStart
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = command.color..style = PaintingStyle.stroke..strokeWidth = command.thickness;

    Offset start = Offset(4, size.height / 2);
    Offset end = Offset(size.width - 4, size.height / 2);

    if (command.dashStyle == DashStyle.full) {
      canvas.drawLine(start, end, paint);
    } else {
      Path path = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
      DashedPainter.pattern(enableCaching: false, dashPattern: command.dashStyle.dashPattern).paint(canvas, path, paint);
    }

    StylingCommand partialCommand = command.copyWith(
      startArrow: atStart? arrowType : ArrowType.none,
      endArrow: atStart? ArrowType.none : arrowType,
    );

    ArrowPainter.paint(
      canvas: canvas, 
      styleCommand: partialCommand, 
      start: start, end: end, 
      paint: paint,
      arrowSizeOverride: partialCommand.arrowSize.size * 2,
    );
  }

  @override
  bool shouldRepaint(covariant ArrowChooserPainter oldDelegate) {
    return oldDelegate.arrowType != arrowType || oldDelegate.command != command || oldDelegate.atStart != atStart;
  }

}