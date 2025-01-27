import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';

/// Add composing to hashTag decorated text.
///
/// Expected to be used when Japanese letters are typed.
class Composer {
  Composer(
      {required this.sourceText,
      required this.detections,
      required this.composing,
      required this.selection,
      required this.basicStyle,
      required this.detectedStyleCallback,
      required this.onDetectableTypedText,
      required this.onDetectableTyped});

  final String sourceText;
  final List<Detection?> detections;
  final TextRange composing;
  final int selection;
  final TextStyle basicStyle;

  /// A callback function that returns a [TextStyle] for detected text, passing
  /// in the [DetectableText.text]. The [TextStyle] returned by the
  /// [detectedStyleCallback] has the highest priority in styling detected
  /// text, followed by [detectedStyle] and then [basicStyle] or the current
  /// theme's [TextTheme.subtitle1] with blue color.
  final TextStyleCallBack detectedStyleCallback;

  final ValueChanged<String>? onDetectableTypedText;

  final ValueChanged<Detection>? onDetectableTyped;

  // ignore: todo
  // TODO(Takahashi): Add test code for composing
  TextSpan getComposedTextSpan() {
    final span = detections.map(
      (item) {
        final spanRange = item!.range;
        final text = spanRange.textInside(sourceText);
        final spanStyle = detectedStyleCallback(text) ?? basicStyle;
        final underlinedStyle =
            spanStyle.copyWith(decoration: TextDecoration.underline);
        if (spanRange.start <= composing.start &&
            spanRange.end >= composing.end) {
          return TextSpan(
            children: [
              TextSpan(
                  text: TextRange(start: spanRange.start, end: composing.start)
                      .textInside(sourceText),
                  style: spanStyle),
              TextSpan(
                  text: TextRange(start: composing.start, end: composing.end)
                      .textInside(sourceText),
                  style: underlinedStyle),
              TextSpan(
                  text: TextRange(start: composing.end, end: spanRange.end)
                      .textInside(sourceText),
                  style: spanStyle),
            ],
          );
        } else if (spanRange.start >= composing.start &&
            spanRange.end >= composing.end &&
            spanRange.start <= composing.end) {
          return TextSpan(children: [
            TextSpan(
                text: TextRange(start: spanRange.start, end: composing.end)
                    .textInside(sourceText),
                style: underlinedStyle),
            TextSpan(
                text: TextRange(start: composing.end, end: spanRange.end)
                    .textInside(sourceText),
                style: spanStyle)
          ]);
        } else if (spanRange.start <= composing.start &&
            spanRange.end <= composing.end &&
            spanRange.end >= composing.start) {
          return TextSpan(
            children: [
              TextSpan(
                  text: TextRange(start: spanRange.start, end: composing.start)
                      .textInside(sourceText),
                  style: spanStyle),
              TextSpan(
                  text: TextRange(start: composing.start, end: spanRange.end)
                      .textInside(sourceText),
                  style: underlinedStyle),
            ],
          );
        } else {
          return TextSpan(
              text: spanRange.textInside(sourceText), style: spanStyle);
        }
      },
    ).toList();
    return TextSpan(children: span);
  }

  Detection? typingDetection() {
    final res = detections.where((detection) {
      final typingRange = detection!.range;
      return typingRange.start <= selection && typingRange.end >= selection;
    });
    if (res.isNotEmpty) {
      return res.first;
    } else {
      return null;
    }
  }

  void callOnDetectionTyped() {
    final detection = typingDetection();
    if (detection != null) {
      final typingRange = detection.range;
      if (onDetectableTypedText != null) {
        onDetectableTypedText!(typingRange.textInside(sourceText));
      }
      if (onDetectableTyped != null) {
        onDetectableTyped!(detection);
      }
    }
  }
}
