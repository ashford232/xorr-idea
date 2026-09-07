import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';

class TabModel {
  final int id;
  final String name;
  final String? emoji;
  final Widget item;
  final IconData? icon;

  TabModel({
    required this.id,
    required this.name,
    required this.item,
    this.icon,
    this.emoji,
  });

  TabModel copyWith({
    int? id,
    String? name,
    String? emoji,
    Widget? item,
    ValueGetter<IconData?>? icon,
  }) {
    return TabModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      item: item ?? this.item,
      icon: icon != null ? icon() : this.icon,
    );
  }

  static final Set<TabModel> defaultTabs = {currentTab};
  static final currentTab = TabModel(
    id: DefaultNavigationData.gettingStated.id,
    name: DefaultNavigationData.gettingStated.name,
    item: DefaultNavigationData.gettingStated.page!,
    icon: DefaultNavigationData.gettingStated.icon,
  );
}
