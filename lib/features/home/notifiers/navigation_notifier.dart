import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/models/navigation_state.dart';
import 'package:xorr/features/home/models/tab_model.dart';
import 'package:xorr/features/home/view/system_default_view.dart';

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return NavigationState.defaultState;
  }

  void toggle() {
    state = state.copyWith(toggled: !state.toggled);
  }

  void chnageNav(NavigationItem nav) {
    state = state.copyWith(currentItem: nav);
    if (nav.id == TabModel.currentTab.id) {
      addTab(TabModel.currentTab);
      return;
    }
    addTab(
      TabModel(
        id: nav.id,
        emoji: nav.emoji,
        icon: nav.icon,
        name: nav.name,
        item: nav.page ?? SystemDefaultView(),
      ),
    );
  }

  void addTab(TabModel tab) {
    if (state.openedTabs.any((t) => t.id == tab.id)) {
      state = state.copyWith(currentTab: tab);
      return;
    }
    state = state.copyWith(
      openedTabs: {...state.openedTabs, tab},
      currentTab: tab,
    );
  }

  void closeTab(TabModel tab) {
    final tabs = {...state.openedTabs};
    tabs.remove(tab);

    final isCurrentTab = state.currentTab?.id == tab.id;
    final isCurrentNav = state.currentItem?.id == tab.id;

    if (isCurrentTab) {
      final remainingTab = tabs.toList().lastOrNull;

      state = state.copyWith(
        openedTabs: tabs,
        currentTab: remainingTab,
        currentItem: isCurrentNav
            ? _getNavigationItem(remainingTab?.id)
            : state.currentItem,
      );

      return;
    }

    state = state.copyWith(openedTabs: tabs);
  }

  NavigationItem? _getNavigationItem(int? id) {
    if (id == null) return null;

    final all = [
      ...DefaultNavigationData.getDefaultItems,
      DefaultNavigationData.gettingStated,
      DefaultNavigationData.localWorkspace,
      DefaultNavigationData.workspace,
      DefaultNavigationData.account,
    ];

    return all.where((nav) => nav.id == id).firstOrNull;
  }
}
