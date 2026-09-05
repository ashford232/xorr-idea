import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/settings/views/settings_view.dart';
import 'package:xorr/features/workspace/views/archive_view.dart';
import 'package:xorr/features/workspace/views/new_idea_view.dart';
import 'package:xorr/features/workspace/views/notifications_view.dart';
import 'package:xorr/features/workspace/views/favorites_view.dart';
import 'package:xorr/features/workspace/views/recent_view.dart';
import 'package:xorr/features/workspace/views/search_view.dart';
import 'package:xorr/features/workspace/views/trash_view.dart';

class DefaultNavigationData {
  static List<NavigationItem> get getDefaultItems => _defaultItems;
  static final List<NavigationItem> _defaultItems = [
    NavigationItem(
      id: 7,
      type: .user,
      name: "New Idea",
      icon: CupertinoIcons.add_circled,
      emoji: null,
      page: NewIdeaView(),
    ),
    NavigationItem(
      id: 6,
      type: .system,
      name: "Find",
      icon: CupertinoIcons.search,
      emoji: null,
      page: SearchView(),
    ),
    NavigationItem(
      id: 0,
      type: .system,
      name: "Recent",
      icon: CupertinoIcons.time,
      emoji: null,
      page: RecentView(),
    ),
    NavigationItem(
      id: 1,
      type: .user,
      name: "Favorites",
      icon: CupertinoIcons.heart_fill,
      color: Colors.red,
      page: FavoritesView(),
    ),

    NavigationItem(
      id: 2,
      type: .user,
      name: "Archive",
      color: Colors.blueAccent,
      icon: CupertinoIcons.archivebox_fill,
      page: ArchiveView(),
    ),

    NavigationItem(
      id: 3,
      type: .user,
      name: "Trash",
      icon: CupertinoIcons.trash_fill,
      color: Colors.red,

      page: TrashView(),
    ),

    NavigationItem(
      id: 4,
      type: .system,
      name: "Notifications",
      icon: CupertinoIcons.bell_fill,
      page: NotificationsView(),
    ),

    NavigationItem(
      id: 5,
      type: .system,
      name: "Settings",
      icon: CupertinoIcons.gear_alt_fill,
      emoji: null,
      page: SettingsView(),
    ),
  ];
}
