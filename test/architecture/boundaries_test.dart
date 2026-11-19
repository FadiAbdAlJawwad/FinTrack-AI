import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String packageName = 'fin_track_ai';

const List<String> legacyPaths = [
  'lib/features/*/domain/',
  'lib/features/*/data/',
  'lib/features/currency/data/services/exchange_rate_service.dart',
  'lib/core/services/gemini_service.dart',
  'lib/features/wallets/data/services/wallet_migration_service.dart',
];

bool isLegacyPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (normalized ==
          'lib/features/currency/data/services/exchange_rate_service.dart' ||
      normalized == 'lib/core/services/gemini_service.dart' ||
      normalized ==
          'lib/features/wallets/data/services/wallet_migration_service.dart') {
    return true;
  }
  if (RegExp(r'^lib/features/[^/]+/domain/').hasMatch(normalized)) {
    return true;
  }
  if (RegExp(r'^lib/features/[^/]+/data/').hasMatch(normalized)) {
    return true;
  }
  return false;
}

List<String> extractImportExportUris(String content) {
  final uris = <String>[];

  // Remove multi-line comments
  final noMultiLineComments = content.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

  // Filter single-line comments
  final cleanLines = <String>[];
  for (final line in noMultiLineComments.split('\n')) {
    final commentIdx = line.indexOf('//');
    if (commentIdx != -1) {
      cleanLines.add(line.substring(0, commentIdx));
    } else {
      cleanLines.add(line);
    }
  }

  final cleanContent = cleanLines.join('\n');

  // Match import or export statements up to semicolon
  final directiveRegex = RegExp(r'\b(import|export)\s+[^;]+;', multiLine: true);
  final matches = directiveRegex.allMatches(cleanContent);

  final stringLiteralRegex = RegExp(r"""['"]([^'"]+)['"]""");

  for (final match in matches) {
    final directiveText = match.group(0)!;
    for (final strMatch in stringLiteralRegex.allMatches(directiveText)) {
      uris.add(strMatch.group(1)!);
    }
  }

  return uris;
}

String resolveUri(String fromFile, String uri) {
  final normalizedUri = uri.replaceAll('\\', '/');
  final normalizedFromFile = fromFile.replaceAll('\\', '/');

  if (normalizedUri.startsWith('package:$packageName/')) {
    return 'lib/${normalizedUri.substring('package:$packageName/'.length)}';
  } else if (normalizedUri.startsWith('package:') ||
      normalizedUri.startsWith('dart:')) {
    return normalizedUri;
  }

  // Relative path resolution
  final parts = normalizedFromFile.split('/');
  parts.removeLast(); // Remove filename to get directory path

  for (final segment in normalizedUri.split('/')) {
    if (segment == '.' || segment.isEmpty) {
      continue;
    } else if (segment == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else {
      parts.add(segment);
    }
  }

  return parts.join('/');
}

String? getFeatureName(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (normalized.startsWith('lib/features/')) {
    final rel = normalized.substring('lib/features/'.length);
    final segments = rel.split('/');
    if (segments.isNotEmpty && segments[0].isNotEmpty) {
      return segments[0];
    }
  }
  return null;
}

void main() {
  group('Architecture Boundary Tests', () {
    late List<File> allDartFiles;
    late List<File> featuresFiles;
    late List<File> coreFiles;
    late List<File> domainFiles;
    late List<File> dataFiles;

    setUpAll(() {
      final libDir = Directory('lib');
      final allEntities = libDir.existsSync()
          ? libDir.listSync(recursive: true)
          : <FileSystemEntity>[];

      allDartFiles = allEntities.whereType<File>().where((file) {
        final path = file.path.replaceAll('\\', '/');
        return path.endsWith('.dart') &&
            !path.endsWith('.g.dart') &&
            !path.endsWith('.freezed.dart');
      }).toList();

      featuresFiles = allDartFiles
          .where(
            (f) => f.path.replaceAll('\\', '/').startsWith('lib/features/'),
          )
          .toList();
      coreFiles = allDartFiles
          .where((f) => f.path.replaceAll('\\', '/').startsWith('lib/core/'))
          .toList();
      domainFiles = allDartFiles
          .where((f) => f.path.replaceAll('\\', '/').startsWith('lib/domain/'))
          .toList();
      dataFiles = allDartFiles
          .where((f) => f.path.replaceAll('\\', '/').startsWith('lib/data/'))
          .toList();
    });

    test('1. Non-vacuous check: file counts', () {
      final domainDirExists = Directory('lib/domain').existsSync();
      final dataDirExists = Directory('lib/data').existsSync();

      // ignore: avoid_print
      print(
        'Scanned files: features=${featuresFiles.length}, core=${coreFiles.length}, domain=${domainFiles.length}, data=${dataFiles.length}',
      );

      expect(
        featuresFiles.length,
        greaterThanOrEqualTo(50),
        reason: 'Expected lib/features to have >= 50 files',
      );
      expect(
        coreFiles.length,
        greaterThanOrEqualTo(10),
        reason: 'Expected lib/core to have >= 10 files',
      );
      expect(
        domainFiles.length,
        greaterThanOrEqualTo(1),
        reason: 'Expected lib/domain to have >= 1 files',
      );
      expect(
        domainDirExists,
        isTrue,
        reason: 'lib/domain directory must exist',
      );
      expect(dataDirExists, isTrue, reason: 'lib/data directory must exist');
    });

    test('2. Domain layer boundaries: no forbidden packages in lib/domain', () {
      final forbiddenPrefixes = [
        'package:flutter/',
        'package:firebase_',
        'package:cloud_firestore',
        'package:http/',
        'package:drift/',
      ];

      final violations = <String>[];

      for (final file in domainFiles) {
        final fromFile = file.path.replaceAll('\\', '/');
        final content = file.readAsStringSync();
        final uris = extractImportExportUris(content);

        for (final uri in uris) {
          final resolved = resolveUri(fromFile, uri);
          for (final forbidden in forbiddenPrefixes) {
            if (resolved.startsWith(forbidden)) {
              violations.add(
                '$fromFile imports forbidden dependency: $resolved',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Domain layer files must not import forbidden packages:\n${violations.join('\n')}',
      );
    });

    test('3. Data layer boundaries: no lib/data file imports lib/features/', () {
      final violations = <String>[];

      for (final file in dataFiles) {
        final fromFile = file.path.replaceAll('\\', '/');
        final content = file.readAsStringSync();
        final uris = extractImportExportUris(content);

        for (final uri in uris) {
          final resolved = resolveUri(fromFile, uri);
          if (resolved.startsWith('lib/features/')) {
            violations.add('$fromFile imports feature layer: $resolved');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Data layer files must not import feature layer:\n${violations.join('\n')}',
      );
    });

    test('4. Cross-feature import boundaries and baseline check', () {
      final baselineFile = File('test/architecture/cross_feature_baseline.txt');
      final baselineLines = baselineFile.existsSync()
          ? baselineFile
                .readAsLinesSync()
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty)
                .toSet()
          : <String>{};

      final matchedBaseline = <String>{};
      final newViolations = <String>[];

      for (final file in featuresFiles) {
        final fromFile = file.path.replaceAll('\\', '/');
        final fromFeature = getFeatureName(fromFile);
        if (fromFeature == null) continue;

        final content = file.readAsStringSync();
        final uris = extractImportExportUris(content);

        for (final uri in uris) {
          final resolved = resolveUri(fromFile, uri);
          final toFeature = getFeatureName(resolved);
          if (toFeature != null && fromFeature != toFeature) {
            final violationLine = '$fromFile -> $resolved';
            if (baselineLines.contains(violationLine)) {
              matchedBaseline.add(violationLine);
            } else {
              newViolations.add(violationLine);
            }
          }
        }
      }

      final staleBaseline = baselineLines.difference(matchedBaseline);

      final errors = <String>[];
      if (newViolations.isNotEmpty) {
        newViolations.sort();
        errors.add(
          'New cross-feature import violations found:\n${newViolations.join('\n')}',
        );
      }
      if (staleBaseline.isNotEmpty) {
        final sortedStale = staleBaseline.toList()..sort();
        errors.add(
          'Stale baseline entries found (no matching import):\n${sortedStale.join('\n')}',
        );
      }

      expect(errors, isEmpty, reason: errors.join('\n\n'));
    });

    test('5. Legacy path boundaries: no lib/domain, lib/data, lib/core imports legacy paths', () {
      final targetFiles = [...domainFiles, ...dataFiles, ...coreFiles];
      final violations = <String>[];

      for (final file in targetFiles) {
        final fromFile = file.path.replaceAll('\\', '/');
        final content = file.readAsStringSync();
        final uris = extractImportExportUris(content);

        for (final uri in uris) {
          final resolved = resolveUri(fromFile, uri);
          if (isLegacyPath(resolved)) {
            violations.add('$fromFile imports legacy path: $resolved');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'lib/domain, lib/data, and lib/core must not import legacy paths:\n${violations.join('\n')}',
      );
    });
  });
}
