import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/models/navigation_action.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/models/tab_model.dart';

class NavigationState {
  final List<NavigationItem> defaultItems;
  final List<NavigationAction> defaultActions;
  final NavigationItem? currentItem;
  final bool toggled;

  final Set<TabModel> openedTabs;
  final TabModel? currentTab;

  NavigationState({
    required this.defaultItems,
    required this.currentItem,
    required this.toggled,
    required this.defaultActions,
    required this.openedTabs,
    this.currentTab,
  });

  NavigationState copyWith({
    List<NavigationItem>? defaultItems,
    NavigationItem? currentItem,
    bool? toggled,
    List<NavigationAction>? defaultActions,
    Set<TabModel>? openedTabs,
    TabModel? currentTab,
  }) {
    return NavigationState(
      defaultItems: defaultItems ?? this.defaultItems,
      currentItem: currentItem ?? this.currentItem,
      toggled: toggled ?? this.toggled,
      defaultActions: defaultActions ?? this.defaultActions,
      openedTabs: openedTabs ?? this.openedTabs,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  static final defaultState = NavigationState(
    defaultItems: DefaultNavigationData.getDefaultItems,
    currentItem: null,
    toggled: false,
    defaultActions: DefaultNavigationData.getDefaultActions,
    openedTabs: TabModel.defaultTabs,
    currentTab: TabModel.currentTab,
  );
}
