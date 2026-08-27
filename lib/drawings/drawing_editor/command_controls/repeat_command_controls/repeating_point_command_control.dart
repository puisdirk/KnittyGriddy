import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepeatingPointCommandControl extends StatelessWidget {

  final AbstractDrawing drawing;
  final RepeatingPointCommand command;
  final RepeatCommand repeatContext;
  final bool sorting;
  final bool editing;
  final void Function(RepeatingPointCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatingPointCommand newCommand) onChanged;

  const RepeatingPointCommandControl({
    required this.drawing,
    required this.command,
    required this.repeatContext,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });


  void pointLabelChanged(String newText) {
    if (command.label != newText) {
      onChangeLabel(
        command.copyWith(
          label: newText,
          wrappedPoint: command.wrappedPoint.copyWith(label: newText),
        ),
        command.label);
    }
  }

  void distanceFormulaChanged(String formula) {
    if (command.wrappedPoint.distanceFormula != formula) {
      onChanged(command.copyWith(
        wrappedPoint: command.wrappedPoint.copyWith(
          distanceFormula: formula
        )
      ));
    }
  }

  void directionAngleFormulaChanged(String formula) {
    if (command.wrappedPoint.directionAngleFormula != formula) {
      onChanged(command.copyWith(
        wrappedPoint: command.wrappedPoint.copyWith(
          directionAngleFormula: formula
        )
      ));
    }
  }

  void onLineFractionFormulaChanged(String formula) {
    if (command.wrappedPoint.onLineFractionFormula != formula) {
      onChanged(command.copyWith(
        wrappedPoint: command.wrappedPoint.copyWith(
          onLineFractionFormula: formula
        )
      ));
    }
  }

  void onCurveFractionFormulaChanged(String formula) {
    if (command.wrappedPoint.onCurveFractionFormula != formula) {
      onChanged(command.copyWith(
        wrappedPoint: command.wrappedPoint.copyWith(
          onCurveFractionFormula: formula
        )
      ));
    }
  }

  Widget createViewContent() {
    String content = ' ';

    if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.relativeToPoint) {
      String distanceLabel = '???';
      if (command.wrappedPoint.distanceFormula.isNotEmpty) {
        distanceLabel = command.wrappedPoint.distanceFormula;
      }

      String directionLabel = '???';
      if (command.wrappedPoint.direction == RelativePointDirection.angle) {
        String angleFormulaLabel = '???';
        if (command.wrappedPoint.directionAngleFormula.isNotEmpty) {
          angleFormulaLabel = command.wrappedPoint.directionAngleFormula;
        }
        directionLabel = 'at angle $angleFormulaLabel';
      } else {
        directionLabel = command.wrappedPoint.direction.label;
      }

      String fromPointLabel = 
        drawing.commandLabelIncluded(command.wrappedPoint.fromPointId, repeatContext: repeatContext);

      content += '$distanceLabel $directionLabel of $fromPointLabel';

    } else if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.onLine) {
      String onlineLabel = drawing.commandLabelIncluded(command.wrappedPoint.onLineId, repeatContext: repeatContext);

      String fractionLabel = '???';
      if (command.wrappedPoint.onLineFractionFormula.isNotEmpty) {
        fractionLabel = command.wrappedPoint.onLineFractionFormula;
      }

      content += 'on line $onlineLabel at $fractionLabel';
    } else if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.onCurve) {
      String oncurveLabel = drawing.commandLabelIncluded(command.wrappedPoint.onCurveId, repeatContext: repeatContext);

      String fractionLabel = '???';
      if (command.wrappedPoint.onCurveFractionFormula.isNotEmpty) {
        fractionLabel = command.wrappedPoint.onCurveFractionFormula;
      }

      content += 'on curve $oncurveLabel at $fractionLabel';
    } else if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.onIntersection) {
      String l1label = drawing.commandLabelIncluded(command.wrappedPoint.intersectionLine1Id, repeatContext: repeatContext);
      String l2label = drawing.commandLabelIncluded(command.wrappedPoint.intersectionLine2Id, repeatContext: repeatContext);

      content += 'on intersection of $l1label and $l2label';
    }

    return Row(
      children: [
        const Icon(Symbols.line_start_circle),
        hspacing,
        SizedBox(
          width: command.hasErrors ? repeatcommandControlViewWidth : repeatcommandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: command.label, style: smallStyleBold),
                TextSpan(text: content, style: smallStyle,)
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
            const Icon(Symbols.line_start_circle),
            hspacing,
            DropdownButton<PointDefinitionType>(
              key: ValueKey('${command.id}-pdt'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (PointDefinitionType pdt in PointDefinitionType.values)
                  DropdownMenuItem(value: pdt, child: Text(pdt.label))
              ],
              value: command.wrappedPoint.pointDefinitionType,
              onChanged: (value) {
                if (value != command.wrappedPoint.pointDefinitionType) {
                  onChanged(
                    command.copyWith(
                      wrappedPoint: command.wrappedPoint.copyWith(
                        pointDefinitionType: value
                      )
                    )
                  );
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
              key: ValueKey('${command.id}-${command.version}-label'),
              initialText: command.label,
              width: 100,
              onTextChanged: pointLabelChanged,
            ),
          ],
        ),
        vspacing,
        if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.relativeToPoint)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Distance'),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-${command.version}-dist'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    width: 200, 
                    formula: command.wrappedPoint.distanceFormula,
                    onFormulaChanged: distanceFormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Direction'),
                  hspacing,
                  DropdownButton<RelativePointDirection>(
                    key: ValueKey('${command.id}-dir'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      for (RelativePointDirection direction in RelativePointDirection.values)
                        DropdownMenuItem(value: direction, child: Text(direction.label)),
                    ], 
                    onChanged: (value) {
                      if (value != command.wrappedPoint.direction) {
                        onChanged(
                          command.copyWith(
                            wrappedPoint: command.wrappedPoint.copyWith(
                              direction: value
                            )
                          )
                        );
                      }
                    },
                    value: command.wrappedPoint.direction,
                  ),
                  hspacing,
                  if (command.wrappedPoint.direction == RelativePointDirection.angle)
                    FormulaFieldControl(
                      key: ValueKey('${command.id}-${command.version}-angle'),
                      drawing: drawing,
                      repeatContext: repeatContext,
                      excludeLabels: [command.label],
                      formula: command.wrappedPoint.directionAngleFormula,
                      width: 120, 
                      onFormulaChanged: directionAngleFormulaChanged,
                      unitLabel: ' °',
                    ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Of'),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-of'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),

                      for (RepeatingPointCommand point in repeatContext.points.where((p) => p.id != command.id))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),

                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),

                      for (PointCommand point in drawing.pointsIncluded.where((p) => p.id != command.id))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != command.wrappedPoint.fromPointId) {
                        onChanged(command.copyWith(
                          wrappedPoint: command.wrappedPoint.copyWith(
                            fromPointId: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedPoint.fromPointId,
                  )
                ]
              ),
            ]
          ),
        if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.onLine)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Line'),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-line'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      
                      for (RepeatingLineCommand line in repeatContext.lines)
                        DropdownMenuItem(value: line.id, child: Text(line.label)),

                      for (LineCommand line in drawing.linesIncluded)
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != command.wrappedPoint.onLineId) {
                        onChanged(command.copyWith(
                          wrappedPoint: command.wrappedPoint.copyWith(
                            onLineId: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedPoint.onLineId,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Fraction'),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-linefrac'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedPoint.onLineFractionFormula,
                    width: 200, 
                    onFormulaChanged: onLineFractionFormulaChanged,
                  )
                ],
              )
            ],
          ),
        if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.onCurve)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Curve'),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-curve'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),

                      for (RepeatingCurveCommand curve in repeatContext.curves)
                        DropdownMenuItem(value: curve.id, child: Text(curve.label)),

                      for (CurveCommand curve in drawing.curvesIncluded)
                        DropdownMenuItem(value: curve.id, child: Text(curve.label))
                    ], 
                    onChanged: (value) {
                      if (value != command.wrappedPoint.onCurveId) {
                        onChanged(command.copyWith(
                          wrappedPoint: command.wrappedPoint.copyWith(
                            onCurveId: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedPoint.onCurveId,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Fraction'),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-curvefrac'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedPoint.onCurveFractionFormula,
                    width: 200, 
                    onFormulaChanged: onCurveFractionFormulaChanged,
                  )
                ],
              )
            ],
          ),
        if (command.wrappedPoint.pointDefinitionType == PointDefinitionType.onIntersection)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Line 1'),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-line1'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),

                      for (RepeatingLineCommand line in repeatContext.lines.where((l) => l.id != command.wrappedPoint.intersectionLine2Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label)),

                      for (LineCommand line in drawing.linesIncluded.where((l) => l.id != command.wrappedPoint.intersectionLine2Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != command.wrappedPoint.intersectionLine1Id) {
                        onChanged(command.copyWith(
                          wrappedPoint: command.wrappedPoint.copyWith(
                            intersectionLine1Id: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedPoint.intersectionLine1Id,
                  ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Line 2'),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-line2'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),

                      for (RepeatingLineCommand line in repeatContext.lines.where((l) => l.id != command.wrappedPoint.intersectionLine1Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label)),

                      for (LineCommand line in drawing.linesIncluded.where((l) => l.id != command.wrappedPoint.intersectionLine1Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != command.wrappedPoint.intersectionLine2Id) {
                        onChanged(command.copyWith(
                          wrappedPoint: command.wrappedPoint.copyWith(
                            intersectionLine2Id: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedPoint.intersectionLine2Id,
                  ),
                ],
              ),
            ],
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (editing && !sorting) ? createEditContent() : createViewContent();
  }
}