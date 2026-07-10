import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/tape_command.dart';
import 'package:knitty_griddy/utils/constants.dart';

class TapeCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final TapeCommand command;
  final bool sorting;
  final bool editing;
  final void Function(TapeCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(TapeCommand newCommand) onChanged;

  const TapeCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<TapeCommandControl> createState() => _TapeCommandControlState();
}

class _TapeCommandControlState extends State<TapeCommandControl> {

  void lineLabelChanged(String newText) {
    if (widget.command.label != newText) {
      // No one will ever depend on us, so no need to call onChangeLabel
      widget.onChanged(widget.command.copyWith(label: newText));
    }
  }

    Widget createViewContent() {
    String content = '';

    switch (widget.command.tapeType) {
      case TapeType.betweenPoints: {
        String point1label = widget.drawing.commandLabelIncluded(widget.command.fromPointId);
        String point2label = widget.drawing.commandLabelIncluded(widget.command.toPointId);

        content += 'from $point1label to $point2label in ${widget.command.unit.shortLabel}';
      } break;
      case TapeType.line: {
        String lineLabel = widget.drawing.commandLabelIncluded(widget.command.lineId);
        content += 'line $lineLabel';
      } break;
      case TapeType.linesAndcurves: {
        String curveLabels = '';
        for (String curveId in widget.command.lineAndCurveIds) {
          curveLabels += '${widget.drawing.commandLabelIncluded(curveId)} , ';
        }
        content += 'lines and curves $curveLabels';
      }
    }

    return Row(
      children: [
        const Icon(Icons.straighten),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold,),
                TextSpan(text: ' $content', style: smallStyle)
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.straighten),
            hspacing,
            DropdownButton<TapeType>(
              key: GlobalObjectKey('${widget.command.id}-tapetype'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (TapeType tt in TapeType.values)
                  DropdownMenuItem(value: tt, child: Text(tt.label))
              ],
              value: widget.command.tapeType,
              onChanged: (value) {
                if (value != widget.command.tapeType) {
                  widget.onChanged(widget.command.copyWith(tapeType: value));
                }
              },
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(
              key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: lineLabelChanged,
            ),
          ],
        ),
        vspacing,
        if (widget.command.tapeType == TapeType.betweenPoints)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'From'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-from'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      if (widget.command.toPointId != origin.id)
                        DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                      for (PointCommand point in widget.drawing.pointsIncluded.where((p) => p.id != widget.command.toPointId))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != widget.command.fromPointId) {
                        widget.onChanged(widget.command.copyWith(fromPointId: value?? ''));
                      }
                    },
                    value: widget.command.fromPointId,
                  ),
                  hspacing,
                  const SmallLabel(label: 'To'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-to'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      if (widget.command.fromPointId != origin.id)
                        DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                      for (PointCommand point in widget.drawing.pointsIncluded.where((p) => p.id != widget.command.fromPointId))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != widget.command.toPointId) {
                        widget.onChanged(widget.command.copyWith(toPointId: value?? ''));
                      }
                    },
                    value: widget.command.toPointId,
                  ),
                ]
              ),
            ],
          ),
        if (widget.command.tapeType == TapeType.line)
          Row(
            children: [
              const SmallLabel(label: 'Line'),
              hspacing,
              DropdownButton<String>(
                key: GlobalObjectKey('${widget.command.id}-line'),
                isDense: true,
                autofocus: false,
                style: smallStyle,
                itemHeight: kMinInteractiveDimension,
                focusColor: Colors.transparent,
                underline: Container(),
                items: [
                  const DropdownMenuItem(value: '', child: Text('')),
                  for (LineCommand line in widget.drawing.linesIncluded)
                    DropdownMenuItem(value: line.id, child: Text(line.label))
                ], 
                onChanged: (value) {
                  if (value != widget.command.lineId) {
                    widget.onChanged(widget.command.copyWith(lineId: value?? ''));
                  }
                },
                value: widget.command.lineId,
              ),
            ],
          ),
        if (widget.command.tapeType == TapeType.linesAndcurves)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SmallLabel(label: 'Lines and Curves', width: 100,),
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
                          key: GlobalObjectKey('${widget.command.id}-linesandcurveschooser'),
                          isDense: true,
                          autofocus: false,
                          style: smallStyle,
                          itemHeight: kMinInteractiveDimension,
                          focusColor: Colors.transparent,
                          underline: Container(),
                          items: [
                            for (DrawingCommand cmd in widget.drawing.linesAndCurvesIncluded.where((c) => !widget.command.lineAndCurveIds.contains(c.id)))
                              DropdownMenuItem(value: cmd, child: Text(cmd.label)),
                          ], 
                          onChanged: (value) {
                            if (value != null) {
                              widget.onChanged(widget.command.copyWith(lineAndCurveIds: {...widget.command.lineAndCurveIds, value.id}));
                            }
                          }
                        ),
                        for (String id in widget.command.lineAndCurveIds)
                          Chip(
                            label: Text(widget.drawing.commandLabelIncluded(id), style: smallStyle,),
                            onDeleted: () => widget.onChanged(
                              widget.command.copyWith(lineAndCurveIds: widget.command.lineAndCurveIds.where((c) => c != id).toSet())
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          vspacing,
          Row(
            children: [
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Direction'),
                  hspacing,
                  DropdownButton<TapeDirectionType>(
                    key: GlobalObjectKey('${widget.command.id}-directiontype'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      for (TapeDirectionType tdt in TapeDirectionType.values)
                        DropdownMenuItem(value: tdt, child: Text(tdt.label))
                    ],
                    value: widget.command.directionType,
                    onChanged: (value) {
                      if (value != widget.command.directionType) {
                        widget.onChanged(widget.command.copyWith(directionType: value));
                      }
                    },
                  ),
                ],
              ),
            ],            
          ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Unit'),
            hspacing,
            DropdownButton<TapeUnit>(
              key: GlobalObjectKey('${widget.command.id}-unit'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (TapeUnit unit in TapeUnit.values)
                  DropdownMenuItem(value: unit, child: Text(unit.label)),
              ],
              onChanged: (value) {
                if (value != null && value != widget.command.unit) {
                  widget.onChanged(widget.command.copyWith(unit: value));
                }
              },
              value: widget.command.unit,
            ),
          ],
        ),
        if (widget.command.unit == TapeUnit.rows)
          vspacing,
        if (widget.command.unit == TapeUnit.rows)
          Row(
            children: [
              const SmallLabel(label: 'Rows gauge / 10 cm'),
              hspacing,
              SizedBox(
                width: 180,
                child: SpinBox(
                  key: GlobalObjectKey('${widget.command.id}-rowsgauge'),
                  textStyle: smallStyle,
                  onChanged: (value) {
                    if (value != widget.command.rowsGauge) {
                      widget.onChanged(widget.command.copyWith(rowsGauge: value));
                    }
                  },
                  min: 0.1,
                  max: 30,
                  decimals: 1,
                  step: 0.1,
                  value: widget.command.rowsGauge,
                ),
              ),
            ]
          ),
        if (widget.command.unit == TapeUnit.sts)
          vspacing,
        if (widget.command.unit == TapeUnit.sts)
          Row(
            children: [
              const SmallLabel(label: 'Stitch gauge / 10 cm'),
              hspacing,
              SizedBox(
                width: 180,
                child: SpinBox(
                  key: GlobalObjectKey('${widget.command.id}-stsgauge'),
                  textStyle: smallStyle,
                  onChanged: (value) {
                    if (value != widget.command.stitchesGauge) {
                      widget.onChanged(widget.command.copyWith(stitchesGauge: value));
                    }
                  },
                  min: 0.1,
                  max: 20,
                  decimals: 1,
                  step: 0.1,
                  value: widget.command.stitchesGauge,
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