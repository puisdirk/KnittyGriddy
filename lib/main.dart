import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knitty_griddy/drawings/storage/drawings_no_op_model_repository.dart';
import 'package:knitty_griddy/knitty_griddy_app.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';
import 'package:knitty_griddy/charts/storage/charts_in_memory_model_repository.dart';
import 'package:knitty_griddy/charts/storage/charts_json_files_model_repository.dart';
import 'package:knitty_griddy/charts/storage/charts_no_op_model_repository.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';
import 'package:knitty_griddy/drawings/storage/drawings_in_memory_model_repository.dart';
import 'package:knitty_griddy/drawings/storage/drawings_json_files_model_repository.dart';
import 'package:knitty_griddy/patterns/storage/patterns_in_memory_model_repository.dart';
import 'package:knitty_griddy/patterns/storage/patterns_json_files_model_repository.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';
import 'package:knitty_griddy/patterns/storage/patterns_no_op_model_repository.dart';
import 'package:knitty_griddy/utils/app_platform_ext.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  GoogleFonts.config.allowRuntimeFetching = false;
  
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });
*/
  final ChartsModelRepository chartsRepo = 
    AppPlatformExt.isWeb ? ChartsInMemoryModelRepository() : 
      AppPlatformExt.isDesktop ?  ChartsJsonFilesModelRepository() : const ChartsNoOpModelRepository();
  
  final DrawingsModelRepository drawingsRepo = 
    AppPlatformExt.isWeb ? DrawingsInMemoryModelRepository() : 
      AppPlatformExt.isDesktop ?  DrawingsJsonFilesModelRepository() : const DrawingsNoOpModelRepository();

  final PatternsModelRepository patternsRepo = 
    AppPlatformExt.isWeb ? PatternsInMemoryModelRepository() : 
      AppPlatformExt.isDesktop ?  PatternsJsonFilesModelRepository() : const PatternsNoOpModelRepository();

  runApp(
    KnittyGriddyApp(
      chartsRepository: chartsRepo,
      drawingsRepository: drawingsRepo,
      patternsRepository: patternsRepo,
  ));
}
