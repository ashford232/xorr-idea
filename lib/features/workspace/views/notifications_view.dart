import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  const new({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(backgroundColor: theme.colorScheme.surfaceContainer);
  }
}
