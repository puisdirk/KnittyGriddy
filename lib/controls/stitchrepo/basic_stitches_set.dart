
import 'dart:ui';

import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_curve.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_text.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';

class BasicStitchesSet extends StitchesSet {

  static const String basicStitchSetId = '7146003f-6dfb-4a4e-bfd5-aca61137ee83';
  static const String noStitchId = '184026cb-4cf2-4d70-959d-90acb2e7182b';

  static const StitchDefinition noStitch = StitchDefinition(
    id: noStitchId,
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
            rotationRad: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r2',
            height: 0.3,
            width: 28,
            translation: Offset(-10, -10),
            rotationRad: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r3',
            height: 0.3,
            width: 45,
            translation: Offset(-3, -3),
            rotationRad: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r4',
            height: 0.3,
            width: 45,
            translation: Offset(3, 3),
            rotationRad: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r5',
            height: 0.3,
            width: 28,
            translation: Offset(10, 10),
            rotationRad: -0.7853981633974483,
          ), 
          KnittingSymbolRectangle(
            name: 'r6',
            height: 0.3,
            translation: Offset(18, 18),
            rotationRad: -0.7853981633974483,
          ), 
        ],
      ), 
    ],
    category: 'General',
  );

static const StitchDefinition knit = StitchDefinition(
    id: '323aef80-0205-4479-b6bc-70b31e931c7a',
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
    id: 'dce04020-2ba0-4c18-bb4e-4128f445d341',
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
            rotationRad: 1.5707963267948966,
          ), 
        ],
      ), 
    ],
    category: 'General',
  );

  BasicStitchesSet() : super(
    id: basicStitchSetId,
    name: 'Basic Set',
    stitchDefinitions: [
      noStitch, knit,

      const StitchDefinition(
      id: 'dacf321a-af4f-4914-84d4-ab0dad37001c',
      name: 'Knit',
      abbreviation: 'k',
      symbols: [
        KnittingSymbol(
          name: '', parts: [],
        ), 
      ],
      category: 'General',
    ),

    purl,

    const StitchDefinition(
      id: '9176acea-1a2c-4941-ab6f-09ca3c35adea',
      name: 'Purl',
      abbreviation: 'p',
      symbols: [
        KnittingSymbol(
          name: '',
          parts: [
            KnittingSymbolArc(
              name: 'arc',height: 6,width: 6,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),

    const StitchDefinition(
      id: 'e0952df8-8d5d-4b12-8e15-b1e9c774c854',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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

    const StitchDefinition(
      id: '16ad6af6-91e5-4dca-b80f-ad32a3e4142d',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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
    const StitchDefinition(
      id: '1168501d-40d8-4a95-b43e-c82faab7ccea',
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
              rotationRad: 1.5707963267948966,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 16,
              rotationRad: 0.7853981633974483,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),
    const StitchDefinition(
      id: '0679be71-096e-4c06-b88a-ac665922ec13',
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
              rotationRad: 1.2740903539558606,
            ), 
            KnittingSymbolCurve(
              name: 'curve',
              length: 29,
              amplitude: 17,
              slant: -17,
              scale: Offset(-1, 1),
              translation: Offset(-4.4, 0),
              rotationRad: 1.2740903539558606,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),
    const StitchDefinition(
      id: '41f494fc-3abf-493f-a979-c5f26c59bbf6',
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
              rotationRad: 1.5707963267948966,
            ), 
            KnittingSymbolCurve(
              name: 'curve',
              length: 15,
              amplitude: 1,
              translation: Offset(10.1, -5.4),
              rotationRad: 4.71238898038469,
            ), 
          ],
        ), 
      ],
      category: 'General',
    ),
    const StitchDefinition(
      id: 'c8ec2cbd-6c9b-44ae-9afc-d014ad62325a',
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

    const StitchDefinition(
      id: '04a26e4a-bb77-4435-ac26-7f54119d2558',
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
              rotationRad: -0.7853981633974483,
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    const StitchDefinition(
      id: 'feb6b120-a184-4171-87e5-0eef97a755ae',
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
              rotationRad: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2', 
              height: 3, 
              width: 14, 
              translation: Offset(5, 5), 
              rotationRad: 0.7853981633974483,
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    const StitchDefinition(
      id: '8e2f5d50-3a7b-462b-8a35-c5f3ec9a2b2e',
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
              rotationRad: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 14,
              translation: Offset(5, 5),
              rotationRad: 0.7853981633974483,
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

    const StitchDefinition(
      id: 'd4e68fad-547d-4c4f-81e7-dafcb3747743',
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
              rotationRad: -0.7853981633974483,
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
    const StitchDefinition(
      id: '45b7855c-be58-42ee-b3c9-15cca0e19a91',
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
              rotationRad: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2', 
              height: 3, 
              width: 14, 
              translation: Offset(5, 5), 
              rotationRad: 0.7853981633974483,
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
    const StitchDefinition(
      id: '02e02869-ec36-4f0c-9172-1ce3cabbbcbf',
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
              rotationRad: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 14,
              translation: Offset(5, 5),
              rotationRad: 0.7853981633974483,
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

    const StitchDefinition(
      id: '8d0b7ae8-d3c6-4020-81a1-eaae27fb6fa8',
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
              rotationRad: -0.7853981633974483,
            ), 
          ],
        ), 
      ], 
      category: 'Decrease',
    ),
    const StitchDefinition(
      id: '6f4e4eaa-6762-411e-b73c-99ab2010f512',
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
              rotationRad: -0.7853981633974483,
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
    const StitchDefinition(
      id: '83f54093-ccb1-4ec3-8eca-000050231a8f',
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
              rotationRad: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 14,
              translation: Offset(5, 5),
              rotationRad: 0.7853981633974483,
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
    const StitchDefinition(
      id: '6b8dd2bb-32a0-4e40-b2ff-3fb65f3df71c',
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
              rotationRad: -0.7853981633974483,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 3,
              width: 14,
              translation: Offset(5, 5),
              rotationRad: 0.7853981633974483,
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

    const StitchDefinition(
      id: '574bb150-5787-4a84-8427-3c13fe0b08e4',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              scale: Offset(1, -1),
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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

    const StitchDefinition(
      id: '4be354d8-1966-4144-b404-dfeebb8e0824',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              scale: Offset(1, -1),
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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

    const StitchDefinition(
      id: '6884ed18-2542-4457-9796-7d34c7c88fc0',
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
              rotationRad: -0.7853981633974483,
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
              rotationRad: 0.7853981633974483,
            ), 
          ],
        ), 
      ],
      category: 'Decrease',
    ),
    const StitchDefinition(
      id: 'c2dd16cc-e97a-4d33-bd5f-4828fc876acd',
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
              rotationRad: -0.7853981633974483,
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
              rotationRad: 0.7853981633974483,
            ), 
          ],
          translation: Offset(-1.7, 0),
        ), 
      ],
      category: 'Decrease',
    ),


    //*************************** INCREASES *****************************/

    const StitchDefinition(
      id: '8f4eb492-bf33-412b-b624-fbac757dc7cd',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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

    const StitchDefinition(
      id: 'cb193481-4a5d-4322-8e1c-d45cdf978f9e',
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

    const StitchDefinition(
      id: '5d7df207-afc0-4a1b-befc-f9da29492922',
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
              rotationRad: 0.7853981633974483,
            ), 
          ],
        ), 
      ],
      category: 'Increase',
    ),

    const StitchDefinition(
      id: 'f2a94def-b85b-41a3-9fbf-17cf3a2e7dd7',
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
    const StitchDefinition(
      id: 'c6ee0546-002a-4229-b914-913f0c50f2ee',
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
    const StitchDefinition(
      id: '119d9898-0a27-43cd-86b1-5b62a0dcd279',
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

    const StitchDefinition(
      id: '3fb85996-212b-44e5-a7d5-ca3681c9fbfc',
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
              rotationRad: -0.7853981633974483,
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

    const StitchDefinition(
      id: '26300080-ec29-447f-a9ad-0035fca3bd0f',
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
              rotationRad: -0.7853981633974483,
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

    const StitchDefinition(
      id: '9dace639-99f5-4384-b060-42cda86d93d5',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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
    const StitchDefinition(
      id: '8fc836b4-aa12-4e83-908a-9c76357ec82a',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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
    const StitchDefinition(
      id: 'aa3ec765-57ab-46c1-b1e7-bdf0176b2386',
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
              rotationRad: -1.0471975511965976,
            ), 
            KnittingSymbolRectangle(
              name: 'r2',
              height: 26,
              width: 3,
              translation: Offset(-7, 0),
              rotationRad: -0.5235987755982988,
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

    const StitchDefinition(
      id: '3b0fe065-72c4-4deb-befe-4e27fe5fa357',
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

    const StitchDefinition(
      id: 'dfc3ff3d-9ea7-4999-83fd-9dcc4bc61bf0',
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

    const StitchDefinition(
      id: '2493660d-820a-4a25-a01f-7056ca3794d5',
  name: '1/1 LC (LT)',
  abbreviation: '1/1lc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.4, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25.1,width: 3,translation: Offset(-9.7, 9),rotationRad: 0.7853981633974483,), ],), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(2.2, 2.2),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 26.1,width: 3,translation: Offset(10.4, -9),rotationRad: 0.7853981633974483,), ],), ],category: 'Cables v1',
  description: 'sl 1 st onto cn, hold in front, k1, k1 from cn \nOR with right needle behind left needle, knit 2nd st tbl, knit first st, \ndrop both sts from left needle',),

    const StitchDefinition(
      id: '820e5952-6f3e-454d-8cbb-28dbd77e875b',
  name: '1/1 RC (RT)',
  abbreviation: '1/1rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(2.2, 2.2),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 26.1,width: 3,translation: Offset(10.4, -9),rotationRad: 0.7853981633974483,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.4, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.7),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25.1,width: 3,translation: Offset(-9.7, 9),rotationRad: 0.7853981633974483,), ],scale: Offset(-1, 1),), ],category: 'Cables v1',
  description: 'sl 1 st onto cn, hold in back, k1, k1 from cn \nOR k2tog but do not drop sts from left needle, k1, \ndrop both sts from left needle',),

    const StitchDefinition(
      id: '11b17e56-fbca-4458-8ee2-de8e913b9c73',
  name: '1/1 LPC',
  abbreviation: '1/1lpc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.8, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.8),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25,width: 3,translation: Offset(-9.9, 9),rotationRad: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 30,translation: Offset(-0.2, 20.6),rotationRad: 0.7853981633974483,), ],), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 53.1,width: 3,translation: Offset(1, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 24.1,width: 3,translation: Offset(10.4, -9),rotationRad: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 30,translation: Offset(1.1, -19.9),rotationRad: 0.7853981633974483,), ],), ],category: 'Cables v1',
  description: 'sl 1 st onto cn, hold in front, p1, k1 from cn',),

    const StitchDefinition(
      id: '1e62dc84-51a8-4c8e-b289-9a0e7d931e88',
  name: '1/1 RPC',
  abbreviation: '1/1rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 53.1,width: 3,translation: Offset(1, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 24.1,width: 3,translation: Offset(10.4, -9),rotationRad: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 30,translation: Offset(1.1, -19.9),rotationRad: 0.7853981633974483,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 60,width: 3,translation: Offset(-1.8, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, 18.8),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 45,width: 3,translation: Offset(0, -18.9),rotationRad: 1.5707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 25,width: 3,translation: Offset(-9.9, 9),rotationRad: 0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 30,translation: Offset(-0.2, 20.6),rotationRad: 0.7853981633974483,), ],scale: Offset(-1, 1),), ],category: 'Cables v1',
  description: 'sl 1 st onto cn, hold in back, k1, p1 from cn',),

const StitchDefinition(
  id: 'f46947bf-11de-4711-a194-ff139d45180a',
  name: '2/1 LC',
  abbreviation: '2/1lc',
  symbols: [KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 3,translation: Offset(10, 12),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.9),), ],scale: Offset(-1, 1),), ],category: 'Cables v1',
  description: 'sl 2 sts onto cn, hold in front, k1, k2 from cn',),

const StitchDefinition(
  id: '6958d3fb-e5d9-4538-98e5-59882c688512',
  name: '2/1 RC',
  abbreviation: '2/1rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.9),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 30,width: 3,translation: Offset(10, 12),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), ],), ],category: 'Cables v1',
  description: 'sl 1 st onto cn, hold in back, k2, k1 from cn',),

const StitchDefinition(
  id: '830fa416-9c07-4d42-b6e3-73999ca23f5f',
  name: '2/1 LPC',
  abbreviation: '2/1lpc',
  symbols: [KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolPath(
  name: 'path',
  path: 'M21,24L0,40L40,40L21,24z',scale: Offset(-1, 1),translation: Offset(-0.7, 0.7),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(10, 12),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.7, 0),rotationRad: -0.767944870877505,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0, 18.7),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolPath(
  name: 'path',
  path: 'M20,24L0,40L40,40L20,24z',scale: Offset(-1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.7),), ],scale: Offset(-1, 1),), ],category: 'Cables v1',
  description: 'sl 2 sts onto cn, hold in front, p1, k2 from cn',),

const StitchDefinition(
  id: 'd5c72b0f-00b2-474c-ba47-ce64588cfb1b',
  name: '2/1 RPC',
  abbreviation: '2/1rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(-1.2, 0),rotationRad: -0.7853981633974483,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolPath(
  name: 'path',
  path: 'M20,24L0,40L40,40L20,24z',scale: Offset(-1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'r',height: 30,width: 3,translation: Offset(-10.1, -12.8),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
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
  name: 'r',height: 30,width: 3,translation: Offset(10, 12),rotationRad: -1.0471975511965976,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.7, 0),rotationRad: -0.767944870877505,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18),), ],), ],category: 'Cables v1',
  description: 'sl 1 st onto cn, hold in back, k2, p1 from cn',),

const StitchDefinition(
  id: 'fca950ae-b86c-4b96-9604-7ca801810110',
  name: '2/2 LC',
  abbreviation: '2/2lc',
  symbols: [KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4, 10.6),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7.8),rotationRad: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 9.9),rotationRad: -0.4014257279586958,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotationRad: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45.7,translation: Offset(0.9, -8.5),rotationRad: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(3.8, 10.1),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), ],), ],category: 'Cables v1',
  description: 'sl 2 sts onto cn, hold in front, k2, k2 from cn',),

const StitchDefinition(
  id: '78b3a0da-51cb-4449-84cb-6f2efe80e8ea',
  name: '2/2 RC',
  abbreviation: '2/2rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45.7,translation: Offset(0.9, -8.5),rotationRad: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(3.8, 10.1),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotationRad: -0.4188790204786391,), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 9.9),rotationRad: -0.4014257279586958,), ],), KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4, 10.6),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7.8),rotationRad: -0.4188790204786391,), ],), ],category: 'Cables v1',
  description: 'sl 2 sts onto cn, hold in back, k2, k2 from cn',),

const StitchDefinition(
  id: '4f1bb1a0-3785-4346-a5a9-73a363a337e0',
  name: '2/2 LPC',
  abbreviation: '2/2lpc',
  symbols: [KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4.6, 11),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.4,width: 40,scale: Offset(-1, 1),translation: Offset(-7.6, 28.8),rotationRad: 1.2042771838760873,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7),rotationRad: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 10.1),rotationRad: -0.3665191429188092,), KnittingSymbolRectangle(
  name: 'rectangle',height: 40,width: 40,translation: Offset(13.6, 27.7),rotationRad: 1.2042771838760873,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotationRad: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 52,width: 40,translation: Offset(-5.9, -28.6),rotationRad: 1.1693705988362009,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0.9, -8.5),rotationRad: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(4.6, 10.6),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.6,width: 40,translation: Offset(-6.6, -25.2),rotationRad: 1.1693705988362009,), ],), ],category: 'Cables v1',
  description: 'sl 2 sts onto cn, hold in front, k2, p2 from cn',),

const StitchDefinition(
  id: '6cfc33e2-c01d-4014-b560-4e7da9904259',
  name: '2/2 RPC',
  abbreviation: '2/2rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 45,translation: Offset(0.9, -8.5),rotationRad: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 53.8,width: 3,translation: Offset(4.6, 10.6),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.7),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.6,width: 40,translation: Offset(-6.6, -25.2),rotationRad: 1.1693705988362009,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, -18.9),), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 85.9,translation: Offset(0, -9),rotationRad: -0.4188790204786391,), KnittingSymbolRectangle(
  name: 'rectangle',height: 52,width: 40,translation: Offset(-5.9, -28.6),rotationRad: 1.1693705988362009,), ],), KnittingSymbol(
  name: 'col3',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.7),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 41,translation: Offset(0, -18.6),), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, 10.1),rotationRad: -0.3665191429188092,), KnittingSymbolRectangle(
  name: 'rectangle',height: 40,width: 40,translation: Offset(13.6, 27.7),rotationRad: 1.2042771838760873,), ],), KnittingSymbol(
  name: 'col4',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, -18.5),), KnittingSymbolRectangle(
  name: 'rectangle',height: 47.7,width: 3,translation: Offset(4.6, 11),rotationRad: -1.1868238913561442,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 41,translation: Offset(0, 18.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 44.4,width: 40,scale: Offset(-1, 1),translation: Offset(-7.6, 28.8),rotationRad: 1.2042771838760873,), KnittingSymbolRectangle(
  name: 'r',height: 3,width: 57,translation: Offset(0.9, -7),rotationRad: -0.4188790204786391,), ],), ],category: 'Cables v1',
  description: 'sl 2 sts onto cn, hold in back, k2, p2 from cn',),

const StitchDefinition(
  id: '1cf04560-ec9d-4804-87c1-761ea1b305de',
  name: '2/1/2 LPC',
  abbreviation: '212lpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolPath(
  name: 'path',
  path: 'M0,0L41,20L41,0L0,0z',scale: Offset(1, -1),filled: true,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 56.3,translation: Offset(3.9, -5.7),rotationRad: 0.4537856055185257,), KnittingSymbolRectangle(
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
  name: 'rectangle',height: 3,width: 44.9,translation: Offset(0, 7.4),rotationRad: 0.4363323129985824,), KnittingSymbolPath(
  name: 'path',
  path: 'M0,0L41,20L41,0L0,0z',scale: Offset(-1, 1),filled: true,), ],), ],category: 'Cables v1',
  description: 'sl 2 sts onto first cn and hold in front, sl 1 st onto 2nd cn and hold in back, \nk2, p1 from 2nd cn, k2 from first cn',),

    const StitchDefinition(
      id: 'bbd486b5-4274-4782-bbd5-f7b4048623ac',
      name: '2/1/2 RPC',
      abbreviation: '212rpc',
      symbols: [
        KnittingSymbol(
          name: 'col1',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, 12.7),rotationRad: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,scale: Offset(1, -1),translation: Offset(0, -11.3),rotationRad: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), 
          ],
        ), 
        KnittingSymbol(
          name: 'col2',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, 0.5),rotationRad: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 25.5,scale: Offset(-1, 1),translation: Offset(-14.4, -3.4),rotationRad: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), 
          ],
        ), 
        KnittingSymbol(
          name: 'col3',
          parts: [
            KnittingSymbolPath(name: 'path',path: 'M0,0L0,3L20,10L41,3L51,0L0,0z',filled: true,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 28.9,translation: Offset(6.9, 10.2),rotationRad: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,translation: Offset(-11.1, -8.7),rotationRad: -0.2792526803190927,), 
            KnittingSymbolPath(name: 'path',path: 'M0,39L0,36L20,30L41,36L41,39L0,39z',translation: Offset(0, 1.4),filled: true,), 
          ],
        ), 
        KnittingSymbol(
          name: 'col4',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, 0.3),rotationRad: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,scale: Offset(1, -1),translation: Offset(12.5, 2.9),rotationRad: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, 18.5),), 
          ],
        ), 
        KnittingSymbol(
          name: 'col5',
          parts: [
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,translation: Offset(0, -11.6),rotationRad: -0.2792526803190927,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 44,scale: Offset(1, -1),translation: Offset(0, 11.5),rotationRad: -0.29670597283903605,), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 41.8,translation: Offset(-1, 18.5),), 
            KnittingSymbolRectangle(name: 'rectangle',height: 3,width: 45,translation: Offset(0, -19),), 
          ],
        ), 
      ],
      category: 'Cables v1',
      description: 'sl 2 sts onto first cn and hold in back, sl 1 st onto 2nd cn and hold in back, \nk2, p1 from 2nd cn, k2 from first cn',
    ),

    /*********************** Cables v2 **********************/
    
    const StitchDefinition(
      id: '7e7b962e-d536-41db-b833-f23b161ae297',
  name: '2-st LC (LT)',
  abbreviation: '2lc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotationRad: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43.8,translation: Offset(-1.1, -8.6),rotationRad: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43,translation: Offset(2.6, 8.5),rotationRad: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(-3, -9.2),rotationRad: 0.5235987755982988,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 1 st to cn and hold to front, k1, k1 from cn \nOR with right needle behind left needle, knit 2nd st tbl, knit first st, \ndrop both sts from left needle',),
    
    const StitchDefinition(
      id: '10c8aae3-649d-45db-a2d9-fb71d99611b6',
  name: '2-st RC (RT)',
  abbreviation: '2rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43,translation: Offset(2.6, 8.5),rotationRad: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(-3, -9.2),rotationRad: 0.5235987755982988,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotationRad: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 3,width: 43.8,translation: Offset(-1.1, -8.6),rotationRad: -0.4188790204786391,), ],), ],category: 'Cables v2',description: 'Sl 1 st to cn and hold to back, k1, k1 from cn \nOR k2tog but do not drop sts from left needle, k1, \ndrop both sts from left needle',),

const StitchDefinition(
  id: '1dcd13ed-8302-4932-96f5-6757ed68fff8',
  name: '2-st LPC',
  abbreviation: '2lpc',
  symbols: [KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotationRad: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43.8,translation: Offset(-1.1, -8.6),rotationRad: -0.4188790204786391,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43,translation: Offset(2.6, 8.5),rotationRad: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotationRad: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 1 st to cn and hold to front, k1, p1 from cn',),

const StitchDefinition(
  id: '78866ac8-c32a-43f2-ab44-390255910c05',
  name: '2-st RPC',
  abbreviation: '2rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43,translation: Offset(2.6, 8.5),rotationRad: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotationRad: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 30,translation: Offset(3, 8.3),rotationRad: 0.5235987755982988,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 43.8,translation: Offset(-1.1, -8.6),rotationRad: -0.4188790204786391,), ],), ],category: 'Cables v2',
  description: 'Sl 1 st to cn and hold to back, k1, p1 from cn',),

const StitchDefinition(
  id: '94e210e8-ef2e-45a6-90b0-739a2ec1c5cd',
  name: '3-st LC',
  abbreviation: '3lc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotationRad: -0.2792526803190927,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 1 st to cn and hold to front, k2, k1 from cn',),

const StitchDefinition(
  id: 'ce508e41-e486-4a9c-8625-470494aaad71',
  name: '3-st RC',
  abbreviation: '3rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotationRad: -0.2792526803190927,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotationRad: 0.8203047484373349,), ],), ],category: 'Cables v2',
  description: 'Sl 1 st to cn and hold to back, k2, k1 from cn',),

const StitchDefinition(
  id: '16bcc97c-7975-4459-b7fa-dd11ce60c047',
  name: '3-st LPC',
  abbreviation: '3lpc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotationRad: -0.2792526803190927,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotationRad: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 1 st to cn, hold to front, k2, p1 from cn',),

const StitchDefinition(
  id: 'da985f13-94b8-4f67-9ab9-3e96ecd89f55',
  name: '3-st RPC',
  abbreviation: '3rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 11.4),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(-7.1, -7),rotationRad: 0.6981317007977318,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(-8, -13.5),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.3),rotationRad: -0.2792526803190927,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11),rotationRad: -0.2792526803190927,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-13.6, 9),rotationRad: 0.8203047484373349,), ],), ],category: 'Cables v2',
  description: 'Sl 1 st to cn, hold to back, k2, p1 from cn',),

const StitchDefinition(
  id: '4e609c72-7da7-47e9-95ed-5924aadc9554',
  name: '4-st LC',
  abbreviation: '4lc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-17.6, 9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 9,translation: Offset(18.5, 4),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotationRad: -0.20943951023931956,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotationRad: -0.20943951023931956,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(15.5, -9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 2 sts to cn and hold to front, k2, k2 from cn',),

const StitchDefinition(
  id: 'caba3e0f-fd8c-41d9-9718-751a0aa4bc88',
  name: '4-st RC',
  abbreviation: '4rc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(15.5, -9),rotationRad: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotationRad: -0.20943951023931956,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 9,translation: Offset(18.5, 4),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotationRad: -0.20943951023931956,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-17.6, 9),rotationRad: 0.8203047484373349,), ],), ],category: 'Cables v2',
  description: 'Sl 2 sts to cn and hold to back, k2, k2 from cn',),

const StitchDefinition(
  id: '102bcabb-c337-47b2-b233-3561a5b8df98',
  name: '4-st LPC',
  abbreviation: '4lpc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-9.8, 9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotationRad: -0.20943951023931956,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 8,translation: Offset(-16.5, -15.6),), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 16.7,translation: Offset(15.1, -9.4),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 16,translation: Offset(-6.8, -15.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 12.4,translation: Offset(15.6, -15.6),), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 2 sts to cn and hold to front, p2, k2 from cn',),

const StitchDefinition(
  id: 'bcddd392-7a66-4258-bb33-ce13ae92264d',
  name: '4-st RPC',
  abbreviation: '4rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 16.7,translation: Offset(15.1, -9.4),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 16,translation: Offset(-6.8, -15.6),), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 12.4,translation: Offset(15.6, -15.6),), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 5.5),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 8,translation: Offset(-16.5, -15.6),), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -3.1),rotationRad: -0.20943951023931956,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -11.6),rotationRad: -0.20943951023931956,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 20.4,translation: Offset(-9.8, 9),rotationRad: 0.8203047484373349,), ],), ],category: 'Cables v2',
  description: 'Sl 2 sts to cn and hold to back, k2, p2 from cn',),

const StitchDefinition(
  id: 'd96ab4c3-1804-4fc8-9ad3-d70ed7f486fd',
  name: '5-st LPC',
  abbreviation: '5lpc',
  symbols: [KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -13.4),rotationRad: -0.17453292519943295,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 22.6,translation: Offset(-9.9, 7.2),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -6.4),rotationRad: -0.17453292519943295,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 15.3,translation: Offset(-17.1, -2.3),rotationRad: 0.19198621771937624,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.7),rotationRad: -0.17453292519943295,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 7.4),rotationRad: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(12.4, -9.3),rotationRad: -0.4363323129985824,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(14.3, -4.1),rotationRad: 0.19198621771937624,), ],scale: Offset(-1, 1),), KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotationRad: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(12.5, -9),rotationRad: 0.8203047484373349,), ],scale: Offset(-1, 1),), ],category: 'Cables v2',
  description: 'Sl 2 sts to cn, hold to front, sl 1 st to second cn, hold to back, \nk2, p1 from back cn, k2 from front cn',),

const StitchDefinition(
  id: 'ffd39649-1c31-48eb-81f5-5b6ac56c665d',
  name: '5-st RPC',
  abbreviation: '5rpc',
  symbols: [KnittingSymbol(
  name: 'col1',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 40,translation: Offset(2.6, 13.5),rotationRad: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(-7, -5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 21.8,translation: Offset(15.5, -9),rotationRad: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'col2',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 7.4),rotationRad: -0.15707963267948966,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 10,translation: Offset(-18, -1.2),rotationRad: 0.8203047484373349,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, 0.7),rotationRad: -0.17453292519943295,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,translation: Offset(14.3, -9.6),rotationRad: 0.19198621771937624,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 15,translation: Offset(12.4, -15.3),rotationRad: -0.4363323129985824,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 15.3,translation: Offset(-17.1, -7.7),rotationRad: 0.19198621771937624,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 45,translation: Offset(0, -6.4),rotationRad: -0.17453292519943295,), ],), KnittingSymbol(
  name: 'blank',
  parts: [KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 27.8,translation: Offset(7, 5.9),rotationRad: 0.8203047484373349,), KnittingSymbolRectangle(
  name: 'rectangle',height: 1.5,width: 39.8,translation: Offset(-1.1, -13.4),rotationRad: -0.17453292519943295,), KnittingSymbolRectangle(
  name: 'r',height: 1.2,width: 22.6,translation: Offset(-9.9, 7.2),rotationRad: 0.8203047484373349,), ],), ],category: 'Cables v2',
  description: 'Sl 2 sts to cn, hold to back, sl 1 st to second cn, hold to back, \nk2, p1 from 2nd cn, k2 from first cn',),

    ]
  );

}