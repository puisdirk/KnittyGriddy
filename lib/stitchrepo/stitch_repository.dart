import 'dart:ui';

import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_curve.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_text.dart';
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
      name: 'Slip 1',
      abbreviation: 'Sl1',
      symbols: [
        KnittingSymbol(
          name: 'sl1',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, 11.9),
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),

    StitchDefinition(
      name: 'Slip 1 wyb',
      abbreviation: 'Sl1wyb',
      symbols: [
        KnittingSymbol(
          name: 'sl1wyb',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, 11.9),
            ), 
            KnittingSymbolRectangle(
              name: 'r3',
              height: 3,
              width: 28,
            ), 
          ],
        ), 
      ],
      category: 'General',
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
      name: 'KTBL',
      abbreviation: 'ktbl',
      symbols: [
        KnittingSymbol(
          name: 'k2tog',
          parts: [
            KnittingSymbolCurve(
              name: 'curve',
              length: 29,
              amplitude: 17,
              slant: -17,
              translation: Offset(4.4, 0),
              rotation: 1.2740903539558606,
            ), 
            KnittingSymbolCurve(
              name: 'curve',
              length: 29,
              amplitude: 17,
              slant: -17,
              scale: Offset(-1, 1),
              translation: Offset(-4.4, 0),
              rotation: 1.2740903539558606,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),
    StitchDefinition(
      name: 'Cast on',
      abbreviation: 'CO',
      symbols: [
        KnittingSymbol(
          name: 'co',
          parts: [
            KnittingSymbolArc(
              name: 'arc',
              height: 20,
              width: 20,
              startAngle: 180,
              sweepAngle: 180,
              closed: false,
              scale: Offset(1, -1),
              translation: Offset(0, 2.2),
              filled: false,
              strokeWidth: 3,
            ), 
            KnittingSymbolCurve(
              name: 'curve',
              length: 15,
              amplitude: 1,
              translation: Offset(-10.1, -5.4),
              rotation: 1.5707963267948966,
            ), 
            KnittingSymbolCurve(
              name: 'curve',
              length: 15,
              amplitude: 1,
              translation: Offset(10.1, -5.4),
              rotation: 4.71238898038469,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),
    StitchDefinition(
      name: 'Bind off',
      abbreviation: 'BO',
      symbols: [
        KnittingSymbol(
          name: 'bo',
          parts: [
            KnittingSymbolArc(
              name: 'arc',
              height: 20,
              width: 20,
              startAngle: 180,
              sweepAngle: 180,
              closed: false,
              translation: Offset(0, 5),
              filled: false,
              strokeWidth: 3,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),

    /*********************** DECREASES ************************/

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
            KnittingSymbolRectangle(
              name: 'r3',
              height: 12,
              width: 3,
              translation: Offset(0, 5),
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
      name: 'P3tog',
      abbreviation: 'p3tog',
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
            KnittingSymbolRectangle(
              name: 'r3',
              height: 12,
              width: 3,
              translation: Offset(0, 5),
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 5,
              width: 5,
              translation: Offset(-5, -5),
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
      name: 'SK2P',
      abbreviation: 'sk2p',
      symbols: [
        KnittingSymbol(
          name: 'sk2p',
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
              height: 12,
              width: 3,
              translation: Offset(0, 5),
            ), 
          ],
          scale: Offset(-1, 1),
        ), 
      ],
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'SSSP',
      abbreviation: 'sssp',
      symbols: [
        KnittingSymbol(
          name: 'sssp',
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
              height: 12,
              width: 3,
              translation: Offset(0, 5),
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 5,
              width: 5,
              translation: Offset(-5, -5),
            ), 
          ],
          scale: Offset(-1, 1),
        ), 
      ],
      category: 'Decrease',
    ),

    StitchDefinition(
      name: 'Dec 5-to-1',
      abbreviation: 'dec5to1',
      symbols: [
        KnittingSymbol(
          name: 'dec5to1',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              scale: Offset(1, -1),
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              scale: Offset(1, -1),
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, -11.9),
            ), 
            KnittingSymbolText(
              name: 'text',
              text: '5',
              bold: true,
              scale: Offset(0.75, 0.75),
              translation: Offset(-0.6, 6.1),
            ), 
          ],
        ), 
      ],
      category: 'Decrease',
    ),

    StitchDefinition(
      name: 'Dec 4-to-1',
      abbreviation: 'dec4to1',
      symbols: [
        KnittingSymbol(
          name: 'dec4to1',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              scale: Offset(1, -1),
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              scale: Offset(1, -1),
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, -11.9),
            ), 
            KnittingSymbolText(
              name: 'text',
              text: '4',
              bold: true,
              scale: Offset(0.75, 0.75),
              translation: Offset(-0.6, 6.1),
            ), 
          ],
        ), 
      ],
      category: 'Decrease',
    ),

    StitchDefinition(
      name: 'Dec 4-to-1 L',
      abbreviation: 'dec4to1l',
      symbols: [
        KnittingSymbol(
          name: 'dec4to1l',
          parts: [
            KnittingSymbolRectangle(
              name: 'rectangle',
              height: 26,
              width: 3,
              translation: Offset(7.1, -2.9),
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolText(
              name: 'text',
              text: '4',
              bold: true,
              translation: Offset(-2.3, 5.3),
            ), 
            KnittingSymbolRectangle(
              name: 'rectangle',
              height: 16,
              width: 3,
              translation: Offset(-7.5, -4.5),
              rotation: 0.7853981633974483,
            ), 
          ],
        ), 
      ],
      category: 'Decrease',
    ),
    StitchDefinition(
      name: 'Dec 4-to-1 R',
      abbreviation: 'dec4to1r',
      symbols: [
        KnittingSymbol(
          name: 'dec4to1l',
          parts: [
            KnittingSymbolRectangle(
              name: 'rectangle',
              height: 26,
              width: 3,
              scale: Offset(-1, 1),
              translation: Offset(-3, -2.9),
              rotation: -0.7853981633974483,
            ),
            KnittingSymbolText(
              name: 'text',
              text: '4',
              bold: true,
              translation: Offset(2.4, 5.3),
            ), 
            KnittingSymbolRectangle(
              name: 'rectangle',
              height: 16,
              width: 3,
              scale: Offset(-1, 1),
              translation: Offset(11.5, -4.5),
              rotation: 0.7853981633974483,
            ), 
          ],
          translation: Offset(-1.7, 0),
        ), 
      ],
      category: 'Decrease',
    ),


    //*************************** INCREASES *****************************/

    StitchDefinition(
      name: 'S2KP2',
      abbreviation: 's2kp2',
      symbols: [
        KnittingSymbol(
          name: 's2kp2',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, 11.9),
            ), 
            KnittingSymbolRectangle(
              name: 'rectangle',
              height: 24,
              width: 3,
            ), 
          ],
          scale: Offset(1, -1),
        ), 
      ],
      category: 'Decrease',
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

    StitchDefinition(
      name: 'K1FB',
      abbreviation: 'k1fb',
      symbols: [
        KnittingSymbol(
          name: 'k1fb',
          parts: [
            KnittingSymbolRectangle(
              name: 'r',
              height: 28,
              width: 3,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 18,
              translation: Offset(-5.9, -6),
              rotation: 0.7853981633974483,
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),

    StitchDefinition(
      name: 'M1',
      abbreviation: 'M1',
      symbols: [
        KnittingSymbol(
          name: 'm1',
          parts: [
            KnittingSymbolText(
              name: 'text',
              text: 'M',
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),
    StitchDefinition(
      name: 'M1L',
      abbreviation: 'ML',
      symbols: [
        KnittingSymbol(
          name: 'm1l',
          parts: [
            KnittingSymbolText(
              name: 'text',
              text: 'ML',
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),
    StitchDefinition(
      name: 'M1R',
      abbreviation: 'MR',
      symbols: [
        KnittingSymbol(
          name: 'm1r',
          parts: [
            KnittingSymbolText(
              name: 'text',
              text: 'MR',
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),

    StitchDefinition(
      name: 'M1R lifted',
      abbreviation: 'M1Rl',
      symbols: [
        KnittingSymbol(
          name: 'm1rl',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 28,
              translation: Offset(4, 0),
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              width: 3,
              translation: Offset(-6, 0),
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(-6, 9.6),
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),

    StitchDefinition(
      name: 'M1L lifted',
      abbreviation: 'M1Ll',
      symbols: [
        KnittingSymbol(
          name: 'm1ll',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 28,
              translation: Offset(4, 0),
              rotation: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              width: 3,
              translation: Offset(-6, 0),
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(-6, 9.6),
            ), 
          ],
          scale: Offset(-1, 1),
          translation: Offset(2, 0),
        ), 
      ],
      category: 'Increase',
    ),

    StitchDefinition(
      name: 'Inc 1-to-3',
      abbreviation: 'inc1to3',
      symbols: [
        KnittingSymbol(
          name: 'inc1to3',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, 11.9),
            ), 
            KnittingSymbolRectangle(
              name: 'rectangle',
              height: 24,
              width: 3,
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),
    StitchDefinition(
      name: 'Inc 1-to-4',
      abbreviation: 'inc1to4',
      symbols: [
        KnittingSymbol(
          name: 'inc1to4',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, 11.9),
            ), 
            KnittingSymbolText(
              name: 'text',
              text: '4',
              bold: true,
              scale: Offset(0.75, 0.75),
              translation: Offset(0, -6.1),
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),
    StitchDefinition(
      name: 'Inc 1-to-5',
      abbreviation: 'inc1to5',
      symbols: [
        KnittingSymbol(
          name: 'inc1to5',
          parts: [
            KnittingSymbolRectangle(
              name: 'r1',
              height: 3,
              width: 26,
              translation: Offset(7, 0),
              rotation: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotation: -0.5235987755982988,
            ), 
            KnittingSymbolArc(
              name: 'arc',
              height: 3,
              width: 3,
              translation: Offset(0, 11.9),
            ), 
            KnittingSymbolText(
              name: 'text',
              text: '5',
              bold: true,
              scale: Offset(0.75, 0.75),
              translation: Offset(0, -6.1),
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),

    /********************** Decorative **********************/

    StitchDefinition(
      name: 'Bobble',
      abbreviation: 'bobble',
      symbols: [
        KnittingSymbol(
          name: 'k2tog',
          parts: [
            KnittingSymbolArc(
              name: 'arc',
              height: 20,
              width: 20,
            ), 
          ],
        ), 
      ],
      category: 'Decorative',
    ),

    /********************** Elongated **********************/

    StitchDefinition(
      name: 'K1Wrap2',
      abbreviation: 'k1wrap2',
      symbols: [
        KnittingSymbol(
          name: 'k1wrap2',
          parts: [
            KnittingSymbolPath(
              name: 'path',
              path: 'M4,9C4,9,8.9573,8.69,11,10C13.5869,11.659,16.2947,13.9355,17,17C17.5866,19.5488,17.5457,24.4855,17,27C16.3357,30.0612,15.9021,31.8244,14,33C12.5822,33.8762,10.4178,33.8762,9,33C7.0979,31.8244,6.5137,29.1763,6,27C5.2342,23.7558,6.0759,19.7567,7,17C7.6859,14.9538,10.5135,12.3543,11,12C13.1724,10.418,14.852,9.5993,18,9C19.4676,8.7206,19.5838,8.7703,19.9901,8.7708C20.4273,8.7713,20.4075,8.7097,22,9C24.9834,9.5438,26.8643,10.3688,29,12C30.8731,13.4307,32.098,14.8224,33,17C34.2756,20.0796,34.7658,23.7558,34,27C33.4863,29.1763,32.9021,31.8244,31,33C29.5822,33.8762,27.4178,33.8762,26,33C24.0979,31.8244,23.5441,29.1689,23,27C22.4196,24.6864,22.0811,20.2042,23,17C23.8669,13.9772,26.4131,11.659,29,10C31.0427,8.69,36,9,36,9',
              strokeWidth: 1.9,
            ), 
          ],
        ), 
      ],
      category: 'Elongated',
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