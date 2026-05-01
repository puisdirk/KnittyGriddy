import 'package:flutter/material.dart';
import 'package:knitty_griddy/knitty_griddy_app.dart';
import 'package:knitty_griddy/storage/in_memory_model_repository.dart';
import 'package:knitty_griddy/storage/json_files_model_repository.dart';
import 'package:knitty_griddy/storage/model_repository.dart';
import 'package:knitty_griddy/storage/no_op_model_repository.dart';
import 'package:knitty_griddy/utils/app_platform_ext.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final ModelRepository repo = AppPlatformExt.isWeb ? InMemoryModelRepository() : AppPlatformExt.isDesktop ? const JsonFilesModelRepository() : const NoOpModelRepository();

  runApp(
    KnittyGriddyApp(
      repository: repo,
  ));
}
