import 'package:flutter/material.dart';

/// 高亮文本组件 - 用于搜索关键词高亮
class HighlightText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final bool caseSensitive;
  final int? maxLines;
  final TextOverflow overflow;

  const HighlightText({
    Key? key,
    required this.text,
    required this.highlight,
    this.style,
    this.highlightStyle,
    this.caseSensitive = false,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final keywords = highlight
        .split(' ')
        .where((k) => k.isNotEmpty)
        .toList();

    if (keywords.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final textLower = caseSensitive ? text : text.toLowerCase();
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    // 找到所有需要高亮的位置
    final List<_Match> matches = [];
    for (final keyword in keywords) {
      final keywordLower = caseSensitive ? keyword : keyword.toLowerCase();
      int startIndex = 0;
      while (true) {
        final index = textLower.indexOf(keywordLower, startIndex);
        if (index == -1) break;
        matches.add(_Match(index, index + keyword.length, keyword));
        startIndex = index + 1;
      }
    }

    // 合并重叠的匹配
    matches.sort((a, b) => a.start.compareTo(b.start));
    final List<_Match> mergedMatches = [];
    for (final match in matches) {
      if (mergedMatches.isEmpty) {
        mergedMatches.add(match);
      } else {
        final last = mergedMatches.last;
        if (match.start <= last.end) {
          // 重叠，合并
          mergedMatches[mergedMatches.length - 1] = _Match(
            last.start,
            match.end > last.end ? match.end : last.end,
            last.keyword,
          );
        } else {
          mergedMatches.add(match);
        }
      }
    }

    // 构建TextSpan列表
    for (final match in mergedMatches) {
      // 添加高亮前的文本
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      // 添加高亮的文本
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle ??
            style?.copyWith(
              backgroundColor: Colors.yellow.withOpacity(0.3),
              fontWeight: FontWeight.bold,
            ),
      ));

      lastIndex = match.end;
    }

    // 添加剩余的文本
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class _Match {
  final int start;
  final int end;
  final String keyword;

  _Match(this.start, this.end, this.keyword);
}

