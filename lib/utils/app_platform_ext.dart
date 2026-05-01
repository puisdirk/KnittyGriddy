
import 'package:simple_platform/simple_platform.dart';

class AppPlatformExt {
  AppPlatformExt._();

  static bool get isWeb => AppPlatform.isWeb;
  static bool get isDesktop => AppPlatform.isLinux || AppPlatform.isWindows || AppPlatform.isMacOS;
}