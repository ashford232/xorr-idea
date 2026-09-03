import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

abstract class StartupConfig {
  static Future<void> setWindow() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      title: "Xorr Desktop",
      backgroundColor: Colors.transparent,
      center: true,
      minimumSize: Size(400, 500),
      
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
