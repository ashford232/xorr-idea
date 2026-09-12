import 'dart:async';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/workspace/models/online_item.dart';
import 'package:xorr/features/workspace/widgets/block_wrapper.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

class OnlineWorkspaceView extends ConsumerStatefulWidget {
  const OnlineWorkspaceView({super.key});

  @override
  ConsumerState<OnlineWorkspaceView> createState() =>
      _OnlineWorkspaceViewState();
}

class _OnlineWorkspaceViewState extends ConsumerState<OnlineWorkspaceView> {
  // State
  final _titleController = TextEditingController();
  final _searchController = TextEditingController();
  final List<OnlineItem> _items = [];

  // Editor & Async
  StreamSubscription? _editorListener;
  Timer? _saveDebounce;
  EditorState? _editorState;

  // UI State
  int? _selectedNoteId;
  bool _isLoading = true;
  bool _isSaving = false;
  double _scaleFactor = 1.0;
  String _searchQuery = '';
  double _sidebarWidth = 280.0; // Desktop-friendly resizable sidebar width

  // Filtered items based on search
  List<OnlineItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final query = _searchQuery.toLowerCase();
    return _items.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _editorListener?.cancel();
    _editorState?.dispose();
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Data Logic ---

  Future<void> _loadItems() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final items = await ref.read(onlineItemsRepositoryProvider).getAll();
      if (!mounted) return;

      _items
        ..clear()
        ..addAll(items);

      final selected = _selectedNoteId == null
          ? (_items.isEmpty ? null : _items.first.id)
          : _items.any((item) => item.id == _selectedNoteId)
          ? _selectedNoteId
          : (_items.isEmpty ? null : _items.first.id);

      if (selected == null) {
        _disposeEditor();
      } else {
        await _selectItem(selected);
      }
    } catch (error) {
      _showError('Failed to load items: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectItem(int? id) async {
    if (id == null) return;

    // Save current before switching
    if (_saveDebounce?.isActive ?? false) {
      await _saveNote();
    }

    final item = _items.firstWhere((item) => item.id == id);

    _saveDebounce?.cancel();
    await _editorListener?.cancel();
    _editorState?.dispose();

    _selectedNoteId = item.id;
    _titleController.text = item.title;

    _editorState = item.content.trim().isEmpty
        ? EditorState.blank(withInitialText: true)
        : EditorState(document: markdownToDocument(item.content));

    _editorListener = _editorState!.transactionStream.listen((event) {
      final (time, transaction, _) = event;
      if (time == TransactionTime.before || transaction.operations.isEmpty)
        return;
      _scheduleSave();
    });

    if (mounted) setState(() {});
  }

  Future<void> _createItem() async {
    try {
      final item = await ref
          .read(onlineItemsRepositoryProvider)
          .create(title: 'Untitled', content: '');

      if (!mounted) return;

      _items.insert(0, item);
      _searchController.clear(); // Clear search to see new item
      await _selectItem(item.id);
    } catch (error) {
      _showError('Failed to create note: $error');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await ref.read(onlineItemsRepositoryProvider).delete(id);
      if (!mounted) return;

      _items.removeWhere((item) => item.id == id);

      if (_selectedNoteId == id) {
        _disposeEditor();
        if (_items.isNotEmpty) await _selectItem(_items.first.id);
      }
      setState(() {});
    } catch (error) {
      _showError('Failed to delete note: $error');
    }
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 750), _saveNote);
  }

  Future<void> _saveNote() async {
    final id = _selectedNoteId;
    final editorState = _editorState;

    if (id == null || editorState == null || _isSaving) return;

    if (mounted) setState(() => _isSaving = true);

    final title = _titleController.text.trim().isEmpty
        ? 'Untitled'
        : _titleController.text.trim();

    try {
      final content = documentToMarkdown(editorState.document);

      await ref
          .read(onlineItemsRepositoryProvider)
          .update(id: id, title: title, content: content);

      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = _items[index];
        _items[index] = OnlineItem(
          id: old.id,
          title: title,
          content: content,
          userId: old.userId,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
      }
    } catch (error) {
      _showError('Failed to save: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _changeScale(bool increase) {
    setState(() {
      _scaleFactor = (_scaleFactor + (increase ? 0.1 : -0.1)).clamp(0.8, 2.0);
    });
  }

  void _disposeEditor() {
    _saveDebounce?.cancel();
    _editorListener?.cancel();
    _editorState?.dispose();
    _editorState = null;
    _selectedNoteId = null;
    _titleController.clear();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          _buildSidebar(context),
          _buildDraggableDivider(),
          Expanded(child: _buildEditorArea(context)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: _sidebarWidth,
      child: Column(
        children: [
          // Sidebar Header & Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workspace',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      onPressed: _loadItems,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      iconSize: 20,
                      onPressed: _createItem,
                      icon: const Icon(Icons.edit_square),
                      tooltip: 'New Note',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),

          const Divider(height: 1),

          // Notes List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No notes yet'
                          : 'No matches found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item.id == _selectedNoteId;

                      return _buildSidebarItem(item, isSelected, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(OnlineItem item, bool isSelected, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _selectItem(item.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.isEmpty ? 'Untitled' : item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (item.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.content.replaceAll('\n', ' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing actions (Context Menu)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'delete') _deleteItem(item.id);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableDivider() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            _sidebarWidth = max(
              200,
              min(500, _sidebarWidth + details.delta.dx),
            );
          });
        },
        child: Container(
          width: 4,
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildEditorArea(BuildContext context) {
    if (_editorState == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_document,
              size: 64,
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a note or create a new one.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createItem,
              icon: const Icon(Icons.add),
              label: const Text('New Note'),
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _saveNote,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            _saveNote, // Mac support
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            // Editor Toolbar / Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      onChanged: (_) => _scheduleSave(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.inter,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Note Title',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),

                  // Save Status Indicator
                  AnimatedOpacity(
                    opacity: _isSaving ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saving...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Zoom Controls
                  IconButton(
                    onPressed: () => _changeScale(false),
                    icon: const Icon(Icons.remove),
                    tooltip: 'Zoom Out',
                    splashRadius: 20,
                  ),
                  Text(
                    '${(_scaleFactor * 100).toInt()}%',
                    style: theme.textTheme.bodySmall,
                  ),
                  IconButton(
                    onPressed: () => _changeScale(true),
                    icon: const Icon(Icons.add),
                    tooltip: 'Zoom In',
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // AppFlowy Editor
            Expanded(
              child: AppFlowyEditor(
                autoFocus: true,
                editorState: _editorState!,
                blockComponentBuilders: Map.fromEntries(
                  standardBlockComponentBuilderMap.entries.map((entry) {
                    if (entry.key == ParagraphBlockKeys.type) {
                      return MapEntry(
                        entry.key,
                        NumberedBlockWrapper(
                          editorState: _editorState!,
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
                        editorState: _editorState!,
                        builder: entry.value,
                      ),
                    );
                  }),
                ),
                editorStyle: EditorStyle.desktop(
                  textScaleFactor: _scaleFactor,
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
                    getDescription: () => "",
                    key: 'Save Item',
                    command: 'ctrl+s',
                    macOSCommand: 'cmd+s',
                    handler: (state) {
                      _saveNote();
                      return KeyEventResult.handled;
                    },
                  ),
                  ...standardCommandShortcutEvents,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
