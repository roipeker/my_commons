import 'dart:async';

/// extension to expenad Number functionality.
extension NumberExt on num {
  // Creates a [Duration] based on the value of this double,int
  // as seconds.
  Duration get seconds {
    return Duration(milliseconds: (this * 1000).round());
  }

  Duration get milliseconds {
    return Duration(milliseconds: round());
  }

  Duration get hours {
    return Duration(hours: round());
  }

  /// Creates a Future.delay based on SECONDS.
  Future<T?> delay<T>([FutureOr<T>? Function()? callback]) async {
    return Future.delayed(seconds, callback);
  }
}

