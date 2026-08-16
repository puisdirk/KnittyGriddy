import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum PageSize {
  a5(label: 'A5'),
  a4(label: 'A4'),
  a3(label: 'A3'),
  a2(label: 'A2');

  final String label;
  const PageSize({required this.label});
}

enum PageOrientation {
  portrait(label: 'Portrait', iconData: Symbols.desktop_portrait),
  landscape(label: 'Landscape', iconData: Symbols.desktop_landscape);

  final String label;
  final IconData iconData;
  const PageOrientation({required this.label, required this.iconData});
}

@immutable
class PatternPageLayout {
  final PageSize pageSize;
  final PageOrientation pageOrientation;
  final int numberOfPages;
  final bool showPageNumber;
  final bool showGrid;
  
  static const PatternPageLayout defaultLayout = PatternPageLayout(
    pageSize: PageSize.a4, 
    pageOrientation: PageOrientation.portrait, 
    numberOfPages: 1
  );

  const PatternPageLayout({
    required this.pageSize,
    required this.pageOrientation,
    required this.numberOfPages,
    this.showPageNumber = true,
    this.showGrid = true,
  });

  PatternPageLayout copyWith({
    PageSize? pageSize,
    PageOrientation? pageOrientation,
    int? numberOfPages,
    bool? showPageNumber,
    bool? showGrid,
  }) {
    return PatternPageLayout(
      pageSize: pageSize?? this.pageSize, 
      pageOrientation: pageOrientation?? this.pageOrientation,
      numberOfPages: numberOfPages?? this.numberOfPages,
      showPageNumber: showPageNumber?? this.showPageNumber,
      showGrid: showGrid?? this.showGrid,
    );
  }

  Size getDimensionsInMM() {
    switch (pageSize) {
      case PageSize.a5:
        return pageOrientation == PageOrientation.portrait ? const Size(148, 210) : const Size(210, 148);
      case PageSize.a4:
        return pageOrientation == PageOrientation.portrait ? const Size(210, 297) : const Size(297, 210);
      case PageSize.a3:
        return pageOrientation == PageOrientation.portrait ? const Size(297, 420) : const Size(420, 297);
      case PageSize.a2:
        return pageOrientation == PageOrientation.portrait ? const Size(420, 594) : const Size(594, 420);
/*      case PageSize.a1:
        return pageOrientation == PageOrientation.portrait ? const Size(594, 841) : const Size(841, 594);
      case PageSize.a0:
        return pageOrientation == PageOrientation.portrait ? const Size(841, 1189) : const Size(1189, 841);*/
    }    
  }

  static const double pixelsPerMM = 5;
  static const double marginInMM = 10;
  static const double margin = marginInMM * pixelsPerMM;

  double get pageheight => getDimensionsInMM().height * pixelsPerMM;
  double get pagewidth => getDimensionsInMM().width * pixelsPerMM;
  Size get dimensions => Size(pagewidth, pageheight * numberOfPages);

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PatternPageLayout &&
    runtimeType == other.runtimeType &&
    pageSize == other.pageSize &&
    pageOrientation == other.pageOrientation &&
    numberOfPages == other.numberOfPages &&
    showPageNumber == other.showPageNumber &&
    showGrid == other.showGrid;
  
  @override
  int get hashCode => super.hashCode ^ pageSize.hashCode ^ pageOrientation.hashCode ^ numberOfPages.hashCode ^ showPageNumber.hashCode ^ showGrid.hashCode;

  Map<String, Object> toJson() {
    return {
      'si': pageSize.name,
      'or': pageOrientation.name,
      'num': numberOfPages,
      'pn': showPageNumber,
      'gr': showGrid,
    };
  }

  static PatternPageLayout fromJson(Map<String, dynamic> json) {
    return PatternPageLayout(
      pageSize: PageSize.values.byName(json['si'] as String), 
      pageOrientation: PageOrientation.values.byName(json['or'] as String), 
      numberOfPages: json['num'] as int,
      showPageNumber: json['pn'] as bool,
      showGrid: json['gr'] as bool,
    );
  }
}


