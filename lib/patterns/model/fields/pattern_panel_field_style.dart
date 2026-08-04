import 'package:flutter/material.dart';

@immutable
class PatternPanelFieldStyle {

  static const Color kDefaultBackgroundColor = Colors.white;
  static const Color kDefaultBorderColor = Colors.black;
  static const double kDefaultBorderWidth = 1;
  static const double kDefaultBorderRadius = 0;

  final Color backgroundColor;
  final Color leftBorderColor;
  final Color rightBorderColor;
  final Color topBorderColor;
  final Color bottomBorderColor;
  final double leftBorderWidth;
  final double rightBorderWidth;
  final double topBorderWidth;
  final double bottomBorderWidth;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;

  const PatternPanelFieldStyle({
    this.backgroundColor = kDefaultBackgroundColor,
    this.leftBorderColor = kDefaultBorderColor,
    this.rightBorderColor = kDefaultBorderColor,
    this.topBorderColor = kDefaultBorderColor,
    this.bottomBorderColor = kDefaultBorderColor,
    this.leftBorderWidth = kDefaultBorderWidth,
    this.rightBorderWidth = kDefaultBorderWidth,
    this.topBorderWidth = kDefaultBorderWidth,
    this.bottomBorderWidth = kDefaultBorderWidth,
    this.topLeftRadius = kDefaultBorderRadius,
    this.topRightRadius = kDefaultBorderRadius,
    this.bottomLeftRadius = kDefaultBorderRadius,
    this.bottomRightRadius = kDefaultBorderRadius,
  });

  PatternPanelFieldStyle copyWith({
    Color? backgroundColor,
    Color? leftBorderColor,
    Color? rightBorderColor,
    Color? topBorderColor,
    Color? bottomBorderColor,
    double? leftBorderWidth,
    double? rightBorderWidth,
    double? topBorderWidth,
    double? bottomBorderWidth,
    double? topLeftRadius,
    double? topRightRadius,
    double? bottomLeftRadius,
    double? bottomRightRadius,
  }) {
    return PatternPanelFieldStyle(
      backgroundColor: backgroundColor?? this.backgroundColor,
      leftBorderColor: leftBorderColor?? this.leftBorderColor,
      rightBorderColor: rightBorderColor?? this.rightBorderColor,
      topBorderColor: topBorderColor?? this.topBorderColor,
      bottomBorderColor: bottomBorderColor?? this.bottomBorderColor,
      leftBorderWidth: leftBorderWidth?? this.leftBorderWidth,
      rightBorderWidth: rightBorderWidth?? this.rightBorderWidth,
      topBorderWidth: topBorderWidth?? this.topBorderWidth,
      bottomBorderWidth: bottomBorderWidth?? this.bottomBorderWidth,
      topLeftRadius: topLeftRadius?? this.topLeftRadius,
      topRightRadius: topRightRadius?? this.topRightRadius,
      bottomLeftRadius: bottomLeftRadius?? this.bottomLeftRadius,
      bottomRightRadius: bottomRightRadius?? this.bottomRightRadius,
    );
  }

  bool get canSetRadius => 
    leftBorderColor == rightBorderColor && 
    rightBorderColor == topBorderColor && 
    topBorderColor == bottomBorderColor;

  Map<String, Object> toJson() {
    Map<String, Object> o = {
    };

    if (leftBorderWidth != kDefaultBorderWidth) {
      o['lbw'] = leftBorderWidth;
    }

    if (rightBorderWidth != kDefaultBorderWidth) {
      o['rbw'] = rightBorderWidth;
    }

    if (topBorderWidth != kDefaultBorderWidth) {
      o['tbw'] = topBorderWidth;
    }

    if (bottomBorderWidth != kDefaultBorderWidth) {
      o['bbw'] = bottomBorderWidth;
    }

    if (topLeftRadius != kDefaultBorderRadius) {
      o['tlr'] = topLeftRadius;
    }

    if (topRightRadius != kDefaultBorderRadius) {
      o['trr'] = topRightRadius;
    }

    if (bottomLeftRadius != kDefaultBorderRadius) {
      o['blr'] = bottomLeftRadius;
    }

    if (bottomRightRadius != kDefaultBorderRadius) {
      o['brr'] = bottomRightRadius;
    }

    if (backgroundColor != kDefaultBackgroundColor) {
      o['bgcol'] = {'red': backgroundColor.red, 'blue': backgroundColor.blue, 'green': backgroundColor.green, 'alpha': backgroundColor.alpha};
    }

    if (leftBorderColor != kDefaultBorderColor) {
      o['lbcol'] = {'red': leftBorderColor.red, 'blue': leftBorderColor.blue, 'green': leftBorderColor.green, 'alpha': leftBorderColor.alpha};
    }

    if (rightBorderColor != kDefaultBorderColor) {
      o['rbcol'] = {'red': rightBorderColor.red, 'blue': rightBorderColor.blue, 'green': rightBorderColor.green, 'alpha': rightBorderColor.alpha};
    }

    if (topBorderColor != kDefaultBorderColor) {
      o['tbcol'] = {'red': topBorderColor.red, 'blue': topBorderColor.blue, 'green': topBorderColor.green, 'alpha': topBorderColor.alpha};
    }

    if (bottomBorderColor != kDefaultBorderColor) {
      o['bbcol'] = {'red': bottomBorderColor.red, 'blue': bottomBorderColor.blue, 'green': bottomBorderColor.green, 'alpha': bottomBorderColor.alpha};
    }

    return o;
  }

  static PatternPanelFieldStyle fromJson(Map<String, dynamic> json) {
    return PatternPanelFieldStyle(
      backgroundColor: json.containsKey('bgcol') ? Color.fromARGB(json['bgcol']['alpha'] as int, json['bgcol']['red'] as int, json['bgcol']['green'] as int, json['bgcol']['blue'] as int) : kDefaultBackgroundColor,
      leftBorderColor: json.containsKey('lbcol') ? Color.fromARGB(json['lbcol']['alpha'] as int, json['lbcol']['red'] as int, json['lbcol']['green'] as int, json['lbcol']['blue'] as int) : kDefaultBorderColor,
      rightBorderColor: json.containsKey('rbcol') ? Color.fromARGB(json['rbcol']['alpha'] as int, json['rbcol']['red'] as int, json['rbcol']['green'] as int, json['rbcol']['blue'] as int) : kDefaultBorderColor,
      topBorderColor: json.containsKey('tbcol') ? Color.fromARGB(json['tbcol']['alpha'] as int, json['tbcol']['red'] as int, json['tbcol']['green'] as int, json['tbcol']['blue'] as int) : kDefaultBorderColor,
      bottomBorderColor: json.containsKey('bbcol') ? Color.fromARGB(json['bbcol']['alpha'] as int, json['bbcol']['red'] as int, json['bbcol']['green'] as int, json['bbcol']['blue'] as int) : kDefaultBorderColor,
      leftBorderWidth: json.containsKey('lbw') ? json['lbw'] as double : kDefaultBorderWidth,
      rightBorderWidth: json.containsKey('rbw') ? json['rbw'] as double : kDefaultBorderWidth,
      topBorderWidth: json.containsKey('tbw') ? json['tbw'] as double : kDefaultBorderWidth,
      bottomBorderWidth: json.containsKey('bbw') ? json['bbw'] as double : kDefaultBorderWidth,
      topLeftRadius: json.containsKey('tlr') ? json['tlr'] as double : kDefaultBorderRadius,
      topRightRadius: json.containsKey('trr') ? json['trr'] as double : kDefaultBorderRadius,
      bottomLeftRadius: json.containsKey('blr') ? json['blr'] as double : kDefaultBorderRadius,
      bottomRightRadius: json.containsKey('brr') ? json['brr'] as double : kDefaultBorderRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PatternPanelFieldStyle &&
    runtimeType == other.runtimeType &&
    backgroundColor == other.backgroundColor &&
    leftBorderColor == other.leftBorderColor &&
    rightBorderColor == other.rightBorderColor &&
    topBorderColor == other.topBorderColor &&
    bottomBorderColor == other.bottomBorderColor &&
    leftBorderWidth == other.leftBorderWidth &&
    rightBorderWidth == other.rightBorderWidth &&
    topBorderWidth == other.topBorderWidth &&
    bottomBorderWidth == other.bottomBorderWidth &&
    topLeftRadius == other.topLeftRadius &&
    topRightRadius == other.topRightRadius &&
    bottomLeftRadius == other.bottomLeftRadius &&
    bottomRightRadius == other.bottomRightRadius;

  @override
  int get hashCode => super.hashCode ^ backgroundColor.hashCode ^
    leftBorderColor.hashCode ^ rightBorderColor.hashCode ^ topBorderColor.hashCode ^ bottomBorderColor.hashCode ^
    leftBorderWidth.hashCode ^ rightBorderWidth.hashCode ^ topBorderWidth.hashCode ^ bottomBorderWidth.hashCode ^
    topLeftRadius.hashCode ^ topRightRadius.hashCode ^ bottomLeftRadius.hashCode ^ bottomRightRadius.hashCode;
}