import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/patterns/model/text_field_link.dart';
import 'package:knitty_griddy/patterns/model/text_field_links.dart';
import 'package:knitty_griddy/utils/constants.dart';

const String placeholderPatternId = '_placeholder_pattern_id_';
const KnittingPattern placeholderPattern = KnittingPattern(
  id: placeholderPatternId,
  name: placeholderPatternId,
);

@immutable
class KnittingPattern {
  final String id;
  final String name;
  final String description;
  final List<PatternField> fields;
  final PatternPageLayout pageLayout;
  final TextFieldLinks textFieldLinks;

  const KnittingPattern({
    required this.id,
    required this.name,
    this.description = '',
    this.fields = const[],
    this.pageLayout = PatternPageLayout.defaultLayout,
    this.textFieldLinks = const TextFieldLinks()
  });

  KnittingPattern copyWith({
    String? id,
    String? name,
    String? description,
    List<PatternField>? fields,
    PatternPageLayout? pageLayout,
    TextFieldLinks? textFieldLinks,
  }) {
    return KnittingPattern(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      fields: fields?? this.fields,
      pageLayout: pageLayout?? this.pageLayout,
      textFieldLinks: textFieldLinks?? this.textFieldLinks,
    );
  }

  KnittingPattern adjustPositionsToLayout() {
    List<PatternField> newFields = [];

    // Go through all the fields and move/resize them until they fit on the new size
    Rect newPatternRect = Rect.fromLTWH(0, 0, pageLayout.dimensions.width, pageLayout.dimensions.height);
    for (PatternField field in fields) {
      PatternField newField = field;
      if (newField.positionY + newField.height > newPatternRect.height) {
        newField = newField.abstractCopyWith(positionY: newPatternRect.height - newField.height);
        if (newField.positionY < 0) {
          // The pattern dimensions are not high enough to accomodate the field, so we need to resize it
          double newHeight = newPatternRect.height;
          double newWidth = newField.width;
          if (newField.fixedAspectRatio) {
            newWidth *= newField.height / newField.width;
          }
          newField = newField.abstractCopyWith(positionY: 0, height: newHeight, width: newWidth);
        }
      }

      if (newField.positionX + newField.width > newPatternRect.width) {
        newField = newField.abstractCopyWith(positionX: newPatternRect.width - newField.width);
        if (newField.positionX < 0) {
          // The pattern dimensions are not wide enough to accomodate the field, so we need to resize it
          double newHeight = newField.height;
          double newWidth = newPatternRect.width;
          if (newField.fixedAspectRatio) {
            newHeight *= newField.height / newField.width;
          }
          newField = newField.abstractCopyWith(positionX: 0, height: newHeight, width: newWidth);
        }
      }

      newFields.add(newField);
    }

    return copyWith(fields: newFields);
  }

  Iterable<PatternTextEditorField> get textEditorFields => fields.whereType<PatternTextEditorField>();
  bool get hasMultipleTextFields => textEditorFields.length > 1;
  List<String> get freeTextEditorLinks {
    List<String> linkIds = [];
    for (PatternTextEditorField field in textEditorFields) {
      if (!textFieldLinks.hasIncomingLink(field.id)) {
        linkIds.add('${field.id}:input');
      }
      if (!textFieldLinks.hasOutgoingLink(field.id)) {
        linkIds.add('${field.id}:output');
      }
    }
    // If there's only 2 free links, then they can't really be free. Connecting the two would cause a cycle
    if (linkIds.length == 2) {
      return [];
    }
    return linkIds;
  }
  List<String> get freeTextEditorFieldIds => textEditorFields.where((f) => !textFieldLinks.hasIncomingLink(f.id) || !textFieldLinks.hasOutgoingLink(f.id)).map((f) => f.id).toList();

  List<String> acceptableLinkTargetsFor(String fieldId, bool fromOutput) {
    List<String> linkIds = [];

    Map<String, Set<String>> graphData = {};
    for (PatternTextEditorField f in textEditorFields) {
      graphData[f.id] = {};
    }
    for (TextFieldLink l in textFieldLinks.links) {
      graphData[l.fromId]?.add(l.toId);
    }

    for (String freeId in freeTextEditorFieldIds) {
      DirectedGraph graph = DirectedGraph(graphData);
      if (fromOutput) {
        graph.addEdges(fieldId, {freeId});
      } else {
        graph.addEdges(freeId, {fieldId});
      }

      if (graph.cycle.isEmpty) {
        linkIds.add('$freeId:${fromOutput ? 'input' : 'output'}');
      }

    }
    return linkIds;
  }

  KnittingPattern removeTextField(String id) {
    // TODO: if there is a link from or to another textfield, shouldn't we move the contents first??
    return copyWith(
      fields: fields.where((f) => f.id != id).toList(),
      textFieldLinks: textFieldLinks.removeLinksForField(id),
    );
  }

  KnittingPattern addTextFieldLink(String fromId, String toId) {
    return copyWith(textFieldLinks: textFieldLinks.addLink(fromId, toId));
  }

  KnittingPattern removeTextFieldLink(TextFieldLink link) {
    // TODO: should copy contents?
    return copyWith(textFieldLinks: textFieldLinks.removeLink(link));
  }

  List<Color> get knownColours {
    Set<Color> colors = {};

    for (PatternField field in fields) {
      colors.addAll(field.knownColours);
    }

    colors.remove(Colors.black);
    colors.remove(Colors.white);
    colors.remove(Colors.transparent);

    return colors.toList(growable: false);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ fields.hashCode ^ pageLayout.hashCode ^ textFieldLinks.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingPattern &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(fields, other.fields) &&
      pageLayout == other.pageLayout &&
      textFieldLinks == other.textFieldLinks;

    Map<String, Object> toJson() {
    return {
      'objectversion': objectversion,
      'id': id,
      'name': name,
      'description': description,
      'fields': fields.map((f) => f.toJson()).toList(),
      'layout': pageLayout.toJson(),
      'links': textFieldLinks.toJson(),
    };
  }

  static KnittingPattern fromJson(Map<String, dynamic> json) {
    
    Map<String, Drawing> validatedDrawings = {};

    List<PatternField> fields = [];
    List<Map<String, dynamic>> fieldObjects = (json['fields'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> fieldObject in fieldObjects) {
      PatternFieldType fieldType = PatternFieldType.values.byName(fieldObject['type'] as String);
      switch (fieldType) {
        case PatternFieldType.texteditor:
          fields.add(PatternTextEditorField.fromJson(fieldObject));
          break;
        case PatternFieldType.knittingchart:
          fields.add(PatternChartField.fromJson(fieldObject));
          break;
        case PatternFieldType.drawing:
          // Reuse validated drawings if they occur multiple times in the pattern
          PatternDrawingField f = PatternDrawingField.fromJson(fieldObject);
          if (f.drawing != null) {
            if (validatedDrawings.containsKey(f.drawing!.id)) {
              f = f.copyWith(drawing: validatedDrawings[f.drawing!.id]);
            } else {
              f = f.copyWith(drawing: f.drawing!.validate());
              validatedDrawings[f.drawing!.id] = f.drawing!;
            }
          }
          fields.add(f);
          break;
        case PatternFieldType.image:
          fields.add(PatternImageField.fromJson(fieldObject));
          break;
        case PatternFieldType.panel:
          fields.add(PatternPanelField.fromJson(fieldObject));
          break;
      }
    }
    
    return KnittingPattern(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      fields: fields,
      pageLayout: PatternPageLayout.fromJson(json['layout']),
      textFieldLinks: json.containsKey('links') ? TextFieldLinks.fromJson(json['links']) : const TextFieldLinks(),
    );
  }
}