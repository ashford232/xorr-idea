import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/notifiers/navigation_notifier.dart';

final navigationStateProvider = NotifierProvider(() => NavigationNotifier());
