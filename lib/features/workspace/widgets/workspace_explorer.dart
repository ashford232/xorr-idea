import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:xorr/features/home/models/navigation_action.dart';
import 'package:xorr/features/home/models/navigation_state.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/features/workspace/controllers/workspace_controller.dart';
import 'package:xorr/features/workspace/notifiers/workspace_notifier.dart';
import 'package:xorr/features/workspace/provider/workspace_provider.dart';
import 'package:xorr/features/workspace/widgets/entity_card.dart';
import 'package:xorr/features/workspace/widgets/workspace_utils.dart';
import 'package:xorr/shared/extensions/utils.dart';
import 'package:xorr/shared/ui/buttons.dart';
import 'package:xorr/shared/ui/loaders.dart';
import 'package:xorr/shared/ui/text_fields.dart';

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
  WorkspaceNotifier get workspaceNotifier =>
      ref.watch(workspaceProvider.notifier);

  final Set<String> expandedFolders = {};
  final Map<String, List<FileSystemEntity>> folderChildren = {};

  String _getTargetFolder(WorkspaceState ws) {
    final selectedPath = ws.selectedEntity;
    if (selectedPath == null || selectedPath.isEmpty) {
      return ws.workspace.path;
    }

    final type = FileSystemEntity.typeSync(selectedPath);
    if (type == FileSystemEntityType.file) {
      return p.dirname(selectedPath);
    } else if (type == FileSystemEntityType.directory) {
      return selectedPath;
    }

    return ws.workspace.path;
  }

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
                Flexible(
                  child: Text(
                    'Explorer',
                    style: theme.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ),
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

                  final entities = workspaceState.entities;

                  return Column(
                    children: [
                      explorerTop(workspaceState, theme),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entities.length,
                          itemBuilder: (context, index) {
                            return _buildEntityNode(
                              entities[index],
                              0,
                              workspaceState,
                            );
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

  Widget _buildEntityNode(
    FileSystemEntity entity,
    int depth,
    WorkspaceState ws,
  ) {
    final entityPath = entity.path;
    final isFolder =
        FileSystemEntity.typeSync(entityPath) != FileSystemEntityType.file;
    final isExpanded = expandedFolders.contains(entityPath);
    final children = folderChildren[entityPath] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onSecondaryTapDown: (details) async {
            await _showContextMenu(context, details.globalPosition, entity);
          },
          child: Row(
            children: [
              Expanded(
                child: EntityCard(
                  isFile: !isFolder,
                  isExpanded: isExpanded,
                  entityPath: entityPath,
                  isActive: ws.selectedEntity == entityPath,
                  depth: depth,
                  onTap: () async {
                    if (isFolder) {
                      await _handleFolderTap(entityPath);
                    } else {
                      _changePath(entityPath);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  children: children
                      .map((child) => _buildEntityNode(child, depth + 1, ws))
                      .toList(),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }

  PopupMenuItem<T> popupMenuItem<T>({
    dynamic value,
    double? height,
    required Widget icon,
    required String text,
  }) {
    return PopupMenuItem(
      height: height ?? 25,
      value: value,
      child: Row(children: [icon, const SizedBox(width: 5), Text(text)]),
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    Offset position,
    FileSystemEntity entity,
  ) async {
    final action = await appPopupMenu<XorrDocAction>(context, position, [
      popupMenuItem(
        icon: XorrDocAction.open.icon,
        text: XorrDocAction.open.label,
        value: XorrDocAction.open,
      ),

      popupMenuItem(
        icon: XorrDocAction.rename.icon,
        text: XorrDocAction.rename.label,
        value: XorrDocAction.rename,
      ),

      popupMenuItem(
        icon: XorrDocAction.delete.icon,
        text: XorrDocAction.delete.label,
        value: XorrDocAction.delete,
      ),
      popupMenuItem(
        icon: XorrDocAction.properties.icon,
        text: XorrDocAction.properties.label,
        value: XorrDocAction.properties,
      ),
    ]);

    if (action != null) _handleEntityAction(action, entity);
  }

  Future<void> _handleEntityAction(
    XorrDocAction action,
    FileSystemEntity entity,
  ) async {
    switch (action) {
      case XorrDocAction.open:
        _openEntity(entity);
        break;
      case XorrDocAction.rename:
        await _renameEntity(entity);
        break;
      case XorrDocAction.delete:
        await _deleteEntity(entity);
        break;
      case XorrDocAction.properties:
        await _showProperties(entity);
        break;
    }
  }

  void _openEntity(FileSystemEntity entity) {
    final isFolder =
        FileSystemEntity.typeSync(entity.path) ==
        FileSystemEntityType.directory;
    if (isFolder) {
      _handleFolderTap(entity.path);
    } else {
      _changePath(entity.path);
    }
  }

  Future<void> _renameEntity(FileSystemEntity entity) async {
    final oldName = p.basename(entity.path);
    final newName = await showNameDialog(
      context: context,
      title: 'Rename "$oldName"',
      hintText: 'New name',
      initialValue: oldName,
    );

    if (newName != null && newName.isNotEmpty && newName != oldName) {
      final parentDir = p.dirname(entity.path);
      final newPath = p.join(parentDir, newName);

      try {
        await entity.rename(newPath);

        if (expandedFolders.contains(entity.path)) {
          expandedFolders.remove(entity.path);
          expandedFolders.add(newPath);
        }

        await _refreshFolder(parentDir);
        refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to rename: $e')));
      }
    }
  }

  Future<void> _deleteEntity(FileSystemEntity entity) async {
    final entityName = p.basename(entity.path);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$entityName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await entity.delete(recursive: true);
        final parentDir = p.dirname(entity.path);

        expandedFolders.remove(entity.path);
        folderChildren.remove(entity.path);

        await _refreshFolder(parentDir);
        refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _showProperties(FileSystemEntity entity) async {
    final stat = await entity.stat();
    final isFolder = stat.type == FileSystemEntityType.directory;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isFolder ? "Folder" : "File"} Properties'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${p.basename(entity.path)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Path: ${entity.path}'),
            const SizedBox(height: 8),
            Text('Size: ${(stat.size / 1024).toStringAsFixed(2)} KB'),
            const SizedBox(height: 8),
            Text('Modified: ${stat.modified.toLocal()}'),
            const SizedBox(height: 8),
            Text('Mode: ${stat.modeString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFolderTap(String path) async {
    changeFolder(path);

    if (expandedFolders.contains(path)) {
      setState(() {
        expandedFolders.remove(path);
      });
      return;
    }

    await _expandFolder(path);
  }

  Future<void> _expandFolder(String path) async {
    final directory = Directory(path);

    if (!await directory.exists()) return;

    final children = await directory.list().toList();

    children.sort((a, b) {
      final aIsFolder = a is Directory;
      final bIsFolder = b is Directory;

      if (aIsFolder && !bIsFolder) return -1;
      if (!aIsFolder && bIsFolder) return 1;

      return p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase());
    });

    if (!mounted) return;

    setState(() {
      expandedFolders.add(path);
      folderChildren[path] = children;
    });
  }

  void _changePath(String path) {
    workspaceNotifier.changePath(path: path, file: true);
  }

  void changeFolder(String path) {
    workspaceNotifier.changeFolder(path);
  }

  Future<void> _refreshFolder(String path) async {
    final directory = Directory(path);

    if (!await directory.exists()) return;

    final children = await directory.list().toList();

    children.sort((a, b) {
      final aIsFolder = a is Directory;
      final bIsFolder = b is Directory;

      if (aIsFolder && !bIsFolder) return -1;
      if (!aIsFolder && bIsFolder) return 1;

      return p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase());
    });

    if (!mounted) return;

    setState(() {
      folderChildren[path] = children;
      expandedFolders.add(path);
    });
  }

  Row explorerTop(WorkspaceState ws, ThemeData theme) {
    final workspace = ws.workspace;

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

                return ActionBtn(
                  name: action.name,
                  icon: action.icon,

                  onTapDown: (deatils) async {
                    final position = deatils.globalPosition;
                    final targetFolder = _getTargetFolder(ws);

                    switch (action.action) {
                      case NavAction.newFile:
                        final action = await appPopupMenu<XorrDocumentType>(
                          context,
                          position,
                          [
                            popupMenuItem(
                              icon: XorrDocumentType.doc.icon,
                              text: XorrDocumentType.doc.name,
                              value: XorrDocumentType.doc,
                            ),

                            popupMenuItem(
                              icon: XorrDocumentType.md.icon,
                              text: XorrDocumentType.md.name,
                              value: XorrDocumentType.md,
                            ),
                            popupMenuItem(
                              icon: XorrDocumentType.txt.icon,
                              text: XorrDocumentType.txt.name,
                              value: XorrDocumentType.txt,
                            ),
                            popupMenuItem(
                              icon: XorrDocumentType.html.icon,
                              text: XorrDocumentType.html.name,
                              value: XorrDocumentType.html,
                            ),
                          ],
                        );

                        if (action == null) {
                          return;
                        }

                        if (context.mounted) {
                          final fileName = await showNameDialog(
                            context: context,
                            title: action.name,
                            hintText: 'Name',
                          );

                          if (fileName != null && fileName.isNotEmpty) {
                            final filePath = p.join(
                              targetFolder,
                              "$fileName${action.extension}",
                            );
                            await controller.createFile(filePath);
                            workspaceNotifier.setFolder(targetFolder);
                            await _refreshFolder(targetFolder);

                            _changePath(filePath);
                            refresh();
                          }
                        }
                      case NavAction.newFolder:
                        final folderName = await showNameDialog(
                          context: context,
                          title: 'New Folder',
                          hintText: 'Name',
                        );
                        if (folderName != null && folderName.isNotEmpty) {
                          final folderPath = p.join(targetFolder, folderName);
                          await controller.createFolder(folderPath);
                          await _refreshFolder(targetFolder);

                          _handleFolderTap(folderPath);
                          refresh();
                        }

                      case NavAction.collapseAll:
                        expandedFolders.clear();
                        workspaceNotifier.changeFolder(workspace.path);

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
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);

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
                appTextField(controller: controller, hintText: hintText),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    appButton(
                      size: Size(100, 35),
                      text: 'Create',
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.pop(context, name);
                        }
                      },
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
