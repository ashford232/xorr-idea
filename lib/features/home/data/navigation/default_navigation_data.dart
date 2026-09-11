import 'package:flutter/cupertino.dart';
import 'package:xorr/features/home/models/navigation_action.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/view/default_view.dart';
import 'package:xorr/features/settings/views/settings_view.dart';
import 'package:xorr/features/settings/views/user_account.dart';
import 'package:xorr/features/workspace/views/local_workspace_view.dart';
import 'package:xorr/features/workspace/views/notifications_view.dart';
import 'package:xorr/features/workspace/views/favorites_view.dart';
import 'package:xorr/features/workspace/views/online_workspace_view.dart';
import 'package:xorr/features/workspace/views/search_view.dart';

class DefaultNavigationData {
  static List<NavigationAction> get getDefaultActions => _defaultAction;
  static final List<NavigationAction> _defaultAction = [
    NavigationAction(
      id: 1,
      name: "New File",
      icon: CupertinoIcons.plus,
      action: .newFile,
    ),

    NavigationAction(
      id: 2,
      name: "New Folder",
      action: .newFolder,
      icon: CupertinoIcons.folder_badge_plus,
    ),
    NavigationAction(
      id: 3,
      name: "Refresh",
      icon: CupertinoIcons.refresh,
      action: .refresh,
    ),

    NavigationAction(
      id: 5,
      name: "Collapse Folders in Explorer",
      icon: CupertinoIcons.minus_rectangle,
      action: .collapseAll,
    ),
  ];
  static List<NavigationItem> get getDefaultItems => _defaultItems;
  static final List<NavigationItem> _defaultItems = [
    NavigationItem(
      id: 6,
      type: .system,
      name: "Find",
      icon: CupertinoIcons.search,
      emoji: null,
      page: SearchView(),
    ),

    NavigationItem(
      id: 1,
      type: .user,
      name: "Starred",
      icon: CupertinoIcons.star,
      page: StarredView(),
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
    page: OnlineWorkspaceView(),
  );

  static final NavigationItem localWorkspace = NavigationItem(
    id: 9,
    type: .user,
    name: 'Local',
    icon: CupertinoIcons.folder,
    page: LocalWorkspaceView(),
  );

  static final NavigationItem gettingStated = NavigationItem(
    id: 10,
    type: .system,
    name: 'Getting Started',
    icon: CupertinoIcons.lightbulb,
    page: DefaultView(),
  );
  static final NavigationItem account = NavigationItem(
    id: 11,
    type: .system,
    name: 'User Account',
    icon: CupertinoIcons.person,

    page: UserAccount(),
  );
}
