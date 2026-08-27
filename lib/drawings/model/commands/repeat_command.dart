import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_text_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_variable_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/utils/collection_utilities.dart';

@immutable
class RepeatCommand extends DrawingCommand {

  final List<RepeatingDrawingCommand> commands;
  final String repeatValueFormula;
  final int? storedRepeatValue;

  const RepeatCommand({
    required super.id,
    required super.version,
    required super.label,
    super.valid,
    super.validated,
    super.errors,
    super.initiallyOpen,
    this.commands = const[],
    this.repeatValueFormula = '10',
    this.storedRepeatValue,
  });

  @override
  Iterable<String> get labels => commands.map((c) => c.label);

  Iterable<RepeatingVariableCommand> get variables => commands.whereType();
  Iterable<RepeatingPointCommand> get points => commands.whereType();
  Iterable<RepeatingLineCommand> get lines => commands.whereType();
  Iterable<RepeatingCurveCommand> get curves => commands.whereType();
  int get repeatValue => storedRepeatValue?? 1;
  PointCommand? pointById(String id) {
    try {
      return points.firstWhere((c) => c.id == id).wrappedPoint;
    } catch (_) {
      return null;
    }
  }
  LineCommand? lineById(String id) {
    try {
      return lines.firstWhere((l) => l.id == id).wrappedLine;
    } catch (_) {
      return null;
    }
  }
  CurveCommand? curveById(String id) {
    try {
      return curves.firstWhere((c) => c.id == id).wrappedCurve;
    } catch (_) {
      return null;
    }
  }
  VariableCommand? variableByName(String name) {
    try {
      return variables.firstWhere((v) => v.label.replaceAll('_', ' ') == name.replaceAll('_', ' ')).wrappedVariable;
    } catch (_) {
      return null;
    }
  }
  PointCommand? pointByName(String name) {
    try {
      return points.firstWhere((p) => p.label.replaceAll('_', ' ') == name.replaceAll('_', ' ')).wrappedPoint;
    } catch (_) {
      return null;
    }
  }
  LineCommand? lineByName(String name) {
    try {
      return lines.firstWhere((p) => p.label.replaceAll('_', ' ') == name.replaceAll('_', ' ')).wrappedLine;
    } catch (_) {
      return null;
    }
  }

  RepeatCommand copyWith({
    String? id,
    String? label,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    List<RepeatingDrawingCommand>? commands,
    String? repeatValueFormula,
    int? storedRepeatValue,
  }) {
    return RepeatCommand(
      id: id?? this.id, 
      version: version + 1, 
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      commands: commands?? this.commands,
      repeatValueFormula: repeatValueFormula?? this.repeatValueFormula,
      storedRepeatValue: storedRepeatValue?? this.storedRepeatValue,
    );
  }

  @override
  RepeatCommand abstractCopyWith({String? id, String? label, bool? initiallyOpen}) {
    return copyWith(
      id: id?? this.id,
      label: label?? this.label,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 800;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    Rect completeRect = Rect.zero;

    for (int repeatIndex = 1; repeatIndex <= repeatValue; repeatIndex++) {
      RepeatCommand withIndex = _validateWithIndex(drawing, repeatIndex);
      for (RepeatingDrawingCommand command in withIndex.commands) {
        completeRect = completeRect.expandToInclude(command.getBoundingBox(drawing));
      }
    }

    return completeRect;
  }

  @override
  RepeatCommand setInitiallyClosed() => copyWith(initiallyOpen: false);

  @override
  RepeatCommand markAsCyclic(String cycleDescription) => copyWith(
    validated: true,
    valid: false,
    errors: ['Cycle detected: $cycleDescription'],
  );

  @override
  RepeatCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      commands: commands.map((c) => c.changePartDrawingReference(oldId: oldId, newId: newId)).toList()
    );
  }

  @override
  RepeatCommand deleteReference({required String commandId}) {
    return copyWith(
      commands: commands.map((c) => c.deleteReference(commandId: commandId)).toList()
    );
  }

  @override
  RepeatCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      repeatValueFormula: FormulaExpression.replaceDependentLabel(formula: repeatValueFormula, oldLabel: oldLabel, newLabel: newLabel),
      commands: commands.map((c) => c.dependentLabelChanged(oldLabel, newLabel)).toList()
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.repeatCommand.name,
      'id': id,
      'label': label,
      'rep': repeatValueFormula,
      'commands': commands.map((c) => c.toJson()).toList()
    };
  }

  static List<RepeatingDrawingCommand> repeatcommandsFromJson(Map<String, dynamic> json) {
    List<RepeatingDrawingCommand> commands = [];
    List<Map<String, dynamic>> commandObjects = (json['commands'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> commandObject in commandObjects) {
      RepeatingDrawingCommandTypes commandType = RepeatingDrawingCommandTypes.values.byName(commandObject['type'] as String);
      switch (commandType) {
        case RepeatingDrawingCommandTypes.repeatpointCommand:
          commands.add(RepeatingPointCommand.fromJson(commandObject));
          break;
        case RepeatingDrawingCommandTypes.repeatlineCommand:
          commands.add(RepeatingLineCommand.fromJson(commandObject));
          break;
        case RepeatingDrawingCommandTypes.repeatcurveCommand:
          commands.add(RepeatingCurveCommand.fromJson(commandObject));
          break;
        case RepeatingDrawingCommandTypes.repeatvariableCommand:
          commands.add(RepeatingVariableCommand.fromJson(commandObject));
          break;
        case RepeatingDrawingCommandTypes.repeattextCommand:
          commands.add(RepeatingTextCommand.fromJson(commandObject));
          break;
      }
    }
    return commands;
  }

  static RepeatCommand fromJson(Map<String, dynamic> json) {
    List<RepeatingDrawingCommand> commands = RepeatCommand.repeatcommandsFromJson(json);

    return RepeatCommand(
      id: json['id'] as String, 
      version: 0, 
      label: json['label'] as String,
      repeatValueFormula: json['rep'] as String,
      commands: commands,
    );
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': DrawingCommandTypes.repeatCommand.name,
    'label': label,
    'rep': repeatValueFormula,
    'commands': commands.map((c) => c.contentHashCode).toList()
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RepeatCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    repeatValueFormula == other.repeatValueFormula &&
    listEquals(commands, other.commands) &&
    validated == other.validated &&
    valid == other.valid &&
    listEquals(errors, other.errors) &&
    storedRepeatValue == other.storedRepeatValue;

  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
    other is RepeatCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    repeatValueFormula == other.repeatValueFormula &&
    CollectionUtilities.listSameAs(commands, other.commands);

  @override
  int get hashCode => super.hashCode ^ repeatValueFormula.hashCode ^ commands.hashCode ^ storedRepeatValue.hashCode;

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    if (!valid) return '';

    String svg = '<g id="$label>';

    for (int repeatIndex = 1; repeatIndex <= repeatValue; repeatIndex++) {
      RepeatCommand withIndex = _validateWithIndex(drawing, repeatIndex);
      for (RepeatingDrawingCommand command in withIndex.commands) {
        svg += command.toSvg(drawingSize, drawing);
      }
    }

    svg += '</g>';

    return svg;
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const [], bool drawDirectionArrow = false, bool forPreview = false}) {
    if (!valid) return;

    // Pass any stylings for the repeat command as stylings for the repeated commands
    List<StylingCommand> repeatStylings = List.from(stylings);
    StylingCommand? styling = drawing.styleFor(id);
    if (styling != null) {
      repeatStylings.add(styling.copyWith(commandIds: commands.map((c) => c.id).toSet()));
    }

    for (int repeatIndex = 1; repeatIndex <= repeatValue; repeatIndex++) {
      RepeatCommand withIndex = _validateWithIndex(drawing, repeatIndex);
      for (RepeatingDrawingCommand command in withIndex.commands) {
        command.paint(canvas, size, drawing, selected, asPart: asPart, prefixLabel: prefixLabel, stylings: repeatStylings, drawDirectionArrow: drawDirectionArrow, forPreview: forPreview);
      }
    }
  }

  // TODO: passing storedRepeatValue null doesn't do anything
  @override
  RepeatCommand clearValidation() => copyWith(
    validated: false, 
    valid: false, 
    errors: const[],
    commands: commands.map((c) => c.clearValidation()).toList(),
    storedRepeatValue: null,
  );

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};

    deps.addAll(FormulaExpression.dependencies(formula: repeatValueFormula, drawing: drawing));

    for (RepeatingDrawingCommand cmd in commands) {
      deps.addAll(cmd.dependencies(drawing));
    }

    return deps;
  }

  RepeatCommand _validateWithIndex(AbstractDrawing drawing, int repeatIndex) {
    RepeatCommand clearedCommand = clearValidation();
    int passes = 0;
    int maxPasses = 100;
    while (true) {
      if (clearedCommand.commands.any((c) => !c.validated) && passes <= maxPasses) {
        List<RepeatingDrawingCommand> passedCommands = clearedCommand.commands.map((c) {
          if (!c.validated) {
            RepeatingDrawingCommand r = c.validate(drawing, clearedCommand, repeatIndex);
            return r;
          }
          return c;
        }).toList();
        clearedCommand = clearedCommand.copyWith(commands: passedCommands);
        passes++;
      } else {
        break;
      }
    }

    if (passes >= maxPasses) {
      print('!!!!!!!!!validation overflow in validateWithIndex for $label');
    }
    return clearedCommand;
  }

  @override
  RepeatCommand validate(AbstractDrawing drawing) {
    print('validating repeatCommand $label');
    
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    FormulaParseResult res = FormulaExpression.validate(formula: repeatValueFormula, drawing: drawing, label: 'a repeat value');
    int repeatValue = 0;
    if (res.isInvalid) {
      isvalid = false;
      if (!res.shouldRetry) retryValidation = false;
      validationErrors.add(res.errorMessage);
    } else {
      repeatValue = res.result!.toInt();
    }

    RepeatCommand clearedCommand = clearValidation();
    int passes = 0;
    int maxPasses = 100;
    while (true) {
      if (clearedCommand.commands.any((c) => !c.validated) && passes <= maxPasses) {
        List<RepeatingDrawingCommand> passedCommands = clearedCommand.commands.map((c) {
          if (!c.validated) {
            RepeatingDrawingCommand r = c.validate(drawing, clearedCommand, 1);
            return r;
          }
          return c;
        }).toList();
        clearedCommand = clearedCommand.copyWith(commands: passedCommands);
        passes++;
      } else {
        break;
      }
    }

    if (passes >= maxPasses) {
      print('!!!!!!!!!validation overflow in validate for $label');
    }

    if (clearedCommand.commands.any((c) => !c.validated || !c.valid)) {
      isvalid = false;
      if (clearedCommand.commands.any((c) => !c.retryValidation)) {
        retryValidation = false;
      }
      validationErrors.add('Error in the commands');
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
      commands: clearedCommand.commands,
      storedRepeatValue: repeatValue
    );
  }

}