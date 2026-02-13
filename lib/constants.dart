
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/stitchrepo/stitch_repository.dart';

// Warning: also change defaultStitches when changing these
const int defaultGridRows = 10;
const int defaultGridColumns = 10;

const double stitchCellHeight = 40.0;
const double stitchCellWidth = 40.0;
const double columnsAndRowNumbersWidth = stitchCellWidth;
const double columnsAndRowNumbersHeight = stitchCellHeight;

const defaultMainColor = NamedColour(name: 'MC', color: Colors.white, isMainColor: true);

const List<StitchCell> defaultStitches = [
  StitchCell(row: 1, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 1, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 2, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 2, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 3, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 3, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 4, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 4, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 5, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 5, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 5, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 6, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 6, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 7, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 7, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 8, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 8, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 9, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 9, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),

  StitchCell(row: 10, column: 1, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 2, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 3, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 4, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 5, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 6, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 7, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 8, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 9, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
  StitchCell(row: 10, column: 10, stitchDefinition: StitchRepository.noStitch, colour: defaultMainColor),
];

