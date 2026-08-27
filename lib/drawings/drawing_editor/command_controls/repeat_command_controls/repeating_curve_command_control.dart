import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepeatingCurveCommandControl extends StatelessWidget {
  final AbstractDrawing drawing;
  final RepeatingCurveCommand command;
  final RepeatCommand repeatContext;
  final bool sorting;
  final bool editing;
  final void Function(RepeatingCurveCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatingCurveCommand newCommand) onChanged;

  const RepeatingCurveCommandControl({
    required this.drawing,
    required this.command,
    required this.repeatContext,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  void curveLabelChanged(String newText) {
    if (command.label != newText) {
      onChangeLabel(
        command.copyWith(
          label: newText,
          wrappedCurve: command.wrappedCurve.copyWith(label: newText)
        ), 
        command.label);
    }
  }

  void quadAmplitudeFormulaChanged(String formula) {
    if (command.wrappedCurve.quadAmplitudeFormula != formula) {
      onChanged(command.copyWith(
        wrappedCurve: command.wrappedCurve.copyWith(
          quadAmplitudeFormula: formula
        )
      ));
    }
  }

  void quadSlantFormulaChanged(String formula) {
    if (command.wrappedCurve.quadSlantFormula != formula) {
      onChanged(command.copyWith(
        wrappedCurve: command.wrappedCurve.copyWith(
          quadSlantFormula: formula
        )
      ));
    }
  }

  void cubicAmplitude1FormulaChanged(String formula) {
    if (command.wrappedCurve.cubicAmplitudeFormula1 != formula) {
      onChanged(command.copyWith(
        wrappedCurve: command.wrappedCurve.copyWith(
          cubicAmplitudeFormula1: formula
        )
      ));
    }
  }

  void cubicSlant1FormulaChanged(String formula) {
    if (command.wrappedCurve.cubicSlantFormula1 != formula) {
      onChanged(command.copyWith(
        wrappedCurve: command.wrappedCurve.copyWith(
          cubicSlantFormula1: formula
        )
      ));
    }
  }

  void cubicAmplitude2FormulaChanged(String formula) {
    if (command.wrappedCurve.cubicAmplitudeFormula2 != formula) {
      onChanged(command.copyWith(
        wrappedCurve: command.wrappedCurve.copyWith(
          cubicAmplitudeFormula2: formula
        )
      ));
    }
  }

  void cubicSlant2FormulaChanged(String formula) {
    if (command.wrappedCurve.cubicSlantFormula2 != formula) {
      onChanged(command.copyWith(
        wrappedCurve: command.wrappedCurve.copyWith(
          cubicSlantFormula2: formula
        )
      ));
    }
  }

  Widget createViewContent() {
    String content = '';

    String startPointLabel = drawing.commandLabelIncluded(command.wrappedCurve.startPointId, repeatContext: repeatContext);
    String endPointLabel = drawing.commandLabelIncluded(command.wrappedCurve.endPointId, repeatContext: repeatContext);

    content += 'between $startPointLabel and $endPointLabel ';

    switch (command.wrappedCurve.curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        String ampLabel = '???';
        String slantLabel = '???';
        if (command.wrappedCurve.quadAmplitudeFormula.isNotEmpty) {
          ampLabel = command.wrappedCurve.quadAmplitudeFormula;
        }

        if (command.wrappedCurve.quadSlantFormula.isNotEmpty) {
          slantLabel = command.wrappedCurve.quadSlantFormula;
        }

        content += 'quadratic with amplitude $ampLabel and slant $slantLabel';
        break;
      case CurveDefinitionType.cubic:
        String ampLabel = '???';
        String slantLabel = '???';
        if (command.wrappedCurve.cubicAmplitudeFormula1.isNotEmpty) {
          ampLabel = command.wrappedCurve.cubicAmplitudeFormula1;
        }

        if (command.wrappedCurve.cubicSlantFormula1.isNotEmpty) {
          slantLabel = command.wrappedCurve.cubicSlantFormula1;
        }

        content += 'cubic with amplitude $ampLabel and slant $slantLabel';
        break;
      case CurveDefinitionType.quadraticFromPoints:
        String ctrlPointLabel = drawing.commandLabelIncluded(command.wrappedCurve.quadCtrlPointId, repeatContext: repeatContext);

        content += 'quadratic with control point $ctrlPointLabel';
        break;
      case CurveDefinitionType.cubicFromPoints:
        String ctrlPoint1Label = drawing.commandLabelIncluded(command.wrappedCurve.cubicCtrlPointId1, repeatContext: repeatContext);
        String ctrlPoint2Label = drawing.commandLabelIncluded(command.wrappedCurve.cubicCtrlPointId2, repeatContext: repeatContext);

        content += 'cubic with control points $ctrlPoint1Label and $ctrlPoint2Label';
        break;
    }
  
    return Row(
      children: [
        const Icon(Symbols.line_curve),
        hspacing,
        SizedBox(
          width: command.hasErrors ? repeatcommandControlViewWidth : repeatcommandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: command.label, style: smallStyleBold,),
                TextSpan(text: ' $content', style: smallStyle,)
              ]
            )
          ),
        )
      ],
    );
  }

  Widget createEditContent() {
    final double labelWidth = command.wrappedCurve.curveDefinitionType == CurveDefinitionType.cubicFromPoints ? 90 : 70;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.line_curve),
            hspacing,
            DropdownButton<CurveDefinitionType>(
              key: ValueKey('${command.id}-cdt'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (CurveDefinitionType cdt in CurveDefinitionType.values)
                  DropdownMenuItem(value: cdt, child: Text(cdt.label))
              ],
              value: command.wrappedCurve.curveDefinitionType,
              onChanged: (value) {
                if (value != command.wrappedCurve.curveDefinitionType) {
                  onChanged(command.copyWith(
                    wrappedCurve: command.wrappedCurve.copyWith(
                      curveDefinitionType: value
                    )
                  ));
                }
              },
            ),            
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallLabel(label: 'Label', width: labelWidth,),
            hspacing,
            SmallTextField(
              key: ValueKey('${command.id}-${command.version}-label'),
              initialText: command.label,
              width: 100,
              onTextChanged: curveLabelChanged,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallLabel(label: 'From', width: labelWidth,),
            hspacing,
            DropdownButton<String>(
              key: ValueKey('${command.id}-from'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                
                for (RepeatingPointCommand point in repeatContext.points.where((p) => p.id != command.wrappedCurve.endPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),

                if (command.wrappedCurve.endPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),

                for (PointCommand point in drawing.pointsIncluded.where((p) => p.id != command.wrappedCurve.endPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != command.wrappedCurve.startPointId) {
                  onChanged(command.copyWith(
                    wrappedCurve: command.wrappedCurve.copyWith(
                      startPointId: value?? ''
                    )
                  ));
                }
              },
              value: command.wrappedCurve.startPointId,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallLabel(label: 'To', width: labelWidth,),
            hspacing,
            DropdownButton<String>(
              key: ValueKey('${command.id}-to'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                
                for (RepeatingPointCommand point in repeatContext.points.where((p) => p.id != command.wrappedCurve.startPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),

                if (command.wrappedCurve.startPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                
                for (PointCommand point in drawing.pointsIncluded.where((p) => p.id != command.wrappedCurve.startPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != command.wrappedCurve.endPointId) {
                  onChanged(command.copyWith(
                    wrappedCurve: command.wrappedCurve.copyWith(
                      endPointId: value?? ''
                    )
                  ));
                }
              },
              value: command.wrappedCurve.endPointId,
            ),
          ],
        ),
        vspacing,
        if (command.wrappedCurve.curveDefinitionType == CurveDefinitionType.quadratic)
          Column(
            children: [
              Row(
                children: [
                  SmallLabel(label: 'Amplitude', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-qamp'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedCurve.quadAmplitudeFormula, 
                    width: 180, 
                    onFormulaChanged: quadAmplitudeFormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Slant', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-qslant'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedCurve.quadSlantFormula, 
                    width: 180, 
                    onFormulaChanged: quadSlantFormulaChanged,
                  ),
                ]
              ),
            ],
          ),
        if (command.wrappedCurve.curveDefinitionType == CurveDefinitionType.cubic)
          Column(
            children: [
              Row(
                children: [
                  SmallLabel(label: 'Amplitude 1', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-camp1'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedCurve.cubicAmplitudeFormula1, 
                    width: 180, 
                    onFormulaChanged: cubicAmplitude1FormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Slant 1', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-cslant1'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedCurve.cubicSlantFormula1, 
                    width: 180, 
                    onFormulaChanged: cubicSlant1FormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Amplitude 2', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-camp2'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedCurve.cubicAmplitudeFormula2, 
                    width: 180, 
                    onFormulaChanged: cubicAmplitude2FormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Slant 2', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: ValueKey('${command.id}-${command.version}-cslant2'),
                    drawing: drawing,
                    repeatContext: repeatContext,
                    excludeLabels: [command.label],
                    formula: command.wrappedCurve.cubicSlantFormula2, 
                    width: 180, 
                    onFormulaChanged: cubicSlant2FormulaChanged,
                  ),
                ]
              ),
            ],
          ),
        if (command.wrappedCurve.curveDefinitionType == CurveDefinitionType.quadraticFromPoints)
          Row(
            children: [
              SmallLabel(label: 'Control point', width: labelWidth,),
              hspacing,
              DropdownButton<String>(
                key: ValueKey('${command.id}-qctrl'),
                isDense: true,
                autofocus: false,
                style: smallStyle,
                itemHeight: kMinInteractiveDimension,
                focusColor: Colors.transparent,
                underline: Container(),
                items: [
                  const DropdownMenuItem(value: '', child: Text('')),

                  for (RepeatingPointCommand point in repeatContext.points)
                    DropdownMenuItem(value: point.id, child: Text(point.label)),

                  if (command.wrappedCurve.quadCtrlPointId != origin.id)
                    DropdownMenuItem(value: origin.id, child: Text(origin.label)),

                  for (PointCommand point in drawing.pointsIncluded)
                    DropdownMenuItem(value: point.id, child: Text(point.label)),
                ],
                onChanged: (value) {
                  if (value != command.wrappedCurve.quadCtrlPointId) {
                    onChanged(command.copyWith(
                      wrappedCurve: command.wrappedCurve.copyWith(
                        quadCtrlPointId: value?? ''
                      )
                    ));
                  }
                },
                value: command.wrappedCurve.quadCtrlPointId,
              ),
            ],
          ),
        if (command.wrappedCurve.curveDefinitionType == CurveDefinitionType.cubicFromPoints)
          Column(
            children: [
              Row(
                children: [
                  SmallLabel(label: 'Control point 1', width: labelWidth,),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-cctrl1'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),

                      for (RepeatingPointCommand point in repeatContext.points)
                        DropdownMenuItem(value: point.id, child: Text(point.label)),

                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),

                      for (PointCommand point in drawing.pointsIncluded)
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != command.wrappedCurve.cubicCtrlPointId1) {
                        onChanged(command.copyWith(
                          wrappedCurve: command.wrappedCurve.copyWith(
                            cubicCtrlPointId1: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedCurve.cubicCtrlPointId1,
                  ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Control point 2', width: labelWidth,),
                  hspacing,
                  DropdownButton<String>(
                    key: ValueKey('${command.id}-cctrl2'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),

                      for (RepeatingPointCommand point in repeatContext.points)
                        DropdownMenuItem(value: point.id, child: Text(point.label)),

                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),

                      for (PointCommand point in drawing.pointsIncluded)
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != command.wrappedCurve.cubicCtrlPointId2) {
                        onChanged(command.copyWith(
                          wrappedCurve: command.wrappedCurve.copyWith(
                            cubicCtrlPointId2: value?? ''
                          )
                        ));
                      }
                    },
                    value: command.wrappedCurve.cubicCtrlPointId2,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (editing && !sorting) ? createEditContent() : createViewContent();
  }
}