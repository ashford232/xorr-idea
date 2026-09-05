import 'package:flutter/material.dart';

class TrashView extends StatefulWidget {
  const new({super.key});

  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(backgroundColor: theme.colorScheme.surfaceContainer);
  }
}
