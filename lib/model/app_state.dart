
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/stitchrepo/stitch_repository.dart';

// The current tool is derived from the mouse option and the currently selected stitch or colour
enum Tool {
  stitch,
  colour,
  select,
}

// Determines how the mouse will react over the knitting grid. Defaults to singleclick
enum MouseOption {
  singleclick,
  painting,
  selecting,
}

class AppState {

  // The currently selected stitch and colour. One of either is non-null at any given time. If we get into a situation were we
  // need to select a new one without user interaction (e.g. when the currently selected colour is pruned away), we'll set 
  // selectedStitch to noStitch
  final StitchDefinition? selectedStitch;
  final NamedColour? selectedColour;

  // Wheter the knitting grid reacts to single clicks, painting by dragging or manipulating the selection areas
  final MouseOption mouseOption;

  const AppState({
    this.selectedStitch = StitchRepository.noStitch,
    this.selectedColour,
    this.mouseOption = MouseOption.singleclick,
  });

  Tool get currentTool => mouseOption == MouseOption.selecting ? Tool.select : selectedStitch != null ? Tool.stitch : Tool.colour;

  AppState setSelectedStitchDefinition({
    required StitchDefinition stitchDefinition,
  }) {
    return AppState(selectedStitch: stitchDefinition, selectedColour: null, mouseOption: mouseOption);
  }

  AppState setSelectedColour({
    required NamedColour colour,
  }) {
    return AppState(selectedStitch: null, selectedColour: colour, mouseOption: mouseOption);
  }

  AppState setSelectedMouseOption({
    required MouseOption mouseOption,
  }) {
    return AppState(selectedStitch: selectedStitch, selectedColour: selectedColour, mouseOption: mouseOption);
  }
}