import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:xorr/features/workspace/widgets/workspace_explorer.dart';

class LocalWorkspaceView extends StatefulWidget {
  const LocalWorkspaceView({super.key});

  @override
  State<LocalWorkspaceView> createState() => _LocalWorkspaceViewState();
}

class _LocalWorkspaceViewState extends State<LocalWorkspaceView> {
  final _multiSplitController = MultiSplitViewController();

  @override
  void initState() {
    super.initState();
    _multiSplitController.areas = [
      Area(
        min: 100,
        max: 400,
        size: 300,
        builder: (context, area) => WorkspaceExplorer(),
      ),

      Area(
        size: 0.75,

        builder: (context, area) => WorkspaceMainView(),
      ),
    ];
    _multiSplitController.addListener(_rebuild);
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  void dispose() {
    _multiSplitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiSplitView(
        dividerBuilder: (
          axis,
          index,
          resizable,
          dragging,
          highlighted,
          themeData,
        ) => VerticalDivider(width: 1),
        controller: _multiSplitController,
      ),
    );
  }
}

class WorkspaceMainView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
