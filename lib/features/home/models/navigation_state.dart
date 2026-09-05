import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/models/navigation_item.dart';

class NavigationState {
  final List<NavigationItem> defaultItems;
  final NavigationItem? currentItem;

  NavigationState({required this.defaultItems, required this.currentItem});

  NavigationState copyWith({
    List<NavigationItem>? defaultItems,
    NavigationItem? currentItem,
  }) {
    return NavigationState(
      defaultItems: defaultItems ?? this.defaultItems,
      currentItem: currentItem ?? this.currentItem,
    );
  }

  static final defaultState = NavigationState(
    defaultItems: DefaultNavigationData.getDefaultItems,
    currentItem: null,
  );
}
