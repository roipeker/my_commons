import 'dart:async';

extension DurationExt on Duration {

  /// Creates a [Future] to be awaited as a [delay].
  /// ```dart
  /// print("Hello");
  /// await 2.seconds.delay();
  /// print("World");
  ///
  /// // or to use the callback
  ///
  /// Duration(seconds:1).delay(() => print( "hello" ));
  /// 
  /// ```
  Future<T?> delay<T>([FutureOr<T>? Function()? callback]) async {
    return Future.delayed(this, callback);
  }
}