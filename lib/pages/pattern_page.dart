
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:knitty_griddy/controls/toolbar/knitting_toolbar.dart';
import 'package:knitty_griddy/controls/pattern_control.dart';
import 'package:knitty_griddy/model/font_service.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/pages/grid_settings_view.dart';
import 'package:provider/provider.dart';

class PatternPage extends StatefulWidget {

  const PatternPage({super.key});

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  late FocusNode _focusNode;
  bool isGridSettingsMenuOpen = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knitty-Griddy'),
        backgroundColor: Colors.grey.shade300,
        bottom: const PreferredSize(
          preferredSize: Size(20000, 200), 
          child: KnittingToolbar(),
        ),
        actions: [
          PortalTarget(
            visible: isGridSettingsMenuOpen,
            anchor: const Aligned(
              follower: Alignment.topRight, 
              target: Alignment.bottomRight
            ),
            portalFollower: Container(
              color: Colors.white, 
              child: GridSettingsView(
                onClose: () => setState(() => isGridSettingsMenuOpen = false)
              ),
            ), 
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => setState(() => isGridSettingsMenuOpen = !isGridSettingsMenuOpen),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async => await FontService.parseFont(),
          )
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyZ && 
            (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              Provider.of<KnittyGriddyModel>(context, listen: false).redo();
            } else {
              Provider.of<KnittyGriddyModel>(context, listen: false).undo();
            }
          }
        },
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: PatternControl(),
          ),
        ),
      ),
    );
  }
}

