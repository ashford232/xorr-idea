import 'package:flutter/material.dart';

Widget appLoader({double? size, Color? color, double? strokeWidth}) {
  return SizedBox(
    height: size ?? 20,
    width: size ?? 20,
    child: CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
  );
}
