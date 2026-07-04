
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';

@immutable
class CommentCommand extends DrawingCommand {

  final String comment;

  const CommentCommand({
    required super.id,
    required super.label,
    required super.version,
    required this.comment,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  CommentCommand copyWith({
    String? label,
    String? comment,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return CommentCommand(
      id: id, 
      version: version + 1,
      label: label?? this.label,
      comment: comment?? this.comment,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 110;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) => Rect.zero;

  @override
  CommentCommand setInitiallyClosed() => copyWith(initiallyOpen: false);

  @override
  CommentCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) => {};

  @override
  CommentCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  CommentCommand changePartDrawingReference({required String oldId, required String newId}) => this;

  @override
  CommentCommand deleteReference({required String commandId}) => this;

  @override
  CommentCommand dependentLabelChanged(String oldLabel, String newLabel) => this;

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = ''}) {
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.commentCommand.name,
      'id': id,
      'label': label,
      'comment': comment,
    };
  }

  static CommentCommand fromJson(Map<String, dynamic> json) {
    return CommentCommand(
      id: json['id'] as String, 
      version: 0,
      label: json['label'] as String,
      comment: json['comment'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is CommentCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
//      version == other.version &&
      label == other.label &&
      comment == other.comment &&
      valid == other.valid &&
      validated == other.validated &&
      listEquals(errors, other.errors);
  
  @override
  int get hashCode => super.hashCode ^ comment.hashCode;


  @override
  DrawingCommand validate(AbstractDrawing drawing) => this;
}