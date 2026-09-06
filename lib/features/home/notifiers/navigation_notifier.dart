import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/models/navigation_state.dart';

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
  }

  void clearNav() {
    state = NavigationState.defaultState.copyWith(toggled: state.toggled);
  }
}
