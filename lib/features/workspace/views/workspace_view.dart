import 'dart:async';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/workspace/notifiers/workspace_notifier.dart';
import 'package:xorr/features/workspace/provider/workspace_provider.dart';
import 'package:xorr/features/workspace/widgets/block_wrapper.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

class WorkspaceView extends ConsumerStatefulWidget {
  final String currentTab;

  const WorkspaceView({super.key, required this.currentTab});

  @override
  ConsumerState<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends ConsumerState<WorkspaceView> {
  StreamSubscription? _editorListener;
  EditorState? editorState;
  bool _isLoading = true;
  bool _isSupportedFile = false;

  WorkspaceNotifier get workspaceNotifier =>
      ref.watch(workspaceProvider.notifier);

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void didUpdateWidget(covariant WorkspaceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTab != widget.currentTab) {
      _loadFile();
    }
  }

  Future<void> _loadFile() async {
    setState(() => _isLoading = true);

    final pathExtension = widget.currentTab.toLowerCase();

    if (pathExtension.endsWith('.md') ||
        pathExtension.endsWith('.txt') ||
        pathExtension.endsWith('.db') ||
        pathExtension.endsWith('.xorr')) {
      _isSupportedFile = true;
      String content = '';

      try {
        final file = File(widget.currentTab);
        if (await file.exists()) {
          content = await file.readAsString();
        } else {
          await file.create(recursive: true);
        }
      } catch (e) {
        debugPrint("Error reading file: $e");
        workspaceNotifier.toggleWorkspaceStatus(error: true);
      }

      editorState?.dispose();

      if (content.trim().isEmpty) {
        editorState = EditorState.blank(withInitialText: true);
      } else {
        editorState = EditorState(document: markdownToDocument(content));
      }
      _editorListener?.cancel();

      _editorListener = editorState?.transactionStream.listen((event) {
        final (time, transaction, options) = event;
        if (time == TransactionTime.before) return;

        if (transaction.operations.isNotEmpty) {
          _saveFile();
          workspaceNotifier.toggleWorkspaceStatus(status: false);
        }
      });
    } else {
      _isSupportedFile = false;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  double _currentScaleFactor = 1.0;

  void changeScaleFactor(bool increase) {
    const step = 0.1;
    const minScale = 0.5;
    const maxScale = 2.0;

    if (increase) {
      _currentScaleFactor += step;
    } else {
      _currentScaleFactor -= step;
    }

    _currentScaleFactor = _currentScaleFactor.clamp(minScale, maxScale);

    setState(() {});
  }

  Future<void> _saveFile() async {
    if (editorState == null || !_isSupportedFile) return;

    try {
      final file = File(widget.currentTab);
      final content = documentToMarkdown(editorState!.document);

      await file.writeAsString(content);

      workspaceNotifier.toggleWorkspaceStatus(status: true);
    } catch (e) {
      debugPrint("Error saving file: $e");
      if (mounted) {
        workspaceNotifier.toggleWorkspaceStatus(error: true);
      }
    }
  }

  @override
  void dispose() {
    editorState?.dispose();
    _editorListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isSupportedFile) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Unsupported File Format',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          LogicalKeySet(
            Platform.isMacOS
                ? LogicalKeyboardKey.meta
                : LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyS,
          ): _saveFile,
        },
        child: Focus(
          autofocus: true,
          child: AppFlowyEditor(
            autoFocus: true,
            editorState: editorState!,
            blockComponentBuilders: Map.fromEntries(
              standardBlockComponentBuilderMap.entries.map((entry) {
                if (entry.key == ParagraphBlockKeys.type) {
                  return MapEntry(
                    entry.key,
                    NumberedBlockWrapper(
                      editorState: editorState!,
                      builder: ParagraphBlockComponentBuilder(
                        configuration: BlockComponentConfiguration(
                          padding: (node) =>
                              const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                      ),
                    ),
                  );
                }

                return MapEntry(
                  entry.key,
                  NumberedBlockWrapper(
                    editorState: editorState!,
                    builder: entry.value,
                  ),
                );
              }),
            ),
            editorStyle: EditorStyle.desktop(
              textScaleFactor: _currentScaleFactor,
              padding: EdgeInsets.symmetric(horizontal: 10),
              textStyleConfiguration: TextStyleConfiguration(
                text:
                    theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: AppFonts.inter,
                      height: 1.3,
                      fontSize: 17,
                    ) ??
                    const TextStyle(height: 1.3),
              ),
            ),
            commandShortcutEvents: [
              CommandShortcutEvent(
                getDescription: () => "Save file",
                key: 'Save File',
                command: 'ctrl+s',
                macOSCommand: 'cmd+s',
                handler: (state) {
                  _saveFile();
                  return KeyEventResult.handled;
                },
              ),
              CommandShortcutEvent(
                key: 'Increase Scale',
                command: 'ctrl+i',
                handler: (state) {
                  changeScaleFactor(true);
                  return KeyEventResult.handled;
                },
                getDescription: () => 'Increase Scale',
              ),
              CommandShortcutEvent(
                key: 'Decrease Scale',
                command: 'ctrl+u',
                handler: (state) {
                  changeScaleFactor(false);
                  return KeyEventResult.handled;
                },
                getDescription: () => 'Decrease Scale',
              ),
              ...standardCommandShortcutEvents,
            ],
          ),
        ),
      ),
    );
  }
}
