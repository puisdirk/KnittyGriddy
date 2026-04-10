
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_curve.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_text.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';

class KnittingSymbolParts {

  static const KnittingSymbolPart rectangle = KnittingSymbolRectangle(name: 'rectangle', height: 20, width: 20);
  static const KnittingSymbolPart arc = KnittingSymbolArc(name: 'arc', height: 20, width: 20);
  static const KnittingSymbolCurve curve = KnittingSymbolCurve(name: 'curve', length: 20, amplitude: 10);
  static const KnittingSymbolText text = KnittingSymbolText(name: 'text');
  static const KnittingSymbolPath path = KnittingSymbolPath(name: 'path', path: 'M10.2122,3.5755C10.2122,3.5755,23.4936,10.4734,23.5233,15.6018C23.5516,20.4831,8.5465,21.1135,8.9363,25.9794C9.1315,28.4164,15.144,35.8603,15.144,35.8603L26.0269,35.7473C26.0269,35.7473,20.1664,28.5508,19.9152,26.2368C19.3927,21.4227,34.1322,20.5705,33.9903,15.7303C33.8394,10.5864,20.4951,3.7454,20.4951,3.7454L10.2122,3.5755zM19.7852,6.4759C21.5429,7.5231,22.5998,8.953,22.5998,8.953M25.3108,11.0866C26.8692,12.4283,27.4187,14.2168,27.4187,14.2168M26.8858,16.857C26.1205,18.3267,23.2871,19.9238,23.2871,19.9238M19.8469,22.0673C18.0057,22.554,15.6434,24.8985,15.6434,24.8985M14.9708,27.3972C15.1995,28.8617,17.4622,31.5418,17.4622,31.5418');

  static final List<KnittingSymbolPart> parts = [
    rectangle, arc, curve, text, path, 
  ];

  static const KnittingSymbolPart blankPart = KnittingSymbolPath(name: 'blank', path: '');

  KnittingSymbolPart getSymbolPath(String name) => parts.firstWhere((p) => p.name == name, orElse: () => blankPart);
}