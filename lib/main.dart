import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:knitty_griddy/knitty_griddy_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const Portal(
      child: KnittyGriddyApp(
      // TODO: would pass repository here
        ),
    ));
}
