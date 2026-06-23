import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';

class BasicPartsSet extends PartSet {
  
  static const String basicPartsSetId = '0994daf0-a29d-4b27-a2ec-517a8519c9de';

  static const List<String> _basicPartSetResources = [
    'AldrichSleeve.kpd',
    'AldrichBodice.kpd',
  ];

  const BasicPartsSet() : super(
    id: basicPartsSetId, 
    name: 'Basic Set', 
     parts: const[
    ]
  );

  const BasicPartsSet.fromList(List<PartDrawing> parts) : super(
    id: basicPartsSetId, 
    name: 'Basic Set', 
     parts: parts
  );

  static Future<BasicPartsSet> loadFromAssets() async {
    List<PartDrawing> parts = [];
    for (String resourceName in _basicPartSetResources) {
      String json = await rootBundle.loadString('drawings/$resourceName');
      parts.add(PartDrawing.fromJson(jsonDecode(json)).validate());
    }

    return BasicPartsSet.fromList(parts);
  }

}