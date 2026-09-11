import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class NumberedBlockWrapper extends BlockComponentBuilder {
  final BlockComponentBuilder builder;
  final EditorState editorState;

  NumberedBlockWrapper({required this.builder, required this.editorState});

  @override
  BlockComponentWidget build(BlockComponentContext blockContext) {
    final childWidget = builder.build(blockContext);

    final isRootBlock = blockContext.node.parent == editorState.document.root;
    if (!isRootBlock) {
      return childWidget;
    }

    final index =
        editorState.document.root.children.indexOf(blockContext.node) + 1;

    final configuration =
        (builder as dynamic).configuration ??
        const BlockComponentConfiguration();

    return NumberedBlockWidget(
      node: blockContext.node,
      configuration: configuration,
      index: index > 0 ? index : 1,
      child: childWidget,
    );
  }

  @override
  bool Function(Node) get validate => builder.validate;
}

class NumberedBlockWidget extends BlockComponentStatelessWidget {
  final Widget child;
  final int index;

  const NumberedBlockWidget({
    super.key,
    required super.node,
    required super.configuration,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 46,
          child: Padding(
            padding: const EdgeInsets.only(top: 3.0, right: 8.0),
            child: Text(
              '$index',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.6),
                fontSize: 17,
                height: 1.3,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
