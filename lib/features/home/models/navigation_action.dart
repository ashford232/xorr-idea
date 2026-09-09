import 'package:flutter/material.dart';

class NavigationAction {
  final int id;
  final String name;
  final IconData icon;
  final String? emoji;
  final NavAction action;

    NavigationAction({
    required this.id,
    required this.name,
    required this.icon,
    required this.action,
    this.emoji
  });


  NavigationAction copyWith({
    int? id,
    String? name,
    IconData? icon,
    String? emoji,
    NavAction? action
  }) {
    return NavigationAction(
      action: action??this.action,
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      emoji: emoji ?? this.emoji,
    );
  }
}


enum NavAction{
  newFile,
  newFolder,
  refresh,
  collapseAll
}