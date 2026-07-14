import 'dart:convert';
import 'dart:io';

import 'package:exe101/core/constant/app_constant.dart';
import 'package:exe101/core/constant/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses PITCHED-BOOK for every build display name', () {
    expect(AppConstant.appName, 'PITCHED-BOOK');
    expect(AppStrings.appName, 'PITCHED-BOOK');

    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();
    final webManifest = jsonDecode(
      File('web/manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final webIndex = File('web/index.html').readAsStringSync();

    expect(androidManifest, contains('android:label="PITCHED-BOOK"'));
    expect(iosInfo, contains('<string>PITCHED-BOOK</string>'));
    expect(webManifest['name'], 'PITCHED-BOOK');
    expect(webManifest['short_name'], 'PITCHED-BOOK');
    expect(webIndex, contains('<title>PITCHED-BOOK</title>'));
  });
}
