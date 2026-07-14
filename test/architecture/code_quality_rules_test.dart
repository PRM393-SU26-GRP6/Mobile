import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libDirectory = Directory('lib');

  test('source files respect the AGENTS.md hard line limits', () {
    final violations = <String>[];

    for (final file in _dartFiles(libDirectory)) {
      final path = _normalizedPath(file.path);
      final limit = _lineLimitFor(path);
      if (limit == null) continue;

      final lineCount = file.readAsLinesSync().length;
      if (lineCount > limit) {
        violations.add('$path has $lineCount lines (limit: $limit)');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('views do not depend directly on the remote data layer', () {
    final violations = <String>[];

    for (final file in _viewFiles(libDirectory)) {
      final source = file.readAsStringSync();
      if (source.contains("package:exe101/data/remote/") ||
          source.contains('ApiServiceImpl')) {
        violations.add(_normalizedPath(file.path));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('views do not register GetX dependencies', () {
    final violations = <String>[];

    for (final file in _viewFiles(libDirectory)) {
      if (file.readAsStringSync().contains('Get.put<') ||
          file.readAsStringSync().contains('Get.put(')) {
        violations.add(_normalizedPath(file.path));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation does not use hard-coded named routes', () {
    final violations = <String>[];
    final hardCodedRoute = RegExp(
      r'''Get\.(?:toNamed|offNamed|offAllNamed)\(\s*['"]\/''',
    );

    for (final file in _dartFiles(Directory('lib/presentation'))) {
      if (hardCodedRoute.hasMatch(file.readAsStringSync())) {
        violations.add(_normalizedPath(file.path));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('production networking does not log bodies, headers, or secrets', () {
    final violations = <String>[];

    for (final file in _dartFiles(libDirectory)) {
      final path = _normalizedPath(file.path);
      final source = file.readAsStringSync();
      final unsafeLogInterceptor = source.contains('requestBody: true') ||
          source.contains('responseBody: true') ||
          source.contains('requestHeader: true') ||
          source.contains('responseHeader: true');
      final rawSensitiveLog = RegExp(
        r'debugPrint\([^\n]*(?:header|token|password|otp|response\.data)',
        caseSensitive: false,
      ).hasMatch(source);

      if (unsafeLogInterceptor || rawSensitiveLog) {
        violations.add(path);
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('controllers do not import the application entrypoint', () {
    final violations = <String>[];

    for (final file in _dartFiles(Directory('lib/presentation'))) {
      final path = _normalizedPath(file.path);
      if (path.contains('/controller/') &&
          file.readAsStringSync().contains("package:exe101/main.dart")) {
        violations.add(path);
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('views do not resolve repositories directly', () {
    final violations = <String>[];

    for (final file in _viewFiles(libDirectory)) {
      final source = file.readAsStringSync();
      if (source.contains('package:exe101/domain/repositories/') ||
          RegExp(r'Get\.find<[^>]*Repository>').hasMatch(source)) {
        violations.add(_normalizedPath(file.path));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation text does not use font sizes below 12sp', () {
    final violations = <String>[];
    final tooSmall = RegExp(r'fontSize:\s*(?:[0-9]|1[01])(?:\.0)?\b');

    for (final file in _dartFiles(Directory('lib/presentation'))) {
      if (tooSmall.hasMatch(file.readAsStringSync())) {
        violations.add(_normalizedPath(file.path));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('empty catch blocks are not silently ignored', () {
    final violations = <String>[];
    final emptyCatch = RegExp(r'catch\s*\([^)]*\)\s*\{\s*\}');

    for (final file in _dartFiles(libDirectory)) {
      if (emptyCatch.hasMatch(file.readAsStringSync())) {
        violations.add(_normalizedPath(file.path));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('shared UI configuration is centralized', () {
    expect(File('lib/core/constant/app_strings.dart').existsSync(), isTrue);
    expect(File('lib/core/theme/app_dimensions.dart').existsSync(), isTrue);

    final duplicatedMapConfig = <String>[];
    for (final file in _dartFiles(Directory('lib/presentation'))) {
      if (file.readAsStringSync().contains('https://tile.openstreetmap.org')) {
        duplicatedMapConfig.add(_normalizedPath(file.path));
      }
    }
    expect(
      duplicatedMapConfig,
      isEmpty,
      reason: duplicatedMapConfig.join('\n'),
    );
  });
}

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

Iterable<File> _viewFiles(Directory directory) => _dartFiles(directory).where(
      (file) => _normalizedPath(file.path).contains('/view/'),
    );

String _normalizedPath(String path) => path.replaceAll('\\', '/');

int? _lineLimitFor(String path) {
  final fileName = path.split('/').last;

  if (path.contains('/data/remote/')) return 250;
  if (path.contains('/domain/models/')) return 250;
  if (path.contains('/controller/')) return 200;
  if (fileName.contains('dialog') || fileName.contains('sheet')) return 120;
  if (path.contains('/widgets/')) return 180;
  if (fileName.endsWith('_page.dart') || fileName.endsWith('_view.dart')) {
    return 300;
  }
  return null;
}
