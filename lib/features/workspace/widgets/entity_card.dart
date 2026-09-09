import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:xorr/features/workspace/widgets/file_icon.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.isFile,
    required this.entityPath,
    required this.onTap,
    this.isExpanded = false,
    this.depth = 0,
    required this.isActive,
  });

  final bool isFile;
  final String entityPath;
  final VoidCallback onTap;
  final bool isExpanded;
  final int depth;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          padding: EdgeInsets.only(
            left: (depth * 16.0) + 5,
            top: 4,
            bottom: 4,
            right: 5,
          ),
          child: Row(
            children: [
              if (!isFile)
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right, size: 18),
                )
              else
                const SizedBox(width: 18),

              const SizedBox(width: 4),

              FileSystemIcon(
                isFolder: !isFile,
                extension: getFileExtension(entityPath),
                size: 20,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  getEntityName(entityPath),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getEntityName(String path) {
    return p.basename(path);
  }

  String getFileExtension(String path) {
    return p.extension(path).toLowerCase();
  }
}
