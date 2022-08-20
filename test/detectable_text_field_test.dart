import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const urlRegex =
      '((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)';
  test(
    'url detection test',
    () {
      final regex = RegExp(
        urlRegex,
        caseSensitive: false,
        dotAll: true,
      );
      const source = 'http://foo.com/blah_blah';
      final matches = extractDetections(source, regex);
      if (kDebugMode) {
        print(matches);
      }
      expect(regex.hasMatch(source), true);
    },
  );
  test(
    'url detection test with hashTags',
    () {
      final regex = RegExp(
        '(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegex',
      );
      const source =
          'Stop dhttp://foo.com/blah_blah oio#firebase notDetectThis @hello noDetection';
      final matches = extractDetections(source, regex);
      if (kDebugMode) {
        print(matches);
      }
      expect(regex.hasMatch(source), true);
    },
  );
  test(
    'detectionRegExp must return proper regExp',
    () {
      expect(detectionRegExp(), hashTagAtSignUrlRegExp);
      expect(detectionRegExp(hashTag: false), atSignUrlRegExp);
      expect(detectionRegExp(hashTag: false, atSign: false), urlRegex);
      expect(detectionRegExp(atSign: false), hashTagUrlRegExp);
      expect(detectionRegExp(atSign: false, url: false), hashTagRegExp);
      expect(detectionRegExp(url: false), hashTagAtSignRegExp);
    },
  );
}
