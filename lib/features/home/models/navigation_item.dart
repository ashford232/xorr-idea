import 'package:flutter/material.dart';

class NavigationItem {
  final int id;
  final NavigationItemType type;
  final String name;
  final IconData? icon;
  final String? emoji;
  final Widget? page;
  final Color? color;

    NavigationItem({
    required this.id,
    required this.type,
    required this.name,
    this.icon,
    this.emoji,
    this.page,
    this.color
  });

}

enum NavigationItemType {
  system("System"),
  custom("Custom"),
  user("User");

  final String name;
  const NavigationItemType(this.name);
}
