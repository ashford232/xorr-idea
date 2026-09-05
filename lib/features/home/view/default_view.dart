import 'package:flutter/material.dart';

class DefaultView extends StatefulWidget {
  const new({super.key});

  @override
  State<DefaultView> createState() => _DefaultViewState();
}

class _DefaultViewState extends State<DefaultView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(backgroundColor: theme.colorScheme.surfaceContainer);
  }
}
