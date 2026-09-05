import 'package:flutter/material.dart';

class NewIdeaView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(backgroundColor: theme.colorScheme.surfaceContainer);
  }
}
