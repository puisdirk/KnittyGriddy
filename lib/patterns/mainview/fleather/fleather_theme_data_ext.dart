import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

extension FleatherThemeDataExt on FleatherThemeData {
  static FleatherThemeData withTextStyle(BuildContext context, TextStyle textStyle) {

    final double normalFontSize = textStyle.fontSize?? 16;

    final double inlineFontSize = normalFontSize - 2; // 14;
    final double inlineHeading1FontSize = inlineFontSize + 18; // (32)
    final double inlineHeading2FontSize = inlineFontSize + 8; // (22)
    final double inlineHeading3FontSize = inlineFontSize + 4; // (18)

    final double heading1FontSize = normalFontSize + 18; // (34)
    final double heading2FontSize = normalFontSize + 8; // (24)
    final double heading3FontSize = normalFontSize + 4; // (20)
    final double heading4FontSize = normalFontSize + 2; // (18)
    final double heading5FontSize = normalFontSize + 0; // (16)
    final double heading6FontSize = normalFontSize + 0; // (16)

    final double codeFontSize = normalFontSize - 1; // (13)

    final double normalHeight = textStyle.height?? 1.3; 
    final double heading1Height = normalHeight - 0.15; // 1.15
    final double heading2Height = heading1Height;
    final double heading3Height = normalHeight - 0.05; // 1.25
    final double heading4Height = heading3Height;
    final double heading5Height = heading3Height;
    final double heading6Height = heading3Height;
    final double codeHeight = normalHeight + 0.1; // 1.4

    final themeData = Theme.of(context);
    final defaultStyle = textStyle;
    final baseStyle = defaultStyle.copyWith(
      fontSize: normalFontSize,
      height: normalHeight,
    );
    const baseSpacing = VerticalSpacing(top: 6.0, bottom: 10);

    String fontFamily;
    if (baseStyle.fontFamily != null) {
      switch (themeData.platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          fontFamily = 'Menlo';
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          fontFamily = 'Roboto Mono';
          break;
      }
    } else {
      fontFamily = baseStyle.fontFamily!;
    }

    final inlineCodeStyle = TextStyle(
      fontSize: inlineFontSize,
      color: themeData.colorScheme.primary.withOpacity(0.8),
      fontFamily: fontFamily,
    );

    return FleatherThemeData(
      bold: const TextStyle(fontWeight: FontWeight.bold),
      italic: const TextStyle(fontStyle: FontStyle.italic),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikethrough: const TextStyle(decoration: TextDecoration.lineThrough),
      inlineCode: InlineCodeThemeData(
        backgroundColor: themeData.colorScheme.surfaceContainerHigh,
        radius: const Radius.circular(2),
        style: inlineCodeStyle,
        heading1: inlineCodeStyle.copyWith(
          fontSize: inlineHeading1FontSize,
          fontWeight: FontWeight.w300,
        ),
        heading2: inlineCodeStyle.copyWith(fontSize: inlineHeading2FontSize),
        heading3: inlineCodeStyle.copyWith(
          fontSize: inlineHeading3FontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      link: TextStyle(
        color: themeData.colorScheme.primaryContainer,
        decoration: TextDecoration.underline,
      ),
      paragraph: TextBlockTheme(
        style: baseStyle,
        spacing: baseSpacing,
        // lineSpacing is not relevant for paragraphs since they consist of one line
      ),
      heading1: TextBlockTheme(
        style: baseStyle.copyWith(
          fontSize: heading1FontSize,
          color: baseStyle.color?.withOpacity(0.70),
          height: heading1Height,
          fontWeight: FontWeight.w300,
        ),
        spacing: const VerticalSpacing(top: 16.0, bottom: 0.0),
      ),
      heading2: TextBlockTheme(
        style: baseStyle.copyWith(
          fontSize: heading2FontSize,
          color: baseStyle.color?.withOpacity(0.70),
          height: heading2Height,
          fontWeight: FontWeight.normal,
        ),
        spacing: const VerticalSpacing(bottom: 0.0, top: 8.0),
      ),
      heading3: TextBlockTheme(
        style: baseStyle.copyWith(
          fontSize: heading3FontSize,
          color: baseStyle.color?.withOpacity(0.70),
          height: heading3Height,
          fontWeight: FontWeight.w500,
        ),
        spacing: const VerticalSpacing(bottom: 0.0, top: 8.0),
      ),
      heading4: TextBlockTheme(
        style: baseStyle.copyWith(
          fontSize: heading4FontSize,
          color: baseStyle.color?.withOpacity(0.50),
          height: heading4Height,
          fontWeight: FontWeight.w500,
        ),
        spacing: const VerticalSpacing(bottom: 0.0, top: 8.0),
      ),
      heading5: TextBlockTheme(
        style: baseStyle.copyWith(
          fontSize: heading5FontSize,
          color: baseStyle.color?.withOpacity(0.70),
          height: heading5Height,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
        spacing: const VerticalSpacing(bottom: 0.0, top: 8.0),
      ),
      heading6: TextBlockTheme(
        style: baseStyle.copyWith(
            fontSize: heading6FontSize,
            color: baseStyle.color?.withOpacity(0.50),
            height: heading6Height,
            fontWeight: FontWeight.w500),
        spacing: const VerticalSpacing(bottom: 0.0, top: 8.0),
      ),
      lists: TextBlockTheme(
        style: baseStyle,
        spacing: baseSpacing,
        lineSpacing: const VerticalSpacing(bottom: 0),
      ),
      quote: TextBlockTheme(
        style: baseStyle.copyWith(color: baseStyle.color?.withOpacity(0.6)),
        spacing: baseSpacing,
        lineSpacing: const VerticalSpacing(top: 6, bottom: 2),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(
              width: 4,
              color: themeData.colorScheme.surfaceContainerHigh,
            ),
          ),
        ),
      ),
      code: TextBlockTheme(
        style: baseStyle.copyWith(
          color: themeData.colorScheme.primary.withOpacity(0.8),
          fontFamily: fontFamily,
          fontSize: codeFontSize,
          height: codeHeight,
        ),
        spacing: baseSpacing,
        decoration: BoxDecoration(
          color: themeData.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      horizontalRule: HorizontalRuleThemeData(
        height: baseStyle.fontSize! * baseStyle.height!,
        thickness: 2,
        color: themeData.colorScheme.surfaceContainerHigh,
      ),
    );
  }

}