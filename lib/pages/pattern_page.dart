
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/controls/editgrid/grid_settings_control.dart';
import 'package:knitty_griddy/controls/toolbar/knitting_toolbar.dart';
import 'package:knitty_griddy/controls/maingrid/pattern_control.dart';
import 'package:knitty_griddy/stitchrepo/font_service.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
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
    FocusScope.of(context).autofocus(_focusNode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knitty-Griddy'),
        backgroundColor: Colors.grey.shade300,
        bottom: const PreferredSize(
          preferredSize: Size(20000, 200), 
          child: KnittingToolbar(),
        ),
        actions: [
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
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridSettingsControl(),
                    SizedBox(height: 10,),
                    PatternControl(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

