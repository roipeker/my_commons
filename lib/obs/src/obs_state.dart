part of obs;

abstract class ValueState<T> {
  const ValueState();

  factory ValueState.empty() => EmptyState();

  factory ValueState.loading() => LoadingState();

  factory ValueState.error(Object err) => ErrorState(err);

  factory ValueState.data(T data) => DataState(data);
}

class DataState<T> extends ValueState<T> {
  final T? data;

  DataState([this.data]);
}

class ErrorState<T, S> extends ValueState<T> {
  final S error;

  ErrorState(this.error);

  @override
  String toString() => '$error';
}

class EmptyState<T> extends ValueState<T> {}

class LoadingState<T> extends ValueState<T> {}

/// Alias
typedef RxState<T> = ObsState<T>;

/// Defines basic States of asynchronous calls, to simplify
/// common relations between Future "states" and Widget "states".
/// Basically is an [ObsValue] that changes states between:
/// empty (initial), loading, data (success) or error.
/// So it inherits the reactive nature.
///
/// As a helper extension [ObsState.build] provides
/// the the States builders to output Widgets.
///
class ObsState<T> {
  final _state = ObsValue(ValueState<T>.empty());

  /// - Valid for the ErrorState.
  /// The raw error sent via `setError`. Can be an Exception, a String
  /// or any value. But is required for the ErrorState.
  /// Resolve manually with async try/catch, or automatically with
  /// Future::catchError().
  Object? get error {
    final s = _state.value;
    if (s is ErrorState) {
      return (s as ErrorState).error;
    }
    return null;
  }

  /// - Valid for the ErrorState.
  /// Get the Error object as String.
  /// Is preferable to validate the current error / exception
  /// on Future calls and return the error as String.
  /// For all other states returns empty.
  String get errorText {
    final s = _state.value;
    if (s is ErrorState) {
      return (s as ErrorState).error.toString();
    }
    return '';
  }

  /// - Valid for the DataState.
  /// Returns on `DataState`.data, otherwise null.
  /// Usually it represents a successful result from an asynchronous call.
  /// Although it is allowed to be null. Therefore always validate the
  /// state beforehand.
  ///
  T? get data {
    final s = _state.value;
    if (s is DataState) {
      return (s as DataState).data;
    }
    return null;
  }

  /// Set the `ErrorState` with the associated error object.
  void setError(Object errorOrMessage) {
    _state.value = ValueState<T>.error(errorOrMessage);
  }

  /// Set the `DataState` with the associated result.
  void setData(T data) {
    _state.value = ValueState<T>.data(data);
  }

  /// Set to `EmptyState`.
  /// [data] and [error] will be null.
  void setEmpty() => _state.value = ValueState<T>.empty();

  /// Set to `LoadingState`.
  /// [data] and [error] will be null.
  void setLoading() => _state.value = ValueState<T>.loading();

  bool get isLoading => _state.value is LoadingState;

  bool get isError => _state.value is ErrorState;

  bool get isData => _state.value is DataState;

  bool get isEmpty => _state.value is EmptyState;

  /// Only case if subclasses of [ObsState] adds new [ValueState]
  bool get isCustom => !isData && !isLoading && !isError && !isEmpty;

  void dispose() {
    _state.dispose();
  }

  /// Utility method to compute Future States internally.
  /// `onError` resolves `String Function(error)` or `String`.
  FutureOr<T?> compute(Future<T> Function() callback, {
    Object? onError,
    bool throwError = false,
    Function? onData,
  }) {
    if(_state.disposed){
      return null;
    }
    setLoading();
    final f = callback();
    return f.then((value) {
      if(_state.disposed){
        return null;
      }
      // TODO: should we assume empty state as idle?
      if (value == null) {
        setEmpty();
      } else {
        setData(value);
      }
      onData?.call(value);
      return value;
    }, onError: (err) {
      if(_state.disposed){
        return null;
      }
      String msg = '';
      if (onError != null) {
        if (onError is Function) {
          msg = onError(err);
        } else {
          msg = '$onError';
        }
        setError(msg);
      } else {
        setError(err);
        // msg = err.toString();
      }
      if (throwError) {
        throw err;
      }
    });
  }
}
