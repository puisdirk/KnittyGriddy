import 'package:color/color.dart';
import 'dart:ui' as ui;
import 'package:material_color_utilities/contrast/contrast.dart';
import 'package:material_color_utilities/hct/hct.dart';

class ColorUtilities {
  ColorUtilities();

  /// Calculates the complimentary color of a given hex value.
  static HexColor complimentaryFromHex(HexColor passedColor) {
    return complimentaryFromHsl(passedColor.toHslColor()).toHexColor();
  }

  /// Calculates the complimentary color of a given hsl value.
  static HslColor complimentaryFromHsl(HslColor passedColor) {
    var newH = passedColor.h + 180;
    if (newH > 360) newH -= 360;
    var newHslColor = HslColor(newH, passedColor.s, passedColor.l);
    return newHslColor;
  }

  /// Calculates the complimentary color of a given rgb value.
  static RgbColor complimentaryFromRgb(RgbColor passedColor) {
    return complimentaryFromHsl(passedColor.toHslColor()).toRgbColor();
  }

  // From a Material Color
  static ui.Color complimentaryFromColor(ui.Color passedColor) {
    RgbColor rgb = complimentaryFromRgb(RgbColor(passedColor.red, passedColor.green, passedColor.red));
    return ui.Color.fromARGB(passedColor.alpha, rgb.r.toInt(), rgb.b.toInt(), rgb.g.toInt());
  }

  // Get the contrast of a given color
  static ui.Color contrastingFromColor(ui.Color passedColor) {
    Hct original = Hct.fromInt(passedColor.value);
    double lighter = Contrast.lighter(tone: original.tone, ratio: 4.5);
    return ui.Color(Hct.from(original.hue, original.chroma, lighter).toInt());
  }
}