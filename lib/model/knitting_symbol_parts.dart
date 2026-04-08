
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_curve.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';

class KnittingSymbolParts {

  static const KnittingSymbolPart rectangle = KnittingSymbolRectangle(name: 'rectangle', height: 20, width: 20);
  static const KnittingSymbolPart arc = KnittingSymbolArc(name: 'arc', height: 20, width: 20);
  static const KnittingSymbolCurve curve = KnittingSymbolCurve(name: 'curve', length: 20, amplitude: 10);

  static final List<KnittingSymbolPart> parts = [
    rectangle, arc, curve,
  ];

  static const KnittingSymbolPart blankPart = KnittingSymbolPath(name: 'blank', path: '');

  KnittingSymbolPart getSymbolPath(String name) => parts.firstWhere((p) => p.name == name, orElse: () => blankPart);
}