import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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


  NavigationItem copyWith({
    int? id,
    NavigationItemType? type,
    String? name,
    ValueGetter<IconData?>? icon,
    ValueGetter<String?>? emoji,
    ValueGetter<Widget?>? page,
    ValueGetter<Color?>? color,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      icon: icon != null ? icon() : this.icon,
      emoji: emoji != null ? emoji() : this.emoji,
      page: page != null ? page() : this.page,
      color: color != null ? color() : this.color,
    );
  }
}

enum NavigationItemType {
  system("System"),
  custom("Custom"),
  user("User");

  final String name;
  const NavigationItemType(this.name);
}
