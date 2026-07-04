
import 'dart:ui';

import 'package:knitty_griddy/drawings/model/part_drawing.dart';

class PartInfo {
  final String partDrawingId;
  final String category;
  final String partId;
  final String partLabel;

  // Stored drawing when used in includedPartCommand
  final PartDrawing? storedOffsetPartDrawing;
  final Offset? storedOffset;

  const PartInfo({
    required this.partDrawingId,
    required this.category,
    required this.partId,
    required this.partLabel,
    this.storedOffsetPartDrawing,
    this.storedOffset,
  });

  PartInfo copyWith({
    String? partDrawingId,
    PartDrawing? storedOffsetPartDrawing,
    Offset? storedOffset,
  }) {
    return PartInfo(
      partDrawingId: partDrawingId?? this.partDrawingId, 
      category: category, 
      partId: partId, 
      partLabel: partLabel,
      storedOffsetPartDrawing: storedOffsetPartDrawing?? this.storedOffsetPartDrawing,
      storedOffset: storedOffset?? this.storedOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PartInfo &&
      runtimeType == other.runtimeType &&
      partDrawingId == other.partDrawingId &&
      category == other.category &&
      partId == other.partId &&
      partLabel == other.partLabel;

  @override
  int get hashCode => super.hashCode ^ partDrawingId.hashCode ^ category.hashCode ^ partId.hashCode ^ partLabel.hashCode;
  
  bool passesFilter(String filter) {
    return category.toLowerCase().contains(filter.toLowerCase()) || partLabel.toLowerCase().contains(filter.toLowerCase());
  }

  Map<String, Object> toJson() {
    return {
      'partdrawingid': partDrawingId,
      'partid': partId,
      'category': category,
      'partlabel': partLabel
    };
  }

  static PartInfo fromJson(Map<String, dynamic> json) {
    return PartInfo(
      partDrawingId: json['partdrawingid'], 
      category: json['category'], 
      partId: json['partid'], 
      partLabel: json['partlabel']
    );
  }
}