import 'dart:math';

class MathUtils {
  /// normalizes the value.
  static double norm(double value, double min, double max) =>
      (value - min) / (max - min);

  /// Linear interpolation, same as `lerpDouble`
  /// no restrictions on `t` for range 0-1.
  static double lerp(
    double min,
    double max,
    double t,
  ) =>
      min + (max - min) * t;

  /// Like dart num::clamp() but adjusts min/max.
  static double clamp(double value, double min, double max) {
    if (min > max) {
      var tmp = max;
      max = min;
      min = tmp;
    }
    if (value < min) {
      return min;
    } else if (value > max) {
      return max;
    } else {
      return value;
    }
  }

  /// maps `srcValue` from `srcMin` and `srcMax` range ... to `dstMin` / `dstMax`
  /// range... optionally clamping the the output value when `clampDst` is true.
  static double map(
    double srcValue,
    double srcMin,
    double srcMax,
    double dstMin,
    double dstMax, [
    bool clampDst = false,
  ]) {
    final result = lerp(
      dstMin,
      dstMax,
      norm(srcValue, srcMin, srcMax),
    );
    if (clampDst) {
      return clamp(result, dstMin, dstMax);
    }
    return result;
  }

  /// Gives back the absolute difference of 2 numbers (no negative)
  static num difference(num a, num b) => (a - b).abs();

  /// Wraps value between min and max.
  static double wrap(double value, double min, double max) {
    assert(min < max, '`min` value has to be smaller than `max`');
    final range = max - min;
    return min + ((((value - min) % range) + range) % range);
  }

  static double roundTo(double value, num decimal) {
    final multiplier = pow(10, decimal);
    return (value * multiplier).roundToDouble() / multiplier;
  }

  static double roundToNearest(double value, num multiplier) {
    return (value / multiplier).roundToDouble() / multiplier;
  }

  static double sinRange(double angleRadians, double min, double max) {
    return map(sin(angleRadians), -1, 1, min, max);
  }

  static double cosRange(double angleRadians, double min, double max) {
    return map(cos(angleRadians), -1, 1, min, max);
  }

  static double lerpSin(double value, double max, double min) {
    return sinRange(value * pi * 2, min, max);
  }

  /// Delta defines a min threshold difference to take `a` and `b` as the
  /// same value, is like rounding, without decimals.
  static bool equalish(double a, double b, double delta) {
    return difference(a, b) < delta;
  }

  static double dotProduct(
    double x0,
    double y0,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    return (x1 - x0) * (x3 - x2) + (y1 - y0) * (y3 - y2);
  }

  static double angleBetween(
    double x0,
    double y0,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    final dp = dotProduct(x0, y0, x1, y1, x2, y2, x3, y3);
    final mag0 = dist(x0, y0, x1, y1);
    final mag1 = dist(x2, y2, x3, y3);
    return acos(dp / mag0 / mag1);
  }

  /// distance between 2 points.
  static double dist(double x0, double y0, double x1, double y1) {
    final dx = x1 - x0;
    final dy = y1 - y0;
    return sqrt(dx * dx + dy * dy);
  }

  static polarToPoint(double angle, double radius) {
    return Point(
      cos(angle) * radius,
      sin(angle) * radius,
    );
  }

  static double magnitude(Point<double> p) => dist(0, 0, p.x, p.y);

  static Point<double> lerpPoint(
    Point<double> p0,
    Point<double> p1,
    double t,
  ) {
    return Point(
      lerp(p0.x, p1.x, t),
      lerp(p0.y, p1.y, t),
    );
  }

  static bezier(
    Point<double> p0,
    Point<double> p1,
    Point<double> p2,
    Point<double> p3,
    double t,
  ) {
    final oneMinusT = 1 - t;
    final m0 = oneMinusT * oneMinusT * oneMinusT;
    final m1 = 3 * oneMinusT * oneMinusT * t;
    final m2 = 3 * oneMinusT * t * t;
    final m3 = t * t * t;
    return Point(
      m0 * p0.x + m1 * p1.x + m2 * p2.x + m3 * p3.x,
      m0 * p0.y + m1 * p1.y + m2 * p2.y + m3 * p3.y,
    );
  }

  static Point quadratic(
    Point<double> p0,
    Point<double> p1,
    Point<double> p2,
    double t,
  ) {
    final oneMinusT = 1 - t;
    final m0 = oneMinusT * oneMinusT;
    final m1 = 2 * oneMinusT * t;
    final m2 = t * t;
    return Point(
      m0 * p0.x + m1 * p1.x + m2 * p2.x,
      m0 * p0.y + m1 * p1.y + m2 * p2.y,
    );
  }
}
