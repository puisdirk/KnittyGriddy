

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class FleatherFontStyle {
  final TextStyle textStyle;

  const FleatherFontStyle({
    required this.textStyle,
  });

  TextStyle textStyleForParchmentStyle(ParchmentStyle pstyle) {
    if (pstyle.contains(ParchmentAttribute.heading)) {
      int? heading = pstyle.get(ParchmentAttribute.heading)!.value;
      if (heading == 1) return textStyle.copyWith(fontSize: textStyle.fontSize! + 18, height: textStyle.height! - 0.15);
      if (heading == 2) return textStyle.copyWith(fontSize: textStyle.fontSize! + 8, height: textStyle.height! - 0.15);
      if (heading == 3) return textStyle.copyWith(fontSize: textStyle.fontSize! + 4, height: textStyle.height! - 0.05);
      if (heading == 4) return textStyle.copyWith(fontSize: textStyle.fontSize! + 2, height: textStyle.height! - 0.05);
      if (heading == 5) return textStyle.copyWith(fontSize: textStyle.fontSize! + 0, height: textStyle.height! - 0.05);
      if (heading == 6) return textStyle.copyWith(fontSize: textStyle.fontSize! + 0, height: textStyle.height! - 0.05);
    }

    if (pstyle.contains(ParchmentAttribute.inlineCode)) return textStyle.copyWith(fontSize: textStyle.fontSize! - 1, height: textStyle.height! + 0.1);

    return textStyle;
  }

  static VerticalSpacing spacingForParchmentStyle(ParchmentStyle pstyle) {

    if (pstyle.contains(ParchmentAttribute.heading)) {
      int? heading = pstyle.get(ParchmentAttribute.heading)!.value;
      if (heading == 1) return const VerticalSpacing(top: 16.0, bottom: 0.0);
      if (heading == 2) return const VerticalSpacing(bottom: 0.0, top: 8.0);
      if (heading == 3) return const VerticalSpacing(bottom: 0.0, top: 8.0);
      if (heading == 4) return const VerticalSpacing(bottom: 0.0, top: 8.0);
      if (heading == 5) return const VerticalSpacing(bottom: 0.0, top: 8.0);
      if (heading == 6) return const VerticalSpacing(bottom: 0.0, top: 8.0);
    }

//    if (pstyle.contains(ParchmentAttribute.quote)) {
//      return const VerticalSpacing(top: 6, bottom: 2);
//    }

    return const VerticalSpacing(top: 6.0, bottom: 10);
  }
}