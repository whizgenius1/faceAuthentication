import 'package:facial_authentication/utilities/export_packages.dart';
import 'package:facial_authentication/utilities/export_services.dart';
import 'package:flutter/material.dart';


GetIt locator = GetIt.instance;

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

void setupServices() {
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<CameraService>(() => CameraService());
  locator.registerLazySingleton<FaceDetectionService>(() => FaceDetectionService());
 // locator.registerLazySingleton<MLService>(() => MLService());

}
