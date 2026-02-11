
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/controls/knitting_toolbar.dart';
import 'package:knitty_griddy/controls/pattern_control.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class PatternPage extends StatefulWidget {

  const PatternPage({super.key});

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  late FocusNode _focusNode;

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
        )
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

