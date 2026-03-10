import 'package:flutter/material.dart';

/// A simple horizontal separator line, matching Figma dividers.
class SeparatorLine extends StatelessWidget {
  final double? width;
  final double height;
  final Color color;
  final EdgeInsetsGeometry margin;

  const SeparatorLine({
    super.key,
    this.width,
    this.height = 1,
    this.color = const Color(0xFFD8D8D8),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      color: color,
    );
  }
}
