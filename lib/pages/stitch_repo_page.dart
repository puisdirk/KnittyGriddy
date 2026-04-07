import 'package:flutter/material.dart';
import 'package:knitty_griddy/stitchrepo/stitch_chooser.dart';

class StitchRepoPage extends StatelessWidget {
  const StitchRepoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stitches'),
        backgroundColor: Colors.grey.shade300,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: StitchChooser()
        ),
      ),
    );
  }
}