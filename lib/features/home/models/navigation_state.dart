import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/models/navigation_item.dart';

class NavigationState {
  final List<NavigationItem> defaultItems;
  final NavigationItem? currentItem;
  final bool toggled;
  

  NavigationState({required this.defaultItems, required this.currentItem, required this.toggled});

  NavigationState copyWith({
    List<NavigationItem>? defaultItems,
    NavigationItem? currentItem,
    bool? toggled
  }) {
    return NavigationState(
      defaultItems: defaultItems ?? this.defaultItems,
      currentItem: currentItem ?? this.currentItem, toggled: toggled??this.toggled,
    );
  }

  static final defaultState = NavigationState(
    defaultItems: DefaultNavigationData.getDefaultItems,
    currentItem: null,
    toggled:  false
  );
}
