import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

abstract class StartupConfig {
  static Future<void> setWindow() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      title: "Xorr IDEA",
      backgroundColor: Colors.transparent,
      minimumSize: Size(500, 400),

      center: true,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimumSize(const Size(500, 400));
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
