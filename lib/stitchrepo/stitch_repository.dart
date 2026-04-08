import 'dart:ui';

import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchRepository {
  StitchRepository._();

  static const StitchDefinition noStitch = StitchDefinition(
    name: 'No stitch',
    abbreviation: '',
    symbols: [
      KnittingSymbol(
        name: 'nostitch',
        parts: [
          KnittingSymbolRectangle(
            name: 'r1',
            height: 0.3,
            width: 28,
            translation: Offset(-16, -16),
            rotation: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r2',
            height: 0.3,
            width: 28,
            translation: Offset(-10, -10),
            rotation: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r3',
            height: 0.3,
            width: 45,
            translation: Offset(-3, -3),
            rotation: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r4',
            height: 0.3,
            width: 45,
            translation: Offset(3, 3),
            rotation: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r5',
            height: 0.3,
            width: 28,
            translation: Offset(10, 10),
            rotation: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r6',
            height: 0.3,
            translation: Offset(16, 16),
            rotation: -0.7853981633974483,
          ), 
        ],
      ), 
    ],
    category: 'General',
  );
  
  static const StitchDefinition knit = StitchDefinition(
    name: 'Knit', 
    abbreviation: 'k', 
    symbols: [
      KnittingSymbol(
        name: 'knit', 
        parts: [
          KnittingSymbolRectangle(
            name: 'r', 
            height: 28, 
            width: 3,
          ), 
        ],
      ), 
    ], 
    category: 'General',
  );

  static const StitchDefinition purl = StitchDefinition(
    name: 'Purl',
    abbreviation: 'p',
    symbols: [
      KnittingSymbol(
        name: 'purl',
        parts: [
          KnittingSymbolRectangle(
            name: 'r',
            height: 28,
            width: 3,
            rotation: 1.5707963267948966,
          ), 
        ],
      ), 
    ],
    category: 'General',
  );

  static const List<StitchDefinition> definitions = [
    noStitch, knit, purl, 
    StitchDefinition(
      name: 'K2tog', 
      abbreviation: 'k2tog', 
      symbols: [
        KnittingSymbol(
          name: 'k2tog', 
          parts: [
            KnittingSymbolRectangle(
              name: 'r',
              height: 3, 
              width: 28, 
              rotation: -0.7853981633974483,
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'K3tog', 
      abbreviation: 'k3tog', 
      symbols: [
        KnittingSymbol(
          name: 'k3tog', 
          parts: [
            KnittingSymbolRectangle(
              name: 'r', 
              height: 3, 
              width: 28, 
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2', 
              height: 3, 
              width: 14, 
              translation: Offset(5, 5), 
              rotation: 0.7853981633974483,
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'P2tog', 
      abbreviation: 'p2tog', 
      symbols: [
        KnittingSymbol(
          name: 'p2tog', 
          parts: [
            KnittingSymbolRectangle(
              name: 'r', 
              height: 3, 
              width: 28, 
              scale: Offset(-1, 1), 
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2', 
              height: 3, 
              width: 22, 
              translation: Offset(0, 14),
            ), 
          ], 
          scale: Offset(-1, 1),
        ), 
      ], 
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'P3tog', 
      abbreviation: 'p3tog', 
      symbols: [
        KnittingSymbol(
          name: 'p3tog', 
          parts: [
            KnittingSymbolRectangle(
              name: 'r', 
              height: 3, 
              width: 28, 
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2', 
              height: 3, 
              width: 14, 
              translation: Offset(5, 5), 
              rotation: 0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r3', 
              height: 3, 
              width: 22, 
              translation: Offset(0, 14),
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'SSK', 
      abbreviation: 'ssk', 
      symbols: [
        KnittingSymbol(
          name: 'ssk', 
          parts: [
            KnittingSymbolRectangle(
              name: 'r', 
              height: 3, 
              width: 28, 
              scale: Offset(-1, 1),
              rotation: -0.7853981633974483,
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'SSP', 
      abbreviation: 'ssp', 
      symbols: [
        KnittingSymbol(
          name: 'ssp', 
          parts: [
            KnittingSymbolRectangle(
              name: 'r', 
              height: 3, 
              width: 28, 
              scale: Offset(-1, 1), 
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2', 
              height: 3, 
              width: 22, 
              translation: Offset(0, 14),
            ), 
          ],
        ),
      ], 
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'KTBL',
      abbreviation: 'ktbl',
      symbols: [
        KnittingSymbol(
          name: 'k3tog',
          parts: [
            KnittingSymbolRectangle(
              name: 'r',
              height: 3,
              width: 28,
              rotation: 1.5707963267948966,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 16,
              rotation: 0.7853981633974483,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),
    StitchDefinition(
      name: 'YO', 
      abbreviation: 'yo', 
      symbols: [
        KnittingSymbol(
          name: 'yarnover', 
          parts: [
            KnittingSymbolArc(
              name: 'a', 
              height: 22, 
              width: 22, 
              closed: false, 
              filled: false, 
              strokeWidth: 3,
            ), 
          ],
        ), 
      ], 
      category: 'Increase',
    ),
  ];

  static Map<String, List<StitchDefinition>> getDefinitionsPerCategory(List<StitchDefinition> customStitches) {
    Map<String, List<StitchDefinition>> defs = {};
    for (StitchDefinition def in definitions) {
      if (!defs.containsKey(def.category)) {
        defs[def.category] = [];
      }
      defs[def.category]!.add(def);
    }

    if (customStitches.isNotEmpty) {
      defs['Custom'] = [... customStitches];
    }

    return defs;
  }
}