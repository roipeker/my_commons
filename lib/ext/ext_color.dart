import 'dart:ui';

extension ColorStringExt on String {

  /// Try to parse this string as #hex.
  /// fallbacks to transparent color
  Color get color {
    var c = trimLeft();
    if (c.startsWith('#')) {
      c = c.replaceFirst('#', '0x');
    }
    var value = int.tryParse(c);
    return (value ?? 0x0).color;
  }
}

extension ColorIntExt on int {
  /// Take int as hex, add 24bits full alpha if missing.
  Color get color {
    var c = this;
    var alpha = (0xff000000 & c) >> 24;
    if (alpha == 0) {
      c |= (0xff & 0xff) << 24 & 0xFFFFFFFF;
    }
    return Color(c);
  }
}
