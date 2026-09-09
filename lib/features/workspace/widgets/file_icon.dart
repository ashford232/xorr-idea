import 'package:flutter/material.dart';

class FileSystemIcon extends StatelessWidget {
  final String extension;
  final bool isFolder;
  final double size;

  const FileSystemIcon({
    super.key,
    this.extension = '',
    this.isFolder = false,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: isFolder
          ? FolderIconPainter(color: _FileSystemHelper.getColor(extension))
          : FileIconPainter(
              extension: extension,
              baseColor: _FileSystemHelper.getColor(extension),
              label: _FileSystemHelper.getLabel(extension),
            ),
    );
  }
}
class FileIconPainter extends CustomPainter {
  final String extension;
  final Color baseColor;
  final String label;

  FileIconPainter({
    required this.extension,
    required this.baseColor,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    path.moveTo(w * 0.15, h * 0.05);
    path.lineTo(w * 0.60, h * 0.05);
    path.lineTo(w * 0.85, h * 0.30);
    path.lineTo(w * 0.85, h * 0.95);
    path.lineTo(w * 0.15, h * 0.95);
    path.close();

    canvas.drawShadow(path, Colors.black, 1.5, false);

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor.withValues(alpha: 0.7), baseColor],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, paint);

    final foldPath = Path();
    foldPath.moveTo(w * 0.60, h * 0.05);
    foldPath.lineTo(w * 0.60, h * 0.30);
    foldPath.lineTo(w * 0.85, h * 0.30);
    foldPath.close();

    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawPath(foldPath, paint);

    final foldShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawPath(foldPath, foldShadow);

    if (label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: w * 0.28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: w * 0.7);
      textPainter.paint(canvas, Offset((w - textPainter.width) / 2, h * 0.50));
    }
  }

  @override
  bool shouldRepaint(covariant FileIconPainter oldDelegate) =>
      oldDelegate.extension != extension || oldDelegate.baseColor != baseColor;
}

class FolderIconPainter extends CustomPainter {
  final Color color;

  FolderIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final folderColor = color == Colors.grey ? Colors.amber : color;
    final paint = Paint()..style = PaintingStyle.fill;

    final backPath = Path();
    backPath.moveTo(w * 0.05, h * 0.15);
    backPath.lineTo(w * 0.35, h * 0.15);
    backPath.lineTo(w * 0.45, h * 0.30);
    backPath.lineTo(w * 0.95, h * 0.30);
    backPath.lineTo(w * 0.95, h * 0.90);
    backPath.lineTo(w * 0.05, h * 0.90);
    backPath.close();

    canvas.drawShadow(backPath, Colors.black, 1.5, false);

    paint.color = folderColor.withValues(alpha: 0.8);
    canvas.drawPath(backPath, paint);

    final frontPath = Path();
    frontPath.moveTo(w * 0.05, h * 0.90);
    frontPath.lineTo(w * 0.15, h * 0.40);
    frontPath.lineTo(w * 0.95, h * 0.40);
    frontPath.lineTo(w * 0.85, h * 0.90);
    frontPath.close();

    canvas.drawShadow(frontPath, Colors.black, 4.0, false);

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [folderColor, folderColor.withValues(alpha: 0.9)],
    ).createShader(Rect.fromLTWH(0, h * 0.4, w, h * 0.5));

    canvas.drawPath(frontPath, paint);
  }

  @override
  bool shouldRepaint(covariant FolderIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FileSystemHelper {
  static Color getColor(String extension) {
    switch (extension.toLowerCase()) {
      // ADDED .XORR SUPPORT
      case '.xorr':
        return Colors.deepPurple;
        
      // Core Web & Mobile
      case '.dart': return Colors.blue;
      case '.html': case '.htm': return Colors.deepOrange;
      case '.css': case '.scss': case '.sass': case '.less': return Colors.blueAccent;
      case '.js': return Colors.amber;
      case '.ts': return Colors.blue.shade700;
      case '.jsx': return Colors.lightBlueAccent;
      case '.tsx': return Colors.blueAccent.shade700;
      case '.vue': return Colors.green.shade600;
      case '.svelte': return Colors.orange.shade700;

      // Programming Languages
      case '.go': return Colors.cyan;
      case '.py': case '.pyc': return Colors.blueGrey;
      case '.java': case '.jar': case '.class': return Colors.orangeAccent.shade700;
      case '.c': case '.h': return Colors.blue.shade800;
      case '.cpp': case '.hpp': case '.cc': return Colors.blue.shade900;
      case '.cs': return Colors.purple;
      case '.php': return Colors.indigo.shade400;
      case '.rb': return Colors.red.shade600;
      case '.swift': return Colors.deepOrangeAccent;
      case '.kt': case '.kts': return Colors.deepPurpleAccent;
      case '.rs': return Colors.brown.shade600;
      case '.m': case '.mm': return Colors.blueGrey.shade600;

      // Scripts & Shell
      case '.sh': case '.bash': case '.zsh': case '.bat': case '.cmd': case '.ps1': return Colors.green.shade800;

      // Data, Config & Markup
      case '.json': return Colors.orange;
      case '.xml': return Colors.orange.shade700;
      case '.yaml': case '.yml': case '.toml': case '.ini': case '.env': case '.conf': return Colors.teal;
      case '.csv': case '.tsv': return Colors.green.shade600;
      case '.sql': case '.db': case '.sqlite': return Colors.blueGrey.shade700;
      case '.graphql': case '.gql': return Colors.pink.shade400;

      // Documents & Text
      case '.md': case '.mdx': return Colors.purple.shade400;
      case '.txt': return Colors.grey.shade700;
      case '.rtf': return Colors.brown.shade400;
      case '.doc': case '.docx': return Colors.blue.shade600;
      case '.pdf': return Colors.red.shade700;
      case '.log': return Colors.grey.shade500;
      case '.tex': return Colors.teal.shade800;

      default: return Colors.grey;
    }
  }

  static String getLabel(String extension) {
    switch (extension.toLowerCase()) {
      // ADDED .XORR SUPPORT
      case '.xorr': return 'XORR';
      
      // Core Web & Mobile
      case '.dart': return 'D';
      case '.html': case '.htm': return '<>';
      case '.css': case '.scss': case '.sass': case '.less': return '#';
      case '.js': return 'JS';
      case '.ts': return 'TS';
      case '.jsx': return 'JSX';
      case '.tsx': return 'TSX';
      case '.vue': return 'VUE';
      case '.svelte': return 'SVE';

      // Programming Languages
      case '.go': return 'GO';
      case '.py': case '.pyc': return 'PY';
      case '.java': case '.jar': case '.class': return 'JAVA';
      case '.c': case '.h': return 'C';
      case '.cpp': case '.hpp': case '.cc': return 'C++';
      case '.cs': return 'C#';
      case '.php': return 'PHP';
      case '.rb': return 'RB';
      case '.swift': return 'SWIFT';
      case '.kt': case '.kts': return 'KT';
      case '.rs': return 'RS';

      // Scripts & Shell
      case '.sh': case '.bash': case '.zsh': return 'SH';
      case '.bat': case '.cmd': return 'BAT';
      case '.ps1': return 'PS';

      // Data, Config & Markup
      case '.json': return '{}';
      case '.xml': return '</>';
      case '.yaml': case '.yml': return 'YML';
      case '.toml': case '.ini': case '.env': case '.conf': return 'CFG';
      case '.csv': return 'CSV';
      case '.tsv': return 'TSV';
      case '.sql': case '.db': case '.sqlite': return 'SQL';
      case '.graphql': case '.gql': return 'GQL';

      // Documents & Text
      case '.md': case '.mdx': return 'M↓';
      case '.txt': return 'TXT';
      case '.rtf': return 'RTF';
      case '.doc': case '.docx': return 'DOC';
      case '.pdf': return 'PDF';
      case '.log': return 'LOG';
      case '.tex': return 'TEX';

      default:
        final cleanExt = extension.replaceAll('.', '').toUpperCase();
        return cleanExt.length > 3 ? cleanExt.substring(0, 3) : cleanExt;
    }
  }
}