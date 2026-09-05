import 'package:flutter/material.dart';

class FavoritesView extends StatefulWidget {
  const new({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(backgroundColor: theme.colorScheme.surfaceContainer);
  }
}
