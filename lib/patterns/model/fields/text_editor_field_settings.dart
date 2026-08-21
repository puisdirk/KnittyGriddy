
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

enum FontFamily {
  roboto(label: 'Roboto Mono', comment: 'Default for windows and linux'),
  menlo(label: 'Menlo', comment: 'Default for MacOS'),
  pontano(label: 'Pontano', comment: 'Pontano Sans, minimalist and light weighted Sans Serif, designed by Vernon Adams'),
  fredoka(label: 'Fredoka', comment: 'Big, round, bold font, designed by Milena Brandão for Hafontia'),
  nunito(label: 'Nunito', comment: 'Well balanced sans serif, designed by Vernon Adams, Cyreal, Jacques Le Bailly'),
  crimson(label: 'Crimson', comment: 'Crimson Text, an oldstyle serif designed by Sebastian Kosch'),
  prata(label: 'Prata', comment: 'A serif designed by Ivan Petrov for Cyreal'),
  felipa(label: 'Felipa', comment: 'Calligraphic font designed by Fontstage'),
  cookie(label: 'Cookie', comment: 'Legible brush calligraphy, designed by Ania Kruk'),
  argentina(label: 'Argentina', comment: 'Playwrite Argentina. Handwriting font designed by TypeTogether, Veronika Burian, José Scaglione'),
  ;

  final String label;
  final String comment;

  const FontFamily({required this.label, required this.comment});
}

class TextEditorFieldSettings {

  static const double defaultSize = 16;
  static const double defaultHeight = 1.3;

  static const defaultSettings = TextEditorFieldSettings(
    fontFamily: FontFamily.nunito, 
    fontSize: defaultSize, 
    fontHeight: defaultHeight,
  );

  final FontFamily fontFamily;
  final double fontSize;
  final double fontHeight;

  const TextEditorFieldSettings({
    required this.fontFamily,
    required this.fontSize,
    required this.fontHeight,
  });

  TextStyle get style {
    switch (fontFamily) {
      case FontFamily.roboto:
        return GoogleFonts.robotoMono(fontSize: fontSize, height: fontHeight);
      case FontFamily.menlo:
        return TextStyle(fontFamily: 'Menlo', fontFamilyFallback: const['Roboto Mono'], fontSize: fontSize, height: fontHeight);
      case FontFamily.felipa:
        return GoogleFonts.felipa(fontSize: fontSize, height: fontHeight);
      case FontFamily.crimson:
        return GoogleFonts.crimsonText(fontSize: fontSize, height: fontHeight);
      case FontFamily.prata:
        return GoogleFonts.prata(fontSize: fontSize, height: fontHeight);
      case FontFamily.cookie:
        return GoogleFonts.cookie(fontSize: fontSize, height: fontHeight);
      case FontFamily.argentina:
        return GoogleFonts.playwriteAr(fontSize: fontSize, height: fontHeight);
      case FontFamily.fredoka:
        return GoogleFonts.fredoka(fontSize: fontSize, height: fontHeight);
      case FontFamily.pontano:
        return GoogleFonts.pontanoSans(fontSize: fontSize, height: fontHeight);
      case FontFamily.nunito:
        return GoogleFonts.nunito(fontSize: fontSize, height: fontHeight);
    }
  }

  TextEditorFieldSettings copyWith({
    FontFamily? fontFamily,
    double? fontSize,
    double? fontHeight,
  }) {
    return TextEditorFieldSettings(
      fontFamily: fontFamily?? this.fontFamily, 
      fontSize: fontSize?? this.fontSize, 
      fontHeight: fontHeight?? this.fontHeight,
    );
  }

  Map<String, Object> toJson() {
    return {
      'ff': fontFamily.name,
      'fs': fontSize,
      'fh': fontHeight,
    };
  }

  static TextEditorFieldSettings fromJson(Map<String, dynamic> json) {
    return TextEditorFieldSettings(
      fontFamily: FontFamily.values.byName(json['ff'] as String), 
      fontSize: json['fs'] as double, 
      fontHeight: json['fh'] as double,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TextEditorFieldSettings &&
    runtimeType == other.runtimeType &&
    fontFamily == other.fontFamily &&
    fontSize == other.fontSize &&
    fontHeight == other.fontHeight;

  @override
  int get hashCode => super.hashCode ^ fontFamily.hashCode ^ fontSize.hashCode ^ fontHeight.hashCode;

}