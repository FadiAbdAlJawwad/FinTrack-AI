import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Code Hygiene Tests', () {
    late List<File> dartFiles;

    setUpAll(() {
      final libDir = Directory('lib');
      final allEntities = libDir.listSync(recursive: true);

      dartFiles = allEntities.whereType<File>().where((file) {
        final path = file.path.replaceAll('\\', '/');
        return path.endsWith('.dart') &&
            !path.endsWith('.g.dart') &&
            !path.endsWith('.freezed.dart') &&
            !path.contains('lib/l10n/');
      }).toList();
    });

    test('1. No scanned file contains "package:fin_track_ai/"', () {
      final offendingFiles = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (content.contains('package:fin_track_ai/')) {
          offendingFiles.add(file.path.replaceAll('\\', '/'));
        }
      }

      expect(
        offendingFiles,
        isEmpty,
        reason:
            'The following files contain package:fin_track_ai/ imports:\n'
            '${offendingFiles.join('\n')}',
      );
    });

    test('2. Colors.white appears in NO scanned file except lib/core/constant/color_manager.dart', () {
      final offendingFiles = <String>[];

      for (final file in dartFiles) {
        final normalizedPath = file.path.replaceAll('\\', '/');
        if (normalizedPath == 'lib/core/constant/color_manager.dart') {
          continue;
        }

        final content = file.readAsStringSync();
        if (content.contains('Colors.white')) {
          offendingFiles.add(normalizedPath);
        }
      }

      expect(
        offendingFiles,
        isEmpty,
        reason:
            'The following files contain Colors.white instead of ColorManager.white:\n'
            '${offendingFiles.join('\n')}',
      );
    });

    test('3. Sanity: the scan finds more than 50 .dart files', () {
      expect(
        dartFiles.length,
        greaterThan(50),
        reason:
            'Expected to scan more than 50 .dart files in lib, but found ${dartFiles.length}. Check directory root.',
      );
    });
  });
}
