import 'package:flutter/material.dart';

Future<T?> appPopupMenu<T>(
  BuildContext context,
  Offset position,
  List<PopupMenuEntry<T>> items,
) async {
  return await showMenu<T>(
    popUpAnimationStyle: .noAnimation,
    menuPadding: .zero,
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    items: items,
  );
}
