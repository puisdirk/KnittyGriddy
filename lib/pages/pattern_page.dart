
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/knitting_toolbar.dart';
import 'package:knitty_griddy/controls/pattern_control.dart';

class PatternPage extends StatelessWidget {
  const PatternPage({super.key});

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
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: PatternControl(),
        ),
      ),
    );
  }
}

