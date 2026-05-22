
import 'package:flutter/material.dart';

class StateWidget extends StatefulWidget {

  final void Function() initState;
  final void Function() dispose;

  const StateWidget({
    required this.initState,
    required this.dispose,
    super.key
  });

  @override
  State<StateWidget> createState() => _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {

  @override
  void initState() {
    widget.initState();
    super.initState();
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}