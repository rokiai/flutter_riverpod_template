import 'dart:io';

const _maxEffectiveLines = 500;

final _generatedName = RegExp(
  r'(?:\.g|\.freezed)\.(dart|kt|swift)$|'
  r'^app_localizations(?:_.*)?\.dart$',
);

final _dartDirective = RegExp(r'^(library|import|export|part)\b');
final _kotlinDirective = RegExp(r'^(package|import)\b');
final _swiftDirective = RegExp(r'^import\b');

final _previewAnnotation = RegExp(r'^@(?:App)?Preview\b');
final _previewFunctionDecl = RegExp(
  r'^(?:static\s+)?(?:WidgetBuilder|Widget)\s+preview\w*\s*\(',
);
final _previewValueDecl = RegExp(
  r'^(?:static\s+)?(?:late\s+)?(?:final|const|var)\s+'
  r'(?:[\w?.<>,\[\]\s]+\s+)preview\w*\s*[;=<(]',
);
final _previewValueDeclNoType = RegExp(
  r'^(?:static\s+)?(?:late\s+)?(?:final|const|var)\s+'
  r'preview\w*\s*[;=<(]',
);

void main() {
  final roots = <Directory>[
    Directory('lib'),
    Directory('test'),
    Directory('pigeons'),
    Directory('ios/Runner'),
    Directory('android/app/src/main'),
  ];
  final violations = <_FileReport>[];
  for (final root in roots) {
    if (!root.existsSync()) {
      continue;
    }
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File) {
        continue;
      }
      final path = entity.path.replaceAll(r'\', '/');
      if (!_isHandwrittenSource(path)) {
        continue;
      }
      final report = _FileReport(
        path: path,
        effectiveLines: _countEffectiveLines(entity.readAsStringSync(), path),
      );
      if (report.effectiveLines > _maxEffectiveLines) {
        violations.add(report);
      }
    }
  }

  violations.sort((a, b) => b.effectiveLines.compareTo(a.effectiveLines));
  if (violations.isEmpty) {
    stdout.writeln(
      'Source size OK: handwritten files are within '
      '$_maxEffectiveLines effective lines.',
    );
    return;
  }

  stderr.writeln(
    'Source size check failed. Effective lines exclude import/export/part/'
    'package directives, comments, blank lines, generated files, and '
    'Widget Preview. Limit is $_maxEffectiveLines.',
  );
  for (final violation in violations) {
    stderr.writeln(
      '  ${violation.path}: ${violation.effectiveLines} effective lines',
    );
  }
  stderr.writeln(
    'Split by the Feature-First whitelist. Do not delete comments or create '
    '*_manager/*_helper/*_logic files to pass this check.',
  );
  exitCode = 1;
}

bool _isHandwrittenSource(String path) {
  final name = path.split('/').last;
  if (_generatedName.hasMatch(name)) {
    return false;
  }
  // Preview 基建整文件不计：app_preview.dart、foo_preview.dart。
  if (name == 'app_preview.dart' || name.endsWith('_preview.dart')) {
    return false;
  }
  return name.endsWith('.dart') ||
      name.endsWith('.kt') ||
      name.endsWith('.swift');
}

int _countEffectiveLines(String source, String path) {
  final isDart = path.endsWith('.dart');
  final isKotlin = path.endsWith('.kt');
  final isSwift = path.endsWith('.swift');

  var inBlockComment = false;
  var inDirective = false;
  var skipPreviewDepth = 0;
  var skipPreviewToSemicolon = false;
  var count = 0;

  for (final rawLine in source.split('\n')) {
    var line = rawLine;
    final stripped = _stripBlockComments(line, inBlockComment);
    inBlockComment = stripped.inBlockComment;
    line = stripped.text.trim();
    if (line.isEmpty) {
      continue;
    }
    if (line.startsWith('//')) {
      continue;
    }

    if (inDirective) {
      if (line.contains(';')) {
        inDirective = false;
      }
      continue;
    }

    final isDirective =
        (isDart && _dartDirective.hasMatch(line)) ||
        (isKotlin && _kotlinDirective.hasMatch(line)) ||
        (isSwift && _swiftDirective.hasMatch(line));
    if (isDirective) {
      inDirective = isDart && !line.contains(';');
      continue;
    }

    if (isDart) {
      if (skipPreviewDepth > 0 || skipPreviewToSemicolon) {
        skipPreviewDepth += _nestingDelta(line);
        if (skipPreviewDepth < 0) {
          skipPreviewDepth = 0;
        }
        if (skipPreviewDepth == 0 &&
            (!skipPreviewToSemicolon || line.contains(';'))) {
          skipPreviewToSemicolon = false;
        }
        continue;
      }
      if (_previewAnnotation.hasMatch(line)) {
        skipPreviewDepth += _nestingDelta(line);
        if (skipPreviewDepth < 0) {
          skipPreviewDepth = 0;
        }
        continue;
      }
      if (_isPreviewDeclaration(line)) {
        skipPreviewDepth += _nestingDelta(line);
        if (skipPreviewDepth < 0) {
          skipPreviewDepth = 0;
        }
        skipPreviewToSemicolon = skipPreviewDepth == 0 && !line.contains(';');
        continue;
      }
    }

    count += 1;
  }

  return count;
}

bool _isPreviewDeclaration(String line) {
  return _previewFunctionDecl.hasMatch(line) ||
      _previewValueDeclNoType.hasMatch(line) ||
      _previewValueDecl.hasMatch(line);
}

int _nestingDelta(String line) {
  var delta = 0;
  var index = 0;
  while (index < line.length) {
    final char = line[index];
    if (char == "'" || char == '"') {
      index = _skipQuoted(line, index);
      continue;
    }
    if (char == '(' || char == '{' || char == '[') {
      delta += 1;
    } else if (char == ')' || char == '}' || char == ']') {
      delta -= 1;
    }
    index += 1;
  }
  return delta;
}

int _skipQuoted(String line, int start) {
  final quote = line[start];
  var index = start + 1;
  while (index < line.length) {
    final char = line[index];
    if (char == '\\') {
      index += 2;
      continue;
    }
    if (char == quote) {
      return index + 1;
    }
    index += 1;
  }
  return line.length;
}

({String text, bool inBlockComment}) _stripBlockComments(
  String line,
  bool inBlockComment,
) {
  final buffer = StringBuffer();
  var index = 0;
  var inBlock = inBlockComment;

  while (index < line.length) {
    if (inBlock) {
      final end = line.indexOf('*/', index);
      if (end == -1) {
        return (text: buffer.toString(), inBlockComment: true);
      }
      inBlock = false;
      index = end + 2;
      continue;
    }

    if (index + 1 < line.length &&
        line[index] == '/' &&
        line[index + 1] == '*') {
      inBlock = true;
      index += 2;
      continue;
    }

    buffer.write(line[index]);
    index += 1;
  }

  return (text: buffer.toString(), inBlockComment: inBlock);
}

final class _FileReport {
  const _FileReport({required this.path, required this.effectiveLines});

  final String path;
  final int effectiveLines;
}
