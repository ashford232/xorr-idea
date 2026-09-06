import 'package:flutter/cupertino.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/settings/views/settings_view.dart';
import 'package:xorr/features/workspace/views/archive_view.dart';
import 'package:xorr/features/workspace/views/local_workspace_view.dart';
import 'package:xorr/features/workspace/views/new_idea_view.dart';
import 'package:xorr/features/workspace/views/notifications_view.dart';
import 'package:xorr/features/workspace/views/favorites_view.dart';
import 'package:xorr/features/workspace/views/recent_view.dart';
import 'package:xorr/features/workspace/views/search_view.dart';
import 'package:xorr/features/workspace/views/trash_view.dart';
import 'package:xorr/features/workspace/views/workspace_view.dart';

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
      name: "Starred",
      icon: CupertinoIcons.star,
      page: StarredView(),
    ),

    NavigationItem(
      id: 2,
      type: .user,
      name: "Archive",
      icon: CupertinoIcons.archivebox,
      page: ArchiveView(),
    ),

    NavigationItem(
      id: 3,
      type: .user,
      name: "Trash",
      icon: CupertinoIcons.trash,

      page: TrashView(),
    ),

    NavigationItem(
      id: 4,
      type: .system,
      name: "Notifications",
      icon: CupertinoIcons.bell,
      page: NotificationsView(),
    ),

    NavigationItem(
      id: 5,
      type: .system,
      name: "Settings",
      icon: CupertinoIcons.gear,
      emoji: null,
      page: SettingsView(),
    ),
  ];

  static final NavigationItem workspace = NavigationItem(
    id: 8,
    type: .user,
    name: 'Workspace',
    icon: CupertinoIcons.square_stack_3d_up,
    page: WorkspaceView(),
  );

  static final NavigationItem localWorkspace = NavigationItem(
    id: 9,
    type: .user,
    name: 'Local',
    icon: CupertinoIcons.folder,
    page: LocalWorkspaceView(),
  );
}
