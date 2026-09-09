import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:xorr/data/db/app_db.dart';
import 'package:xorr/features/home/models/navigation_action.dart';
import 'package:xorr/features/home/models/navigation_state.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/features/workspace/controllers/workspace_controller.dart';
import 'package:xorr/features/workspace/notifiers/workspace_notifier.dart';
import 'package:xorr/features/workspace/provider/workspace_provider.dart';
import 'package:xorr/features/workspace/widgets/entity_card.dart';
import 'package:xorr/features/workspace/widgets/workspace_utils.dart';
import 'package:xorr/shared/ui/buttons.dart';
import 'package:xorr/shared/ui/loaders.dart';

class WorkspaceExplorer extends ConsumerStatefulWidget {
  const WorkspaceExplorer({super.key});

  @override
  ConsumerState<WorkspaceExplorer> createState() => _WorkspaceExplorerState();
}

class _WorkspaceExplorerState extends ConsumerState<WorkspaceExplorer> {
  WorkspaceController get controller => ref.read(workspaceControllerProvider);
  NavigationState get navigationState => ref.watch(navigationStateProvider);

  List<NavigationAction> get defaultActions => navigationState.defaultActions;
  AsyncValue<WorkspaceState?> get workspaceStateAsync =>
      ref.watch(workspaceProvider);

  final Set<String> expandedFolders = {};
  final Map<String, List<FileSystemEntity>> folderChildren = {};

  String? selectedEntity;
  String? selectedFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Explorer', style: theme.textTheme.labelLarge),
                ActionBtn(name: 'Open', icon: Icons.add, onPressed: openFolder),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: workspaceStateAsync.when(
                data: (workspaceState) {
                  if (workspaceState == null) {
                    return Column(
                      children: [
                        appButton(
                          size: const Size(double.infinity, 35),
                          text: 'Open folder',
                          onPressed: openFolder,
                        ),
                      ],
                    );
                  }

                  final workspace = workspaceState.workspace;
                  final entities = workspaceState.entities;

                  return Column(
                    children: [
                      explorerTop(workspace, theme),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entities.length,
                          itemBuilder: (context, index) {
                            return _buildEntityNode(entities[index], 0);
                          },
                        ),
                      ),
                    ],
                  );
                },
                error: (err, st) => Center(child: Text(err.toString())),
                loading: () => Center(child: appLoader()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityNode(FileSystemEntity entity, int depth) {
    final entityPath = entity.path;
    final isFolder =
        FileSystemEntity.typeSync(entityPath) != FileSystemEntityType.file;
    final isExpanded = expandedFolders.contains(entityPath);
    final children = folderChildren[entityPath] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntityCard(
          isFile: !isFolder,
          isExpanded: isExpanded,
          entityPath: entityPath,
          isActive: selectedEntity == entityPath,
          depth: depth,
          onTap: () {
            selectedEntity = entityPath;

            if (isFolder) {
              selectedFolder = entityPath;
              toggleFolder(entityPath);
            } else {
              setState(() {});
            }
          },
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  children: children
                      .map((child) => _buildEntityNode(child, depth + 1))
                      .toList(),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }

  Future<void> toggleFolder(String folderPath) async {
    if (expandedFolders.contains(folderPath)) {
      setState(() {
        expandedFolders.remove(folderPath);
      });
      return;
    }

    final directory = Directory(folderPath);
    if (!await directory.exists()) return;

    final children = await directory.list().toList();

    children.sort((a, b) {
      final aIsFolder =
          FileSystemEntity.typeSync(a.path) != FileSystemEntityType.file;
      final bIsFolder =
          FileSystemEntity.typeSync(b.path) != FileSystemEntityType.file;

      if (aIsFolder && !bIsFolder) return -1;
      if (!aIsFolder && bIsFolder) return 1;

      final aName = p.basename(a.path).toLowerCase();
      final bName = p.basename(b.path).toLowerCase();
      return aName.compareTo(bName);
    });

    setState(() {
      expandedFolders.add(folderPath);
      folderChildren[folderPath] = children;
    });
  }

  Row explorerTop(Workspace workspace, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            workspace.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: SizedBox(
            height: 30,
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(width: 5),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final action = defaultActions[index];
                if (expandedFolders.isEmpty &&
                    action.action == NavAction.collapseAll) {
                  return SizedBox.shrink();
                }
                return ActionBtn(
                  name: action.name,
                  icon: action.icon,
                  onPressed: () async {
                    final parentFolder = selectedFolder ?? workspace.path;

                    switch (action.action) {
                      case NavAction.newFile:
                        final fileName = await showNameDialog(
                          context: context,
                          title: 'New File\n$parentFolder:',
                          hintText: 'File name',
                        );
                        if (fileName != null) {
                          final filePath = "$parentFolder/$fileName";
                          await controller.createFile(filePath);
                          selectedEntity = filePath;

                          if (expandedFolders.contains(parentFolder)) {
                            expandedFolders.remove(parentFolder);
                          }
                          await toggleFolder(parentFolder);

                          setState(() {});

                          refresh();
                        }

                      case NavAction.newFolder:
                        final folderName = await showNameDialog(
                          context: context,
                          title: 'New Folder\n$parentFolder:',
                          hintText: 'Folder name',
                        );
                        if (folderName != null) {
                          final folderPath = "$parentFolder/$folderName";
                          await controller.createFolder(folderPath);
                          selectedEntity = folderPath;
                          selectedFolder = folderPath;
                          if (expandedFolders.contains(parentFolder)) {
                            expandedFolders.remove(parentFolder);
                          }
                          await toggleFolder(parentFolder);
                          setState(() {});

                          refresh();
                        }

                      case NavAction.collapseAll:
                        expandedFolders.clear();
                        selectedEntity = null;
                        selectedFolder == null;
                        setState(() {});

                      case NavAction.refresh:
                        refresh();
                    }
                  },
                );
              },
              itemCount: defaultActions.length,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> openFolder() async {
    await controller.openWorkspace();
    refresh();
  }

  void refresh() {
    ref.invalidate(workspaceProvider);
    ref.invalidate(getAllWorkspaceProvider);
  }
}

Future<String?> showNameDialog({
  required BuildContext context,
  required String title,
  required String hintText,
}) async {
  final controller = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hintText,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  onSubmitted: (_) {
                    // final name = controller.text.trim();
                    // if (name.isNotEmpty) {
                    //   Navigator.pop(context, name);
                    // }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.pop(context, name);
                          }
                        },
                        child: const Text(
                          'Create',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  controller.dispose();
  return result;
}
