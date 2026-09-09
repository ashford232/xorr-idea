import 'package:flutter/material.dart';
import 'package:xorr/features/workspace/widgets/file_icon.dart';

class ActionBtn extends StatelessWidget {
  const ActionBtn({
    super.key,
    required this.name,
    required this.icon,
    this.onPressed,
    this.onTapDown,
  });

  final String name;
  final IconData icon;
  final VoidCallback? onPressed;
  final void Function(TapDownDetails)? onTapDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: onTapDown,
          borderRadius: .circular(5),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  //
}

enum XorrDocumentType {
  doc(".xorr", name: "Document"),
  md(".md", name: "Markdown"),
  txt(".txt", name: 'Text'),
  html(".html", name: "HTML");

  final String extension;
  final String name;

  const XorrDocumentType(this.extension, {required this.name});
  Widget get icon => FileSystemIcon(extension: extension, size: 24);
}

enum XorrDocAction {
  open(Icon(Icons.folder_open, size: 18), "Open"),
  rename(Icon(Icons.edit, size: 18), "Rename"),
  delete(Icon(Icons.delete, size: 18), "Delete"),
  properties(Icon(Icons.info_outline, size: 18), "Properties");

  final Icon icon;
  final String label;

  const XorrDocAction(this.icon, this.label);
}
