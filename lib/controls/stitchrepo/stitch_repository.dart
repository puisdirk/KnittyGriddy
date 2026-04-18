import 'dart:ui';

import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_curve.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_text.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

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
            translation: Offset(-18, -18),
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
            translation: Offset(18, 18),
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

    /******************** Cables version 1 ***************/

    StitchDefinition(
  name: '1/1 LC (LT)',
  abbreviation: '1/1lc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.4, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25.1,width: 3,translation: Offset(-9.7, 9),rotation: 0.7853981633974483,), ],), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(2.2, 2.2),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 26.1,width: 3,translation: Offset(10.4, -9),rotation: 0.7853981633974483,), ],), ],category: 'Cables v1',description: 'sl 1 st onto cn, hold in front, k1, k1 from cn OR with right needle behind left needle, knit 2nd st tbl, knit first st, drop both sts from left needle',),

    StitchDefinition(
  name: '1/1 RC (RT)',
  abbreviation: '1/1rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(2.2, 2.2),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 26.1,width: 3,translation: Offset(10.4, -9),rotation: 0.7853981633974483,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.4, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25.1,width: 3,translation: Offset(-9.7, 9),rotation: 0.7853981633974483,), ],scale: Offset(-1, 1),), ],category: 'Cables v1',description: 'sl 1 st onto cn, hold in back, k1, k1 from cn OR k2tog but do not drop sts from left needle, k1, drop both sts from left needle',),

    StitchDefinition(
  name: '1/1 LPC',
  abbreviation: '1/1lpc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.8, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.8),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25,width: 3,translation: Offset(-9.9, 9),rotation: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 30,translation: Offset(-0.2, 20.6),rotation: 0.7853981633974483,), ],), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 53.1,width: 3,translation: Offset(1, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 24.1,width: 3,translation: Offset(10.4, -9),rotation: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 30,translation: Offset(1.1, -19.9),rotation: 0.7853981633974483,), ],), ],category: 'Cables v1',description: 'sl 1 st onto cn, hold in front, p1, k1 from cn',),

    StitchDefinition(
  name: '1/1 RPC',
  abbreviation: '1/1rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 53.1,width: 3,translation: Offset(1, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 24.1,width: 3,translation: Offset(10.4, -9),rotation: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 30,translation: Offset(1.1, -19.9),rotation: 0.7853981633974483,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.8, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.8),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotation: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25,width: 3,translation: Offset(-9.9, 9),rotation: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 30,translation: Offset(-0.2, 20.6),rotation: 0.7853981633974483,), ],scale: Offset(-1, 1),), ],category: 'Cables v1',description: 'sl 1 st onto cn, hold in back, k1, p1 from cn',),

StitchDefinition(
  name: '2/1 LC',
  abbreviation: '2/1lc',
  symbols: [KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 3,translation: Offset(10, 12),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.9),), ],scale: Offset(-1, 1),), ],category: 'Cables v1',description: 'sl 2 sts onto cn, hold in front, k1, k2 from cn',),

StitchDefinition(
  name: '2/1 RC',
  abbreviation: '2/1rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.9),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 3,translation: Offset(10, 12),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],), ],category: 'Cables v1',description: 'sl 1 st onto cn, hold in back, k2, k1 from cn',),

StitchDefinition(
  name: '2/1 LPC',
  abbreviation: '2/1lpc',
  symbols: [KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolPath(
  name: 'path',
  path: 'M21,24L0,40L40,40L21,24z',scale: Offset(-1, 1),translation: Offset(-0.7, 0.7),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(10, 12),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.7, 0),rotation: -0.767944870877505,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0, 18.7),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolPath(
  name: 'path',
  path: 'M20,24L0,40L40,40L20,24z',scale: Offset(-1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.7),), ],scale: Offset(-1, 1),), ],category: 'Cables v1',description: 'sl 2 sts onto cn, hold in front, p1, k2 from cn',),

StitchDefinition(
  name: '2/1 RPC',
  abbreviation: '2/1rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotation: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolPath(
  name: 'path',
  path: 'M20,24L0,40L40,40L20,24z',scale: Offset(-1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.7),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0, 18.7),), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolPath(
  name: 'path',
  path: 'M21,24L0,40L40,40L21,24z',scale: Offset(-1, 1),translation: Offset(-0.7, 0.7),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(10, 12),rotation: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.7, 0),rotation: -0.767944870877505,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18),), ],), ],category: 'Cables v1',description: 'sl 1 st onto cn, hold in back, k2, p1 from cn',),

StitchDefinition(
  name: '2/2 LC',
  abbreviation: '2/2lc',
  symbols: [KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4, 10.6),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7.8),rotation: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 9.9),rotation: -0.4014257279586958,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotation: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45.7,translation: Offset(0.9, -8.5),rotation: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(3.8, 10.1),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), ],), ],category: 'Cables v1',description: 'sl 2 sts onto cn, hold in front, k2, k2 from cn',),

StitchDefinition(
  name: '2/2 RC',
  abbreviation: '2/2rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45.7,translation: Offset(0.9, -8.5),rotation: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(3.8, 10.1),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotation: -0.4188790204786391,), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 9.9),rotation: -0.4014257279586958,), ],), KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4, 10.6),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7.8),rotation: -0.4188790204786391,), ],), ],category: 'Cables v1',description: 'sl 2 sts onto cn, hold in back, k2, k2 from cn',),

StitchDefinition(
  name: '2/2 LPC',
  abbreviation: '2/2lpc',
  symbols: [KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4.6, 11),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.4,width: 40,scale: Offset(-1, 1),translation: Offset(-7.6, 28.8),rotation: 1.2042771838760873,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7),rotation: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 10.1),rotation: -0.3665191429188092,), KnittingSymbolRectangle(
  name: 'rectangle',height: 40,width: 40,translation: Offset(13.6, 27.7),rotation: 1.2042771838760873,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotation: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 52,width: 40,translation: Offset(-5.9, -28.6),rotation: 1.1693705988362009,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0.9, -8.5),rotation: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(4.6, 10.6),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.6,width: 40,translation: Offset(-6.6, -25.2),rotation: 1.1693705988362009,), ],), ],category: 'Cables v1',description: 'sl 2 sts onto cn, hold in front, k2, p2 from cn',),

StitchDefinition(
  name: '2/2 RPC',
  abbreviation: '2/2rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0.9, -8.5),rotation: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(4.6, 10.6),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.6,width: 40,translation: Offset(-6.6, -25.2),rotation: 1.1693705988362009,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotation: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 52,width: 40,translation: Offset(-5.9, -28.6),rotation: 1.1693705988362009,), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 10.1),rotation: -0.3665191429188092,), KnittingSymbolRectangle(
  name: 'rectangle',height: 40,width: 40,translation: Offset(13.6, 27.7),rotation: 1.2042771838760873,), ],), KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4.6, 11),rotation: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.4,width: 40,scale: Offset(-1, 1),translation: Offset(-7.6, 28.8),rotation: 1.2042771838760873,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7),rotation: -0.4188790204786391,), ],), ],category: 'Cables v1',description: 'sl 2 sts onto cn, hold in back, k2, p2 from cn',),

StitchDefinition(
  name: '2/1/2 LPC',
  abbreviation: '212lpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolPath(
  name: 'path',
  path: 'M0,0L41,20L41,0L0,0z',scale: Offset(1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 56.3,translation: Offset(3.9, -5.7),rotation: 0.4537856055185257,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolPath(
  name: 'path',
  path: 'M-1,0L41,20L41,0L0,0z',scale: Offset(-1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.8),), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.8),), ],), KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolPath(
  name: 'path',
  path: 'M0,0L41,20L41,0L0,0z',filled: true,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],), KnittingSymbol(
  name: 'col5',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 44.9,translation: Offset(0, 7.4),rotation: 0.4363323129985824,), KnittingSymbolPath(
  name: 'path',
  path: 'M0,0L41,20L41,0L0,0z',scale: Offset(-1, 1),filled: true,), ],), ],category: 'Cables v1',description: 'sl 2 sts onto first cn and hold in front, sl 1 st onto 2nd cn and hold in back, k2, p1 from 2nd cn, k2 from first cn',),

    StitchDefinition(
      name: '2/1/2 RPC',
      abbreviation: '212rpc',
      symbols: [
        KnittingSymbol(
          name: 'col1',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, 12.7),rotation: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,scale: Offset(1, -1),translation: Offset(0, -11.3),rotation: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), 
          ],
        ), 
        KnittingSymbol(
          name: 'col2',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, 0.5),rotation: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 25.5,scale: Offset(-1, 1),translation: Offset(-14.4, -3.4),rotation: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), 
          ],
        ), 
        KnittingSymbol(
          name: 'col3',
          parts: [
            KnittingSymbolPath(name: 'path',path: 'M0,0L0,3L20,10L41,3L51,0L0,0z',filled: true,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 28.9,translation: Offset(6.9, 10.2),rotation: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,translation: Offset(-11.1, -8.7),rotation: -0.2792526803190927,), 
            KnittingSymbolPath(name: 'path',path: 'M0,39L0,36L20,30L41,36L41,39L0,39z',translation: Offset(0, 1.4),filled: true,), 
          ],
        ), 
        KnittingSymbol(
          name: 'col4',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, 0.3),rotation: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,scale: Offset(1, -1),translation: Offset(12.5, 2.9),rotation: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), 
          ],
        ), 
        KnittingSymbol(
          name: 'col5',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, -11.6),rotation: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,scale: Offset(1, -1),translation: Offset(0, 11.5),rotation: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 41.8,translation: Offset(-1, 18.5),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
          ],
        ), 
      ],
      category: 'Cables v1',
      description: 'sl 2 sts onto first cn and hold in back, sl 1 st onto 2nd cn and hold in back, k2, p1 from 2nd cn, k2 from first cn',
    ),

    /*********************** Cables v2 **********************/
    
    StitchDefinition(
  name: '2-st LC (LT)',
  abbreviation: '2lc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotation: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43.8,translation: Offset(-1.1, -8.6),rotation: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43,translation: Offset(2.6, 8.5),rotation: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(-3, -9.2),rotation: 0.5235987755982988,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to front, k1, k1 from cn OR with right needle behind left needle, knit 2nd st tbl, knit first st, drop both sts from left needle',),
    
    StitchDefinition(
  name: '2-st RC (RT)',
  abbreviation: '2rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43,translation: Offset(2.6, 8.5),rotation: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(-3, -9.2),rotation: 0.5235987755982988,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotation: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43.8,translation: Offset(-1.1, -8.6),rotation: -0.4188790204786391,), ],), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to back, k1, k1 from cn OR k2tog but do not drop sts from left needle, k1, drop both sts from left needle',),

StitchDefinition(
  name: '2-st LPC',
  abbreviation: '2lpc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotation: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43.8,translation: Offset(-1.1, -8.6),rotation: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43,translation: Offset(2.6, 8.5),rotation: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotation: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to front, k1, p1 from cn',),

StitchDefinition(
  name: '2-st RPC',
  abbreviation: '2rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43,translation: Offset(2.6, 8.5),rotation: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotation: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotation: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43.8,translation: Offset(-1.1, -8.6),rotation: -0.4188790204786391,), ],), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to back, k1, p1 from cn',),

StitchDefinition(
  name: '3-st LC',
  abbreviation: '3lc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotation: -0.2792526803190927,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to front, k2, k1 from cn',),

StitchDefinition(
  name: '3-st RC',
  abbreviation: '3rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotation: -0.2792526803190927,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotation: 0.8203047484373349,), ],), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to back, k2, k1 from cn',),

StitchDefinition(
  name: '3-st LPC',
  abbreviation: '3lpc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotation: -0.2792526803190927,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotation: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 1 st to cn, hold to front, k2, p1 from cn',),

StitchDefinition(
  name: '3-st RPC',
  abbreviation: '3rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotation: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotation: -0.2792526803190927,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotation: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotation: 0.8203047484373349,), ],), ],category: 'Cables v2',description: 'Sl 1 st to cn, hold to back, k2, p1 from cn',),

StitchDefinition(
  name: '4-st LC',
  abbreviation: '4lc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-17.6, 9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 9,translation: Offset(18.5, 4),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotation: -0.20943951023931956,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotation: -0.20943951023931956,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(15.5, -9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 2 sts to cn and hold to front, k2, k2 from cn',),

StitchDefinition(
  name: '4-st RC',
  abbreviation: '4rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(15.5, -9),rotation: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotation: -0.20943951023931956,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 9,translation: Offset(18.5, 4),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotation: -0.20943951023931956,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-17.6, 9),rotation: 0.8203047484373349,), ],), ],category: 'Cables v2',description: 'Sl 2 sts to cn and hold to back, k2, k2 from cn',),

StitchDefinition(
  name: '4-st LPC',
  abbreviation: '4lpc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-9.8, 9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotation: -0.20943951023931956,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 8,translation: Offset(-16.5, -15.6),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 16.7,translation: Offset(15.1, -9.4),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 16,translation: Offset(-6.8, -15.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 12.4,translation: Offset(15.6, -15.6),), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 2 sts to cn and hold to front, p2, k2 from cn',),

StitchDefinition(
  name: '4-st RPC',
  abbreviation: '4rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 16.7,translation: Offset(15.1, -9.4),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 16,translation: Offset(-6.8, -15.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 12.4,translation: Offset(15.6, -15.6),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 8,translation: Offset(-16.5, -15.6),), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotation: -0.20943951023931956,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotation: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-9.8, 9),rotation: 0.8203047484373349,), ],), ],category: 'Cables v2',description: 'Sl 2 sts to cn and hold to back, k2, p2 from cn',),

StitchDefinition(
  name: '5-st LPC',
  abbreviation: '5lpc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -13.4),rotation: -0.17453292519943295,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 22.6,translation: Offset(-9.9, 7.2),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -6.4),rotation: -0.17453292519943295,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 15.3,translation: Offset(-17.1, -2.3),rotation: 0.19198621771937624,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.7),rotation: -0.17453292519943295,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 7.4),rotation: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(12.4, -9.3),rotation: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(14.3, -4.1),rotation: 0.19198621771937624,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotation: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(12.5, -9),rotation: 0.8203047484373349,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',description: 'Sl 2 sts to cn, hold to front, sl 1 st to second cn, hold to back, k2, p1 from back cn, k2 from front cn',),

StitchDefinition(
  name: '5-st RPC',
  abbreviation: '5rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotation: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(15.5, -9),rotation: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 7.4),rotation: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotation: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.7),rotation: -0.17453292519943295,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(14.3, -9.6),rotation: 0.19198621771937624,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(12.4, -15.3),rotation: -0.4363323129985824,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 15.3,translation: Offset(-17.1, -7.7),rotation: 0.19198621771937624,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -6.4),rotation: -0.17453292519943295,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotation: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -13.4),rotation: -0.17453292519943295,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 22.6,translation: Offset(-9.9, 7.2),rotation: 0.8203047484373349,), ],), ],category: 'Cables v2',description: 'Sl 2 sts to cn, hold to back, sl 1 st to second cn, hold to back, k2, p1 from 2nd cn, k2 from first cn',),

  ];

  static Map<String, List<StitchDefinition>> getDefinitionsPerCategory(List<StitchDefinition> customStitches) {
    // TODO: this should be set once only when loading a stitches set
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