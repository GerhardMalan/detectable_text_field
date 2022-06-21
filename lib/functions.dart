import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'detector/detector.dart';

/// Check if the text has detection
bool isDetected(String value, RegExp detectionRegExp) {
  final detector = Detector(detectionRegExp: detectionRegExp);
  final result = detector.getDetections(value);
  return result.isNotEmpty;
}

/// Extract detections from the text
List<String> extractDetections(String value, RegExp detectionRegExp) {
  final decorator = Detector(detectionRegExp: detectionRegExp);
  final decorations = decorator.getDetections(value);
  final result = decorations.map((decoration) {
    final text = decoration.range.textInside(value);
    return text.trim();
  }).toList();
  return result;
}

/// Returns textSpan with detected text
///
/// Used in [DetectableText]
TextSpan getDetectedTextSpan({
  required TextStyle decoratedStyle,
  required TextStyle? Function(String) detectedStyleCallback,
  required TextStyle basicStyle,
  required String source,
  required RegExp detectionRegExp,
  bool alwaysDetectTap = false,
  Function(String)? onTap,
  bool decorateAtSign = false,
}) {
  final detections =
      Detector(detectionRegExp: detectionRegExp).getDetections(source);
  if (detections.isEmpty) {
    return TextSpan(text: source, style: basicStyle);
  } else {
    detections.sort();
    final span = detections
        .asMap()
        .map(
          (index, item) {
            final text = item.range.textInside(source);
            final style = detectedStyleCallback(text) ?? basicStyle;
            final recognizer = TapGestureRecognizer()
              ..onTap = () {
                if (style != basicStyle || alwaysDetectTap) {
                  onTap!(text.trim());
                }
              };
            return MapEntry(
              index,
              TextSpan(
                style: style,
                text: text,
                recognizer: (onTap == null) ? null : recognizer,
              ),
            );
          },
        )
        .values
        .toList();

    return TextSpan(children: span);
  }
}

TextSpan getDetectedTextSpanWithExtraChild(
    {required TextStyle decoratedStyle,
    required TextStyle? Function(String) detectedStyleCallback,
    required TextStyle basicStyle,
    required String source,
    required RegExp detectionRegExp,
    Function(String)? onTap,
    bool decorateAtSign = false,
    List<InlineSpan>? children}) {
  final detections =
      Detector(detectionRegExp: detectionRegExp).getDetections(source);
  if (detections.isEmpty) {
    // return TextSpan(text: source, style: basicStyle);
    return TextSpan(
      style: basicStyle,
      text: source,
      children: children,
    );
  } else {
    detections.sort();
    List<InlineSpan> span = detections
        .asMap()
        .map(
          (index, item) {
            final text = item.range.textInside(source);
            final style = detectedStyleCallback(text) ?? basicStyle;
            final recognizer = TapGestureRecognizer()
              ..onTap = () {
                if (style != basicStyle) {
                  onTap!(text.trim());
                }
              };
            return MapEntry(
              index,
              TextSpan(
                style: style,
                text: text,
                recognizer: (onTap == null) ? null : recognizer,
              ),
            );
          },
        )
        .values
        .toList();

    span.addAll(children!);

    return TextSpan(children: span);
  }
}
