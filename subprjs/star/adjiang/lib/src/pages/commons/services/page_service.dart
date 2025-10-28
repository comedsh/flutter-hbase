// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:sycomponents/components.dart';

class AdJiangPageService {

  static DarkModeSwitcher get darkModeSwicher => DarkModeSwitcher(
    scale: 0.8,
    isPersistence: true,
    isRespectDeviceTheme: false,
    isDefaultDarkMode: true,
    lightTheme: AppServiceManager.appConfig.appTheme.lightTheme,
    darkTheme: AppServiceManager.appConfig.appTheme.darkTheme
  );

}