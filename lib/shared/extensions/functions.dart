import 'package:flutter/material.dart';

abstract class Functions {
  static Color textColorFor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
