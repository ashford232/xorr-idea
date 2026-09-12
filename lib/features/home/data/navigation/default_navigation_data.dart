import 'package:flutter/cupertino.dart';
import 'package:xorr/features/home/models/navigation_action.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/view/default_view.dart';
import 'package:xorr/features/settings/views/settings_view.dart';
import 'package:xorr/features/settings/views/user_account.dart';
import 'package:xorr/features/workspace/views/favorites_view.dart';
import 'package:xorr/features/workspace/views/online_workspace_view.dart';

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
      id: 8,
      type: .user,
      name: 'Workspace',
      icon: CupertinoIcons.square_stack_3d_up,
      page: OnlineWorkspaceView(),
    ),

    NavigationItem(
      id: 1,
      type: .user,
      name: "Starred",
      icon: CupertinoIcons.star,
      page: StarredView(),
    ),

    NavigationItem(
      id: 11,
      type: .system,
      name: 'User Account',
      icon: CupertinoIcons.person,

      page: UserAccount(),
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

  static final NavigationItem gettingStated = NavigationItem(
    id: 10,
    type: .system,
    name: 'Getting Started',
    icon: CupertinoIcons.lightbulb,
    page: DefaultView(),
  );
}

int getPageIndex(int id) {
  final items = DefaultNavigationData._defaultItems;

  for (final ni in items) {
    if (ni.id == id) {
      return items.indexOf(ni);
    }
  }
  return 0;
}
