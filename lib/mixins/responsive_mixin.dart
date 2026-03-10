import 'package:flutter/widgets.dart';

/// Responsive helpers based on Figma base frame (390 × 844).
///
/// Usage: add `with ResponsiveMixin` to any `State<T>` class,
/// then call `rw()`, `rh()`, and `rfs()` instead of the private
/// `_w`, `_h`, `_fs` (or `_getResponsiveWidth`, etc.) helpers.
mixin ResponsiveMixin<T extends StatefulWidget> on State<T> {
  /// Scale a width value from the 390-wide design to the device.
  double rw(double v) => (v / 390) * MediaQuery.of(context).size.width;

  /// Scale a height value from the 844-tall design to the device.
  double rh(double v) => (v / 844) * MediaQuery.of(context).size.height;

  /// Scale a font-size value (width-based, same as `rw`).
  double rfs(double v) => (v / 390) * MediaQuery.of(context).size.width;
}
